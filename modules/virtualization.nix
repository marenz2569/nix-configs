{ pkgs, ... }: {
  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [ virtmanager ];
}
