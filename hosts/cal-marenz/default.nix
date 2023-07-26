{ ... }: {
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./radicale.nix
    ./ubnt.nix
    ./bitwarden.nix
  ];
}
