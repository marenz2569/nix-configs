{ pkgs, ... }:
{
  
  imports = [
    ./admins.nix
    ./qemu.nix
    ./proxy.nix
    ./vim.nix
  ];

  system.stateVersion = "19.03";

  nixpkgs.config.allowUnfree = true;

  boot.tmpOnTmpfs = true;

	environment.shellAliases = {
		l = "ls -laFh";
		ll = "ls -lFh";
		cl = "clear";
		v = "vim";
		g = "git";
	};

  # GPG SSH Authentication and Smartcard support
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Yubikey support
	services.udev.packages = with pkgs; [
    yubikey-personalization
    yubioath-desktop
  ];

  programs.vim.defaultEditor = true;

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" "virtualenv" "sudo" ];
    };
  };

}
