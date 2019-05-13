{ config, pkgs, ... }:

{
  imports =
    [
      ../../lib/common.nix
      ./hardware-configuration.nix
      ./nextcloud.nix
    ];

  qemu-user.aarch64 = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.configurationLimit = 100;

  networking.hostName = "marenz-build";
  networking.nat.externalInterface = "enp3s0f0";

  time.timeZone = "Europe/Amsterdam";

  environment.systemPackages = with pkgs; [
		curl wget htop feh xorg.xkill gnupg st unzip mpv openssl file binutils-unwrapped tmux tmuxp
		git sshpass
		usbutils pciutils dmidecode iftop
		gcc cmake gnumake
		python27Full python36Full
		python27Packages.pip python36Packages.pip
		python27Packages.virtualenv python36Packages.virtualenv
		python36Packages.powerline powerline-fonts
		mutt
    virtmanager
  ];

  services.openssh = {
	  enable = true;
    passwordAuthentication = false;
    forwardX11 = true;
	  ports = [ 1122 ];
  };

  services.xserver.enable = true;

  hardware.opengl.driSupport32Bit = true;
  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
  };

  my.services.proxy = {
    enable = true;
    proxyHosts = [
      { proxyFrom = { hostNames = [ "cloud.bombenverleih.de" ]; httpPort = 80; httpsPort = 443; };
        proxyTo = { host = "10.0.33.11"; port = 80; };
      }
    ];
  };

  users.users.marenz = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/marenz";
    createHome = true;
    extraGroups = [ "wheel" "libvirtd" ];
    shell = pkgs.zsh;
	};

}
