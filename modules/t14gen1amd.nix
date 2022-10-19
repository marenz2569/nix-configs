{ lib, ... }: {
  powerManagement.enable = lib.mkForce true;

  # lan only works on first boot. after suspend it is broken..
  powerManagement.powerUpCommands = ''
    modprobe -r r8169 && modprobe r8169
  '';
}
