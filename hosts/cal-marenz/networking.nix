{ lib, ... }: {

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
  };
}
