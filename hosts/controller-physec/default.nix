{ ... }: {
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./openwrt-updater.nix
  ];
}
