{ ... }:
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


}
