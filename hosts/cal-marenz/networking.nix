{ config, lib, ... }: {
  sops.secrets.wg-bad5-seckey.owner = config.users.users.systemd-network.name;

  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.wireguard.enable = true;

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
        ListenPort = 51820;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            PublicKey = "9iXE78rmMUWMZozAyWT5CHm+FsAsAN54AiDzJHS5A0c=";
            Endpoint = "80.153.192.57:51820";
            AllowedIPs = [ "10.0.1.1/32" "10.0.0.0/24" ];
            PersistentKeepalive = 25;
          };
        }
        {
          wireguardPeerConfig = {
            PublicKey = "X/buhhASrS05ehQdp7Dl2PPFyN4Jh7jzZ3j0fA60QVU=";
            AllowedIPs = [ "10.0.1.3/32" "10.0.20.0/24" ];
            PersistentKeepalive = 25;
          };
        }
        {
          wireguardPeerConfig = {
            PublicKey = "06GGOqS8S3k9No0sDbb4QDh4rINgRBQDZBpgIJWvIzw=";
            AllowedIPs = [ "10.0.1.4/32" ];
            PersistentKeepalive = 25;
          };
        }
        {
          wireguardPeerConfig = {
            PublicKey = "wGugw4yYllwozPRRYWd7dG6bTD62mzqiXmfZG4qWxR0=";
            AllowedIPs = [ "10.0.1.5/32" ];
            PersistentKeepalive = 25;
          };
        }
      ];
    };
    networks."20-wg-bad5" = {
      matchConfig.Name = "wg-bad5";
      linkConfig = { RequiredForOnline = "no"; };
      routes = [
        { routeConfig = { Destination = "10.0.0.0/24"; }; }
        { routeConfig = { Destination = "10.0.20.0/24"; }; }
      ];
      networkConfig = {
        Address = "10.0.1.2/24";
        IPForward = "ipv4";
      };
    };
  };
}
