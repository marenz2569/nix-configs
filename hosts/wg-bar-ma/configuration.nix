{ pkgs, ... }: {
  system.stateVersion = "22.05";

  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.configurationLimit = 2;
  boot.cleanTmpDir = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  zramSwap.enable = false;
  virtualisation.vmware.guest.enable = true;

  networking.hostName = "wg-bar-ma";
}
