{ pkgs, ... }: {
  sops.secrets."wpa_supplicant.conf" = {
    format = "binary";
    sopsFile = ../secrets/wpa_supplicant.conf;
  };

  networking.supplicant."wlp3s0" = {
    driver = "wext";
    extraConf = ''
      pmf=1
      bgscan="simple:30:-70:3600"
      ctrl_interface=/run/wpa_supplicant
      ctrl_interface_group=wheel
    '';
    userControlled.enable = true;
    extraCmdArgs = "-c/run/secrets/wpa_supplicant.conf";
  };

  hardware.wirelessRegulatoryDatabase = true;

  environment.etc."certs/TUD-CACert.pem".text =
    builtins.readFile ./TUD-CACert.pem;
}
