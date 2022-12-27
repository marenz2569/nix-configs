{ config, lib, ... }: {
  sops.secrets.wg-bad5-seckey.owner = config.users.users.systemd-network.name;

  networking.useNetworkd = lib.mkForce true;
  systemd.network = {
    enable = true;

    networks."10-uplink" = {
      matchConfig = { MACAddress = "96:b7:40:2d:e9:5a"; };
      networkConfig = {
        DHCP = "no";
        Address = [ "85.235.64.67/22" "2a03:4000:32:9::1/64" ];
        DNS = [ "1.1.1.1" ];
      };
      routes = [
        {
          routeConfig = {
            Gateway = "85.235.64.1";
            GatewayOnLink = true;
          };
        }
        {
          routeConfig = {
            Gateway = "fe80::1";
            GatewayOnLink = true;
          };
        }
      ];
    };

    netdevs."20-wg-bad5" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg-bad5";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets.wg-bad5-seckey.path;
      };
      wireguardPeers = [{
        wireguardPeerConfig = {
          PublicKey = "9iXE78rmMUWMZozAyWT5CHm+FsAsAN54AiDzJHS5A0c=";
          Endpoint = "80.153.192.57:51820";
          AllowedIPs = [ "10.0.1.0/24" "10.0.0.0/24" ];
          PersistentKeepalive = 25;
        };
      }];
    };
    networks."20-wg-bad5" = {
      matchConfig.Name = "wg-bad5";
      networkConfig = { Address = "10.0.1.2/24"; };
      linkConfig = { RequiredForOnline = "no"; };
      routes = [{ routeConfig = { Destination = "10.0.0.0/24"; }; }];
    };
  };
}
