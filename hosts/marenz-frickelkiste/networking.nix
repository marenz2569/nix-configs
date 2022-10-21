{ config, lib, pkgs, ... }: {
  sops.secrets.wg-dump-dvb-seckey.owner =
    config.users.users.systemd-network.name;

  networking = {
    useNetworkd = true;
    usePredictableInterfaceNames = true;
    wireguard.enable = true;
    useDHCP = lib.mkDefault true;
    interfaces.enp6s0.useDHCP = lib.mkDefault true;
    interfaces.wlp3s0.useDHCP = lib.mkDefault true;
  };

  # workaround for networkd waiting for shit
  systemd.services.systemd-networkd-wait-online.serviceConfig.ExecStart = [
    "" # clear old command
    "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any"
  ];

  systemd.network = {
    enable = true;

    networks."999-ether" = {
      matchConfig.Name = "enp6s0";
      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = true;
      };
      dhcpV4Config = { RouteMetric = 999; };
    };

    networks."900-wlan" = {
      matchConfig.Name = "wlp3s0";
      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = true;
      };
      dhcpV4Config = { RouteMetric = 900; };
    };

    netdevs."800-wg-dumpdvb" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg-dumpdvb";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets.wg-dump-dvb-seckey.path;
      };
      wireguardPeers = [{
        wireguardPeerConfig = {
          PublicKey = "WDvCObJ0WgCCZ0ORV2q4sdXblBd8pOPZBmeWr97yphY=";
          Endpoint = "academicstrokes.com:51820";
          AllowedIPs = [ "10.13.37.0/24" ];
          PersistentKeepalive = 25;
        };
      }];
    };
    networks."800-wg-dumpdvb" = {
      matchConfig.Name = "wg-dumpdvb";
      networkConfig = {
        Address = "10.13.37.4/24";
        IPv6AcceptRA = true;
      };
      routes = [{
        routeConfig = {
          Gateway = "10.13.37.1";
          Destination = "10.13.37.0/24";
          Metric = 800;
        };
      }];
    };
  };
}
