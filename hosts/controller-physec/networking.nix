{ secrets, config, lib, pkgs, ... }: {
  sops.secrets.wg-bar-ma-seckey.owner = config.users.users.systemd-network.name;

  networking = {
    useNetworkd = true;
    usePredictableInterfaceNames = true;
    wireguard.enable = true;
    useDHCP = lib.mkDefault true;
    interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  };

  systemd.network = {
    enable = true;

    networks."10-ether" = {
      matchConfig.PermanentMACAddress = "94:c6:91:11:c9:d2";
      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = true;
      };
      linkConfig.MACAddress = "96:c6:91:11:c9:d2";
      dhcpV4Config.RouteMetric = 100;
    };

    netdevs."20-wg-bar-ma" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg-bar-ma";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets.wg-bar-ma-seckey.path;
      };
      wireguardPeers = [{
        wireguardPeerConfig = {
          PublicKey = "iriQ7Bi5ANixvCOV6EwLcxKCnwBt6hexn+5D4lTGhyY=";
          Endpoint = "172.26.63.120:51820";
          AllowedIPs = [ "10.65.89.0/24" ];
          PersistentKeepalive = 25;
        };
      }];
    };
    networks."20-wg-bar-ma" = {
      matchConfig.Name = "wg-bar-ma";
      networkConfig = { Address = "10.65.89.2/24"; };
      routes = [{
        routeConfig = {
          Gateway = "10.65.89.1";
          Destination = "10.65.89.0/24";
          Metric = 300;
        };
      }];
    };
  };
}
