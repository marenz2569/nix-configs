{ config, pkgs, lib, ... }:

let
  hostIP = "10.0.33.10";
  containerIP = "10.0.33.11";
  hostname = "cloud.bombenverleih.de";
in
{
  my.services.proxy.proxyHosts = lib.singleton {
    proxyFrom = { hostNames = lib.singleton hostname; httpPort = 80; httpsPort = 443; };
    proxyTo = { host = containerIP; port = 80; };
  };

  containers.nextcloud = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = hostIP;
    localAddress = containerIP;
    bindMounts = {
      "/etc/resolv.conf" = {
        hostPath = "/etc/resolv.conf";
        isReadOnly = true;
      };
    };

    config =
      { config, pkgs, lib, ... }:
      {
        imports = lib.singleton ../../../secrets/configs/hosts/marenz-build/container/nextcloud.nix;

        nixpkgs.config.allowUnfree = true;

        networking.firewall = {
          enable = true;
          rejectPackets = true;
          allowPing = true;
          allowedTCPPorts = [ 80 ];
        };

        services.postgresql = {
          enable = true;
          enableTCPIP = true;
          port = 5432;
          authentication = pkgs.lib.mkOverride 10 ''
            local all all trust
            host all all ::1/128 trust
          '';

        };

        services.elasticsearch = {
          enable = true;
        };

        services.nextcloud = {
          enable = true;
          hostName = hostname;
          nginx.enable = true;
          https = true;
          phpOptions = {
            "short_open_tag" = "Off";
            "expose_php" = "Off";
            "error_reporting" = "E_ALL & ~E_DEPRECATED & ~E_STRICT";
            "display_errors" = "stderr";
            "opcache.enable_cli" = "1";
            "opcache.interned_strings_buffer" = "8";
            "opcache.max_accelerated_files" = "10000";
            "opcache.memory_consumption" = "128";
            "opcache.revalidate_freq" = "1";
            "opcache.fast_shutdown" = "1";
            "catch_workers_output" = "yes";
          };
          config = {
            dbtype = "pgsql";
            dbname = "nextcloud";
            dbhost = containerIP;
            dbuser = "nextcloud";
            dbport = "5432";
            adminuser = "admin";
          };
        };
      };
  };

}
