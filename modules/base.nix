{ lib, pkgs, ... }: {
  # NIX configuration
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    extra-sandbox-paths = /nix/var/cache/ccache
  '';
  nix.autoOptimiseStore = true;
  nix.binaryCaches =
    [ "https://dump-dvb.cachix.org" "https://nix-serve.hq.c3d2.de" ];
  nix.binaryCachePublicKeys = [
    "dump-dvb.cachix.org-1:+Dq7gqpQG4YlLA2X3xJsG1v3BrlUGGpVtUKWk0dTyUU="
    "nix-serve.hq.c3d2.de:KZRGGnwOYzys6pxgM8jlur36RmkJQ/y8y62e52fj1ps="
  ];

  nixpkgs.config.allowUnfree = true;

  # SSH configuration
  users.users.root.openssh.authorizedKeys.keyFiles =
    [ ../keys/ssh/marenz1 ../keys/ssh/marenz1 ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    forwardX11 = true;
    ports = [ 1122 ];
  };

  # SOPS configuration
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  # Service configuration
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  time.timeZone = "Europe/Berlin";

  # GPG SSH Authentication and Smartcard support
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableExtraSocket = true;
  };

  # Yubikey support
  services.udev.packages = with pkgs; [
    yubikey-personalization
    yubioath-desktop
  ];

  # CONSOLE configuration
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" "virtualenv" "sudo" ];
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;

  environment.shellAliases = {
    l = "ls -laFh";
    ll = "ls -lFh";
    cl = "clear";
    v = "vim";
    g = "git";
  };

  fonts.fonts = with pkgs; [ powerline-fonts ];

  # VIM configuration
  programs.vim.defaultEditor = true;

  environment.systemPackages = with pkgs; [
    (vim_configurable.customize {
      name = "vim";
      vimrcConfig.customRC = ''
        syntax on
        colorscheme elflord
        set number

        set autoindent
        set shiftwidth=2
        set tabstop=2

        augroup vimrc_todo
          au!
          au Syntax * syn match MyTodo /\v<(FIXME|NOTE|TODO|OPTIMIZE|XXX|maybe I should|SEE):/
            \ containedin=.*Comment,vimCommentTitle
        augroup END
        hi def link MyTodo Todo
      '';
      vimrcConfig.vam.knownPlugins = pkgs.vimPlugins;
      vimrcConfig.vam.pluginDictionaries = [{
        names = [
          "vim-closetag"
          "vim-airline"
          "tagbar"
          "YouCompleteMe"
          "hoogle"
          "haskell-vim"
          "elm-vim"
        ];
      }];
    })
    sops
    git
  ];
}
