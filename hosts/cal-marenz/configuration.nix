{ pkgs, secrets, ... }: {
  system.stateVersion = "22.05";

  boot.cleanTmpDir = true;
  zramSwap.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.grub.configurationLimit = 2;

  networking.hostName = "cal-marenz";
}
