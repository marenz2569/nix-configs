{ secrets, config, lib, pkgs, ... }: {
  sops.secrets.wg-dump-dvb-seckey.owner =
    config.users.users.systemd-network.name;

  sops.secrets.wg-bar-ma-seckey.owner = config.users.users.systemd-network.name;

  sops.secrets.wg-zentralwerk-seckey.owner =
    config.users.users.systemd-network.name;

  sops.secrets."openconnect-tud.pass" = {
    format = "binary";
    sopsFile = "${secrets}/openconnect-tud.pass";
  };

  # systemd.services.systemd-networkd.environment.SYSTEMD_LOG_LEVEL = "debug";
  # systemd.services.systemd-resolved.environment.SYSTEMD_LOG_LEVEL = "debug";

  networking = {
    useNetworkd = true;
    usePredictableInterfaceNames = true;
    wireguard.enable = true;
    useDHCP = lib.mkDefault true;
    interfaces.enp6s0.useDHCP = lib.mkDefault true;
    interfaces.wlp3s0.useDHCP = lib.mkDefault true;
    hosts = {
      "10.65.90.10" = [ "alice-physec" ];
      "10.65.90.11" = [ "eve-physec" ];
      "10.65.90.12" = [ "bob-physec" ];
      "10.65.90.20" = [ "alice2-physec" ];
      "10.65.90.21" = [ "eve2-physec" ];
      "10.65.90.22" = [ "bob2-physec" ];
    };
  };

  # workaround for networkd waiting for shit
  systemd.services.systemd-networkd-wait-online.serviceConfig.ExecStart = [
    "" # clear old command
    "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any"
  ];

  services.openvpn.servers.tud = {
    autoStart = true;
    config = ''
      tls-client
      pull
      remote 141.30.56.199
      port 1194
      dev-type tun
      dev openvpn-tud-tun
      pull-filter ignore redirect-gateway
      proto udp
      auth-user-pass
      nobind
      tls-version-min 1.2
      auth-retry nointeract
      <ca>
      -----BEGIN CERTIFICATE-----
      MIIDJDCCAqqgAwIBAgIIVUfkeTU1KgIwCgYIKoZIzj0EAwQwgcYxCzAJBgNVBAYT
      AkRFMQ8wDQYDVQQIEwZTYXhvbnkxEDAOBgNVBAcTB0RyZXNkZW4xKDAmBgNVBAoT
      H1RlY2huaXNjaGUgVW5pdmVyc2l0YWV0IERyZXNkZW4xQjBABgNVBAsTOVplbnRy
      dW0gZnVlciBJbmZvcm1hdGlvbnNkaWVuc3RlIHVuZCBIb2NobGVpc3R1bmdzcmVj
      aG5lbjEmMCQGA1UEAxMdT3BlblZQTiBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwHhcN
      MjAwMzEzMTcwMjAwWhcNMjMwMzEzMTcwMjAwWjCBxjELMAkGA1UEBhMCREUxDzAN
      BgNVBAgTBlNheG9ueTEQMA4GA1UEBxMHRHJlc2RlbjEoMCYGA1UEChMfVGVjaG5p
      c2NoZSBVbml2ZXJzaXRhZXQgRHJlc2RlbjFCMEAGA1UECxM5WmVudHJ1bSBmdWVy
      IEluZm9ybWF0aW9uc2RpZW5zdGUgdW5kIEhvY2hsZWlzdHVuZ3NyZWNobmVuMSYw
      JAYDVQQDEx1PcGVuVlBOIENlcnRpZmljYXRlIEF1dGhvcml0eTB2MBAGByqGSM49
      AgEGBSuBBAAiA2IABAFyQ2/XGnQpeqQGR9//A3eSUl/dm5ksuPba4yuF+TonfIMS
      SkYrW3KbFexK/7M1F2n6xTCk8YxgF0cl/6AqVW80UsdW9FeQSO2jEOY8xl4Ag95B
      5KD1ur3kfn/GxRfJe6NjMGEwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQU
      /IAoHx3yIpN6FV/js71yXvf+POwwHwYDVR0jBBgwFoAU/IAoHx3yIpN6FV/js71y
      Xvf+POwwCwYDVR0PBAQDAgEGMAoGCCqGSM49BAMEA2gAMGUCMQDyPDrW8JofQUiG
      a1DacXRr3dQUAKIdpgk7VFXU90hRrSTkMBgZNev6rd+TBgk/XeQCMCLq4DQgwTjc
      jexcxW/cIHH5bfUy/xykQWjEnlJsPoeA0JaTtBcrrK7h/9dUCUhk+g==
      -----END CERTIFICATE-----
      </ca>
      <tls-crypt>
      #
      # 2048 bit OpenVPN static key
      #
      -----BEGIN OpenVPN Static key V1-----
      9b32985687664a47084463da740ff2a2
      8976d0f78b2264e7feda8486efe02289
      7ff5abc2f1bfe170eb620e63fb0cba01
      fb65e4f6668fd3a718e1b3d4d94ac2a5
      56a1d53f8f971fb0307034d425758cb3
      1aeb8156b05ceb2fe79eaf56777c3bb5
      0fa26bc1f3a0b21d3a1a8787f133c626
      5776465ab7848443d8b153300853a7c2
      167d72baf41b6372db1b801499ac1aa3
      3506442dfb204bb037e961c938fd9571
      cb62228eb0c482f3db4598f08f8c26fe
      1d72031e82f5bd163e961310fe781806
      8e546e4957f6eae73585b245ae3a6273
      fc4375d385cb2c95646af01ec31a23cc
      e7fbbd353a27ec216f6e677fed8a4298
      6b0c01f429db0ddb52fd0760788c32d5
      -----END OpenVPN Static key V1-----
      </tls-crypt>
      remote-cert-tls server
      cipher AES-256-GCM
      auth SHA384
      reneg-sec 43200
      verb 3
      auth-user-pass ${config.sops.secrets."openconnect-tud.pass".path}
    '';
  };

  systemd.network = {
    enable = true;

    # always use cloudflare for dns. dnssec is fucked up in too many networks...
    networks."10-ether" = {
      matchConfig.Name = "enp6s0";
      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = true;
        DNS = "1.1.1.1";
      };
      dhcpV4Config = {
        RouteMetric = 100;
        UseDNS = false;
      };
      routes = [{
        routeConfig = {
          Gateway = "_dhcp4";
          Destination = "141.30.56.199/32";
          Metric = 100;
        };
      }];
    };

    # always use cloudflare for dns. dnssec is fucked up in too many networks...
    networks."10-wlan" = {
      matchConfig.Name = "wlp3s0";
      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = true;
        DNS = "1.1.1.1";
      };
      dhcpV4Config = {
        RouteMetric = 100;
        UseDNS = false;
      };
      routes = [{
        routeConfig = {
          Gateway = "_dhcp4";
          Destination = "141.30.56.199/32";
          Metric = 200;
        };
      }];
    };

    netdevs."20-wg-dumpdvb" = {
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
    networks."20-wg-dumpdvb" = {
      matchConfig.Name = "wg-dumpdvb";
      networkConfig = {
        Address = "10.13.37.4/24";
        IPv6AcceptRA = true;
      };
      routes = [{
        routeConfig = {
          Gateway = "10.13.37.1";
          Destination = "10.13.37.0/24";
          Metric = 300;
        };
      }];
    };

    netdevs."20-openvpn-tud" = {
      netdevConfig = {
        Kind = "tun";
        Name = "openvpn-tud-tun";
      };
    };
    networks."20-openvpn-tud" = {
      matchConfig.Name = "openvpn-tud-tun";
      networkConfig = {
        DNS = [ "141.30.1.1" "141.76.14.1" ];
        Domains = [ "~tu-dresden.de" ];
        KeepConfiguration = true;
      };
      # 141.30.0.0/16
      # 141.76.0.0/16
      # 172.16.0.0/12
      # 192.168.0.0/16
      routes = [
        {
          routeConfig = {
            Destination = "141.30.1.1/32";
            Metric = 99;
          };
        }
        {
          routeConfig = {
            Destination = "141.76.14.1/32";
            Metric = 99;
          };
        }
        {
          routeConfig = {
            Destination = "141.30.0.0/16";
            Metric = 300;
          };
        }
        {
          routeConfig = {
            Destination = "141.76.0.0/16";
            Metric = 300;
          };
        }
        {
          routeConfig = {
            Destination = "172.16.0.0/12";
            Metric = 300;
          };
        }
        {
          routeConfig = {
            Destination = "192.168.0.0/16";
            Metric = 300;
          };
        }
      ];
    };

    netdevs."20-wg-zentralwerk" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg-zentralwerk";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets.wg-zentralwerk-seckey.path;
        RouteTable = "off";
      };
      wireguardPeers = [{
        wireguardPeerConfig = {
          PublicKey = "PG2VD0EB+Oi+U5/uVMUdO5MFzn59fAck6hz8GUyLMRo=";
          Endpoint = "81.201.149.152:1337";
          AllowedIPs = [
            # c3d2.zentralwerk.org
            "172.22.99.0/24"
            # hq.c3d2.de
            # serv.zentralwerk.org
            "172.20.73.0/25"
            # cluster.zentralwerk.org
            "172.20.77.0/27"
            # wg
            "172.20.76.224/28"
          ];
          PersistentKeepalive = 25;
        };
      }];
    };
    networks."20-wg-zentralwerk" = {
      matchConfig.Name = "wg-zentralwerk";
      networkConfig = {
        Address = "172.20.76.230/28";
        IPv6AcceptRA = true;
        DNS = "172.20.73.8";
        DNSSEC = "no";
        Domains = [
          "~hq.c3d2.de"
          "~serv.zentralwerk.org"
          "~c3d2.zentralwerk.org"
          "~cluster.zentralwerk.org"
        ];
      };
      routes = [
        {
          routeConfig = {
            Destination = "172.20.73.8/32";
            Metric = 99;
          };
        }
        {
          routeConfig = {
            Destination = "172.22.99.0/24";
            Metric = 290;
          };
        }
        {
          routeConfig = {
            Destination = "172.20.73.0/25";
            Metric = 290;
          };
        }
        {
          routeConfig = {
            Destination = "172.20.77.0/27";
            Metric = 290;
          };
        }
        {
          routeConfig = {
            Destination = "172.20.76.224/28";
            Metric = 290;
          };
        }
      ];
    };

    netdevs."21-wg-bar-ma" = {
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
          AllowedIPs = [ "10.65.89.0/24" "10.65.90.0/24" ];
          PersistentKeepalive = 25;
        };
      }];
    };
    networks."21-wg-bar-ma" = {
      matchConfig.Name = "wg-bar-ma";
      networkConfig = { Address = "10.65.89.3/24"; };
      routes = [
        {
          routeConfig = {
            Destination = "10.65.89.0/24";
            Metric = 300;
          };
        }
        {
          routeConfig = {
            Destination = "10.65.90.0/24";
            Metric = 300;
          };
        }
      ];
    };
  };
}
