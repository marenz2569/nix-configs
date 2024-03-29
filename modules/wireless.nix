{ config, secrets, ... }: {
  sops.secrets."wpa_supplicant.conf" = {
    format = "binary";
    sopsFile = "${secrets}/marenz-frickelkiste/wpa_supplicant.conf";
  };

  networking.supplicant."wlp3s0" = {
    driver = "wext";
    extraConf = ''
      pmf=1
      fast_reauth=1
      ap_scan=1
    '';
      # mac_addr=1
    userControlled.enable = true;
    extraCmdArgs = "-c${config.sops.secrets."wpa_supplicant.conf".path}";
  };

  hardware.wirelessRegulatoryDatabase = true;

  environment.etc."certs/TUD-CACert.pem".text =
    builtins.readFile ./TUD-CACert.pem;
}
