{ lib, ... }: {
  networking = {
    nameservers = [ "141.30.1.1" "141.76.14.1" ];
    defaultGateway = "172.26.62.1";
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [{
          address = "172.26.63.103";
          prefixLength = 23;
        }];
        ipv4.routes = [{
          address = "172.26.62.1";
          prefixLength = 32;
        }];
      };

    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="00:50:56:83:30:45", NAME="eth0"

  '';
}
