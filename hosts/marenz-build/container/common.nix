{ ... }:
{

  imports = [
    ./nextcloud.nix
    ./unifi.nix
  ];

  networking.nat.externalInterface = "enp3s0f0";

}
