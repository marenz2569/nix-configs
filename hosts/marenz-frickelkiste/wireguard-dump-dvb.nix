{ config, ... }: {

  sops.secrets.wg-dump-dvb-seckey = { };

  networking.wg-quick.interfaces.wg-dump-dvb = {
    address = [ "10.13.37.4/32" ];
    privateKeyFile = config.sops.secrets.wg-dump-dvb-seckey.path;
    peers = [{
      publicKey = "WDvCObJ0WgCCZ0ORV2q4sdXblBd8pOPZBmeWr97yphY=";
      allowedIPs = [ "10.13.37.0/24" ];
      endpoint = "academicstrokes.com:51820";
      persistentKeepalive = 25;
    }];
  };
}
