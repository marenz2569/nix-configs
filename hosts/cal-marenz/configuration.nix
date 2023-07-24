{ pkgs, secrets, ... }: {
  system.stateVersion = "22.05";

  sops.defaultSopsFile = "${secrets}/cal-marenz/secrets.yaml";

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.grub.configurationLimit = 2;

  networking.hostName = "cal-marenz";

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "webmaster@marenz.ee";

  services.nginx.enable = true;
}
