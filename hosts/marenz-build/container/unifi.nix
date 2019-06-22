{ config, pkgs, lib, ... }:

let
  hostIP = "10.0.33.20";
  containerIP = "10.0.33.21";
in
{
  my.services.proxy.proxyHosts = lib.singleton {
    proxyFrom = { hostNames = [ "unifi.arkom.men" ]; httpPort = 80; httpsPort = 443; };
    proxyTo = { host = containerIP; port = 8443; ssl = true; };
  };

  containers.unifi = {
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
      { config, pkgs, ... }:
      {
        nixpkgs.config.allowUnfree = true;

        networking.firewall = {
          enable = true;
          rejectPackets = true;
          allowPing = true;
          allowedTCPPorts = [ 8443 ];
        };

        services.unifi = {
          enable = true;
          unifiPackage = pkgs.unifiStable;
        };
      };
  };

}
