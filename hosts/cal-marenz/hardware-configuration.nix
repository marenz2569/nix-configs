{ modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "vmw_pvscsi" "xen_blkfront" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/24223d7c-5e1a-47ef-af47-97f1857da6db";
    fsType = "ext4";
  };
}
