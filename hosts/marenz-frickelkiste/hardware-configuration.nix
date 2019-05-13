# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/af794b85-9e9b-42da-891c-13d7ec51f79b";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."root-crypt".device = "/dev/disk/by-uuid/d35d3f9a-28a7-4d87-a0bf-f10f15fdbcb6";

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/b95fc813-93e2-4902-8477-38b2feaf41cd";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."home-crypt".device = "/dev/disk/by-uuid/70c07423-ce83-4316-b8b8-91df5343fdc9";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/9f5562dd-82d7-4039-b69c-0ccc28857bb9";
      fsType = "ext4";
    };

  fileSystems."/home/mpd" =
    { device = "/dev/disk/by-uuid/d150d515-0684-4ade-9c1b-7b6b92e7c416";
      fsType = "ext4";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}