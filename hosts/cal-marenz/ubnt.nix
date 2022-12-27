{ pkgs, config, lib, ... }: {
  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifiStable;
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

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers."uisp" = {
      image = "nico640/docker-unms";
      autoStart = true;
      ports = [ "2055:2055" "9443:443" ];
      volumes = [ "/var/lib/uisp:/config" ];
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
}
