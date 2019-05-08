{ config, pkgs, ... }:

{
  imports =
    [
      ../../lib/common.nix
      ./nextcloud.nix
      ./hardware-configuration.nix
    ];

#  qemu-user.aarch64 = true;

	nixpkgs.config.allowUnfree = true;

	system.stateVersion = "19.03";

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sdb"; # or "nodev" for efi only
  boot.loader.grub.configurationLimit = 100;

  networking.hostName = "marenz-build"; # Define your hostname.

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

	environment.shellAliases = {
		l = "ls -laFh";
		ll = "ls -lFh";
		cl = "clear";
		v = "vim";
		g = "git";
	};

	programs = {
		gnupg.agent = {
			enable = true;
			enableSSHSupport = true;
		};
		vim.defaultEditor = true;
		zsh = {
			enable = true;
			ohMyZsh = {
				enable = true;
				theme = "agnoster";
				plugins = [ "git" "virtualenv" "sudo" ];
			};
		};
	};

  services.openssh = {
	  enable = true;
  	permitRootLogin = "yes";
	  ports = [ 22 ];
  };

  #virtualisation.libvirtd = {
  #  enable = true;
  #  onShutdown = "shutdown";
  #};

  users.users.marenz = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/marenz";
    createHome = true;
    extraGroups = [ "wheel" "audio" "libvirtd" ];
    shell = pkgs.zsh;
	};

}
