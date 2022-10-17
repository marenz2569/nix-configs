{ pkgs, ... }: {
  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [ virtmanager ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
