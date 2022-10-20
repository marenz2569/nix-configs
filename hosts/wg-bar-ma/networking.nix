{ lib, ... }: {
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
      routes = [
        {
          routeConfig = {
            Gateway = "172.26.62.1";
            GatewayOnLink = true;
            Destination = "0.0.0.0/0";
          };
        }
      ];
    };
  };

  networking.useDHCP = lib.mkForce false;
}
