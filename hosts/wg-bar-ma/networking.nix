{ config, lib, ... }: {
  sops.secrets.wg-bar-ma-seckey.owner = config.users.users.systemd-network.name;

  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.wireguard.enable = true;

  networking.useNetworkd = lib.mkForce true;
  systemd.network = {
    enable = true;

    networks."10-uplink" = {
      matchConfig = { MACAddress = "00:50:56:83:79:9b"; };
      networkConfig = {
        DHCP = "no";
        Address = "172.26.63.120/23";
        DNS = [ "141.30.1.1" "141.76.14.1" ];
      };
      routes = [{
        routeConfig = {
          Gateway = "172.26.62.1";
          GatewayOnLink = true;
          Destination = "0.0.0.0/0";
        };
      }];
    };

    netdevs."20-wg-bar-ma" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg-bar-ma";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets.wg-bar-ma-seckey.path;
        ListenPort = 51820;
      };
      wireguardPeers = [
        {
          # marenz-frickelkiste
          wireguardPeerConfig = {
            PublicKey = "NAJeYqPJolZykRoNG2DPzSV9PMXq118OXU1xq1yTFQE=";
            AllowedIPs = [ "10.65.89.3/32" ];
            PersistentKeepalive = 25;
          };
        }
        {
          # controller-physec
          wireguardPeerConfig = {
            PublicKey = "msGmz9wyLJ1IkDeIjyn8NmhMuW9c5lL/tn2csoKnSi0=";
            AllowedIPs = [ "10.65.89.2/32" ];
            PersistentKeepalive = 25;
          };
        }
      ];
    };
    networks."20-wg-bar-ma" = {
      matchConfig.Name = "wg-bar-ma";
      networkConfig = {
        Address = "10.65.89.1/24";
        IPForward = "ipv4";
      };
    };
  };

  networking.useDHCP = lib.mkForce false;
}
