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
      linkConfig.RequiredForOnline = "no";
      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = true;
      };
      linkConfig.MACAddress = "96:c6:91:11:c9:d2";
      dhcpV4Config.RouteMetric = 100;
    };

    networks."10-ether2" = {
      matchConfig.PermanentMACAddress = "a0:ce:c8:0a:46:51";
      linkConfig.RequiredForOnline = "no";
      networkConfig = {
        IPForward = "ipv4";
        IPMasquerade = "ipv4";
        Address = "10.65.90.1/24";
      };
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
      networkConfig = {
        Address = "10.65.89.2/24";
        IPForward = "ipv4";
        IPMasquerade = "ipv4";
      };
      routes = [{
        routeConfig = {
          Gateway = "10.65.89.1";
          Destination = "10.65.89.0/24";
          Metric = 300;
        };
      }];
    };
  };

  services.dhcpd4 = {
    enable = true;
    interfaces = [ "enp0s20f0u3" ];
    extraConfig = ''
      option domain-name-servers 1.1.1.1;
      option subnet-mask 255.255.255.0;

      subnet 10.65.90.0 netmask 255.255.255.0 {
        option broadcast-address 10.65.90.255;
        option routers 10.65.90.1;
        interface enp0s20f0u3;

        host alice {
          hardware ethernet 94:83:c4:1b:cf:2f;
          fixed-address 10.65.90.10;
        }
        host eve {
          hardware ethernet 94:83:c4:1b:d1:90;
          fixed-address 10.65.90.11;
        }
        host bob {
          hardware ethernet 94:83:c4:1b:d2:2f;
          fixed-address 10.65.90.12;
        }
        host alice2 {
          hardware ethernet c0:4a:00:39:4e:fb;
          fixed-address 10.65.90.20;
        }
      }
    '';
  };
}
