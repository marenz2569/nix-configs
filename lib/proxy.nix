{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.my.services.proxy;
  acmeKeyDir = "/var/lib/acme/keys";
  acmeWebRoot = "/var/lib/acme/acme-challenges";
  email = "webmaster@arkom.men";
  uniqueValueFrom = name: flatten (subtractLists [ null ] (unique (concatMap (f: [ (getAttrs [ name ] f.proxyFrom).${name} ]) cfg.proxyHosts)));

in {

  options.my.services.proxy = {

    enable = mkOption {
      default = false;
      description = "Whether to enable the proxy";
      type = types.bool;
    };

    certificates = mkOption {
      default = [];
      description = ''
        Path to the ssl certificates.
        If list is empty acme will be used.
      '';
      type = types.listOf types.string;
    };

    proxyHosts = mkOption {
      type = types.listOf (types.submodule (
        {
          options = {
            proxyFrom = mkOption {
              type = types.submodule (
                {
                  options = {
                    hostNames = mkOption {
                      type = types.listOf types.str;
                      default = [];
                      description = ''
                        Proxy these hostnames.
                      '';
                    };
                    httpPort = mkOption {
                      type = types.nullOr types.int;
                      default = null;
                      description = ''
                        Proxy http from this host port.
                      '';
                    };
                    httpsPort = mkOption {
                      type = types.int;
                      default = 443;
                      description = ''
                        Proxy https from this host port.
                      '';
                    };
                  };
                });
                # TODO: add assertion: http port 80 may only be used once with every domain AND port may not be 88 as it is used for local acme redirection
                description = ''
                  proxyFrom { hostNames = [ /* list of hostnames */ ]; httpPort = null or 80; httpsPort = 443; } to proxyTo
                '';
                default = {};
              };

            proxyTo = mkOption {
              type = types.submodule (
                {
                  options = {
                    host = mkOption {
                      type = types.nullOr types.string;
                      default = null;
                      description = ''
                        Hostsnames from which will be forwarded.
                        Any hostname port combination may only be used once.
                      '';
                    };
                    port = mkOption {
                      type = types.int;
                      default = 80;
                      description = ''
                        Port to forward unencrypted to.
                      '';
                    };
                  };
                });
              description = ''
                { host = ip; port = 80; } to proxy to
              '';
              default = {};
            };
          };

        }));
      default = [];
      example = [
        { proxyFrom = { hostNames = [ "cloud.bombenverleih.de" ]; httpPort = 80; httpsPort = 443; };
          proxyTo = { host = "172.22.99.99"; port = 80; };
        }
        { proxyFrom = { hostNames = [ "mdm.arkom.men" ]; httpPort = 80; httpsPort = 443; };
          proxyTo = { host = "..."; port = 80; };
        }
        { proxyFrom = { hostNames = [ "mdm.arkom.men" ]; httpsPort = 8883; };
          proxyTo = { host = "..."; port = 1883; };
        }
      ];
    };

  };

  config = mkIf cfg.enable {

    networking.firewall = {
      enable = true;
      rejectPackets = true;
      allowPing = true;
      allowedTCPPorts = uniqueValueFrom "httpPort" ++ uniqueValueFrom "httpsPort";
    };

    services.httpd = {
      enable = true;
      adminAddr = "${email}";
      listen = [
        { ip = "*"; port = 88; }
      ];
      user = "haproxy";
      group = "haproxy";
      servedDirs = singleton { dir = acmeWebRoot; urlPath = "/"; };
    };

    # create nginx on port 88 for acme if certificates is empty
    security.acme.production = true;
    security.acme.directory = "${acmeKeyDir}";
    security.acme.certs = if (cfg.certificates == []) then
      let
        acmePairs = map (host: { name = host; value = {
            webroot = "${acmeWebRoot}";
            email = "${email}";
            user = "haproxy";
            group = "haproxy";
            postRun = "systemctl reload haproxy.service";
          }; } ) (uniqueValueFrom "hostNames");
      in
        listToAttrs acmePairs
    else {};

    # create preliminary certificates on boot if none exist
    system.activationScripts.createDummyKey = "/var/run/current-system/sw/bin/systemctl start acme-selfsigned-certificates.target";

    services.haproxy = {
      enable = true;
      config = 
        let
          # frontend for all http ports and always port 80
          # redirect /.well-known/acme-challenges to 127.0.0.1:88
          # redirect to the specific https port if the right hostname is choosen.
          http = concatMapStringsSep "\n" (port: ''
            frontend http-${toString port}
              bind :::${toString port} v4v6
              timeout client 30000
              default_backend proxy-backend-http-${toString port}

            backend proxy-backend-http-${toString port}
              timeout connect 5000
              timeout check 5000
              timeout server 30000
              mode http
              ${optionalString (toString port == "80") ''
                acl url-acme-http path_beg /.well-known/acme-challenge/
                use-server server-acme if url-acme-http
                server server-acme 127.0.0.1:88
              ''}
              ${concatMapStringsSep "\n" (proxyHost: optionalString (proxyHost.proxyFrom.httpPort == port && proxyHost.proxyFrom.hostNames != [])
                  concatMapStringsSep "\n" (hostname: ''
                    http-request redirect location https://%[req.hdr(host)]:${toString proxyHost.proxyFrom.httpsPort}%[capture.req.uri] if { req.hdr(host) -i ${hostname} } !url-acme-http
                  ''
                  ) proxyHost.proxyFrom.hostNames
                ) cfg.proxyHosts
              }
            ''
          ) (unique ([ 80 ] ++ (uniqueValueFrom "httpPort")));

          # frontend for all https ports
          # terminate ssl and redirect to local ip
          https = concatMapStringsSep "\n" (port: ''
            frontend https-${toString port}
              option http-server-close
              reqadd X-Forwarded-Proto:\ https
              reqadd X-Forwarded-Port:\ ${toString port}
              rspadd  Strict-Transport-Security:\ max-age=15768000
              timeout client 30000
              default_backend proxy-backend-https-${toString port}
              ${let
                  certs = if (cfg.certificates == []) then
                    concatMapStrings (f: concatStrings [ " crt " acmeKeyDir "/" f "/full.pem" ]) (uniqueValueFrom "hostNames")
                  else
                    concatMapStrings (f: concatStrings [ " crt " f ]) cfg.certificates;
                  in
                    "bind :::${toString port} v4v6 ssl ${certs}"
                }

            backend proxy-backend-https-${toString port}
              timeout connect 5000
              timeout check 5000
              timeout server 30000
              ${concatMapStringsSep "\n" (proxyHost: optionalString (proxyHost.proxyFrom.hostNames != [])
                  concatMapStringsSep "\n" (hostname: optionalString (proxyHost.proxyFrom.httpsPort == port) ''
                    use-server server-https-${hostname}-${toString port} if { req.hdr(host) -i ${hostname} }
                    server server-https-${hostname}-${toString port} ${proxyHost.proxyTo.host}:${toString proxyHost.proxyTo.port}
                  ''
                  ) proxyHost.proxyFrom.hostNames
                ) cfg.proxyHosts
              }
            ''
          ) (uniqueValueFrom "httpsPort");
        in
          ''
            global
              tune.ssl.default-dh-param 2048
          '' +
          http + https;
    };
  };
}
