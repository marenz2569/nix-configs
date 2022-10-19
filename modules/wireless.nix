{ config, secrets, ... }: {
  sops.secrets."wpa_supplicant.conf" = {
    format = "binary";
    sopsFile = "${secrets}/wpa_supplicant.conf";
  };

  networking.supplicant."wlp3s0" = {
    driver = "nl80211,wext";
    extraConf = ''
      pmf=1
      fast_reauth=1
      ap_scan=1
      autoscan=periodic:1
    '';
    userControlled.enable = true;
    extraCmdArgs = "-c${config.sops.secrets."wpa_supplicant.conf".path}";
  };

  hardware.wirelessRegulatoryDatabase = true;

  environment.etc."certs/TUD-CACert.pem".text =
    builtins.readFile ./TUD-CACert.pem;
}
