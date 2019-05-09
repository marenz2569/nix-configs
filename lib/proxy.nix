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
      description = "whether to enable proxy";
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
                # TODO: add assertion
                description = ''
                  proxyFrom { hostNames = [ /* list of hostnames *]; httpPort = null or 80; httpsPort = 443; } to proxyTo
                  http ports have to rewrite to https. except for /.well-known/acme-challenge
                  TODO: add assertion: http port 80 may only be used once with every domain AND port may not be 88 as it is used for local acme redirection
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
                        Host to forward traffic to.
                        Any hostname may only be used once
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
                { host = /* ip or fqdn */; port = 80; } to proxy to
                This proxy implements acme.
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
        { port = 88; }
      ];
      user = "haproxy";
      group = "haproxy";
      virtualHosts = [
        {
          hostName = "...";
          documentRoot = "${acmeWebRoot}";
        }
      ];
    };

    # create nginx on port 88 for acme if certificates is empty
    # TODO: create internal option for paths to certificates
    security.acme.production = true;
    security.acme.directory = "${acmeKeyDir}";
    security.acme.preliminarySelfsigned = false;
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

    system.activationScripts.createDummyKey =
    let
      mkKeys = dir:
      ''
        dir=${dir}
        mkdir -m 0700 -p $dir

        if ! [[ -e $dir/key.pem ]]; then
          workdir="$(mktemp -d)"
          # Create CA
          ${pkgs.openssl}/bin/openssl genrsa -des3 -passout pass:xxxx -out $workdir/ca.pass.key 2048
          ${pkgs.openssl}/bin/openssl rsa -passin pass:xxxx -in $workdir/ca.pass.key -out $workdir/ca.key
          ${pkgs.openssl}/bin/openssl req -new -key $workdir/ca.key -out $workdir/ca.csr \
            -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=Security Department/CN=mdm.arkom.men"
          ${pkgs.openssl}/bin/openssl x509 -req -days 1 -in $workdir/ca.csr -signkey $workdir/ca.key -out $workdir/ca.crt

          # Create key
          ${pkgs.openssl}/bin/openssl genrsa -des3 -passout pass:xxxx -out $workdir/server.pass.key 2048
          ${pkgs.openssl}/bin/openssl rsa -passin pass:xxxx -in $workdir/server.pass.key -out $workdir/server.key
          ${pkgs.openssl}/bin/openssl req -new -key $workdir/server.key -out $workdir/server.csr \
            -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=IT Department/CN=mdm.arkom.men"
          ${pkgs.openssl}/bin/openssl x509 -req -days 1 -in $workdir/server.csr -CA $workdir/ca.crt \
            -CAkey $workdir/ca.key -CAserial $workdir/ca.srl -CAcreateserial \
            -out $workdir/server.crt

          # Copy key to destination
          cp $workdir/server.key $dir/key.pem

          # Create fullchain.pem (same format as "simp_le ... -f fullchain.pem" creates)
          cat $workdir/{server.crt,ca.crt} > "$dir/fullchain.pem"

          # Create full.pem for e.g. lighttpd
          cat $workdir/{server.key,server.crt,ca.crt} > "$dir/full.pem"
        fi
      '';
    in
      ''
        ${concatMapStringsSep "\n" (f: mkKeys (concatStrings [ acmeKeyDir "/" f ])) (uniqueValueFrom "hostNames")}
        chown -R haproxy:haproxy ${acmeKeyDir} 
      '';

    # TODO: create acme preliminary before starting haproxy !!
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
              default_backend proxy-backend-http-${toString port}

            backend proxy-backend-http-${toString port}
              timeout connect 5000
              timeout check 5000
              timeout client 30000
              timeout server 30000
              ${optionalString (toString port == "80") ''
                acl url-acme-http path_beg /.well-known/acme-challenge/
                use-server server-acme if url-acme-http
                server server-acme http://127.0.0.1:88%[capture.req.uri]
              ''}
              ${concatMapStringsSep "\n" (proxyHost: 
                  optionalString (proxyHost.proxyFrom.httpPort == port && proxyHost.proxyFrom.hostNames != [])
                    concatMapStringsSep "\n" (hostname: ''
                      http-request redirect location https://%[req.hdr(host)]:${toString port}%[capture.req.uri] if { req.hdr(host) -i ${hostname} }
                    ''
                    ) (proxyHost.proxyFrom.hostNames)
              ) (cfg.proxyHosts)
              }
            ''
          ) (unique ([ 80 ] ++ (uniqueValueFrom "httpPort")));

          # frontend for all https ports
          # terminate ssl and redirect to local ip
          https = concatMapStringsSep "\n" (port: ''
            frontend https-${toString port}
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
              timeout client 30000
              timeout server 30000
              ${concatMapStringsSep "\n" (proxyHost:
                  optionalString (proxyHost.proxyFrom.hostNames != [])
                    concatMapStringsSep "\n" (hostname:
                      optionalString (proxyHost.proxyFrom.httpsPort == port) ''
                        use-server server-https-${hostname}-${toString port} if { req.hdr(host) -i ${hostname} }
                        server server-https-${hostname}-${toString port} http://${proxyHost.proxyTo.host}:${toString proxyHost.proxyTo.port}%[capture.req.uri]
                      ''
                    ) (proxyHost.proxyFrom.hostNames)
                ) (cfg.proxyHosts)
              }
            ''
          ) (uniqueValueFrom "httpsPort");
        in
          http + https;
    };
  };
}
