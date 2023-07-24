{ pkgs, config, lib, ... }: {
  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi7;
    mongodbPackage = pkgs.mongodb-4_2;
    openFirewall = false;
  };

  networking.firewall.interfaces."wg-bad5".allowedTCPPorts = [
    8080 # Port for UAP to inform controller.
    8880 # Port for HTTP portal redirect, if guest portal is enabled.
    8843 # Port for HTTPS portal redirect, ditto.
    6789 # Port for UniFi mobile speed test.
  ];

  networking.firewall.interfaces."wg-bad5".allowedUDPPorts = [
    3478 # UDP port used for STUN.
    10001 # UDP port used for device discovery.
  ];

  services.nginx.proxyResolveWhileRunning = true;
  services.nginx.virtualHosts."unifi.marenz.ee" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://127.0.0.1:8443";
      recommendedProxySettings = true;
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header    Referer "";
      '';
    };
  };

  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
    autoPrune.enable = true;
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers."uisp" = {
      image = "nico640/docker-unms:2.2.15";
      autoStart = true;
      ports = [ "127.0.0.1:2055:2055" "127.0.0.1:9443:443" ];
      volumes = [ "/var/lib/uisp:/config" ];
      environment = {
        PUBLIC_HTTPS_PORT = "9443";
        PUBLIC_WS_PORT = "9443";
      };
    };
  };

  services.nginx.virtualHosts."uisp.marenz.ee" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://127.0.0.1:9443";
      recommendedProxySettings = true;
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header    Referer "";
      '';
    };
  };

  # pin docker to older nixpkgs: https://github.com/NixOS/nixpkgs/issues/244159
  virtualisation.docker.package = (let
    pinnedPkgs = import (pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "b6bbc53029a31f788ffed9ea2d459f0bb0f0fbfc";
      sha256 = "sha256-JVFoTY3rs1uDHbh0llRb1BcTNx26fGSLSiPmjojT+KY=";
    }) { };
  in if pkgs.docker.version == "20.10.25" then
    pinnedPkgs.docker
  else
    pkgs.docker);
}
