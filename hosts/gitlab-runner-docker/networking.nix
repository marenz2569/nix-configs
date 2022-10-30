{ lib, ... }: {
  networking = {
    useNetworkd = true;
    usePredictableInterfaceNames = false;
    useDHCP = lib.mkForce false;
    interfaces.eth0.useDHCP = lib.mkForce false;
  };

  systemd.network = {
    enable = true;

    networks."10-ether" = {
      matchConfig.MACAddress = "02:f0:35:5d:65:82";
      networkConfig = {
        Address = "172.20.73.46/25";
        DNS = [ "172.20.73.8" "9.9.9.9" ];
      };
      routes = [{
        routeConfig = {
          Gateway = "172.20.73.1";
          Destination = "0.0.0.0/0";
        };
      }];
    };
  };
}
