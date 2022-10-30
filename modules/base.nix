{ config, pkgs, lib, self, ... }: {
  # NIX configuration
  nix.package = pkgs.nixLatest;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.settings.extra-sandbox-paths = [ "${config.programs.ccache.cacheDir}" ];
  nix.autoOptimiseStore = true;
  nix.binaryCaches =
    [ "https://dump-dvb.cachix.org" "https://nix-serve.hq.c3d2.de" ];
  nix.binaryCachePublicKeys = [
    "dump-dvb.cachix.org-1:+Dq7gqpQG4YlLA2X3xJsG1v3BrlUGGpVtUKWk0dTyUU="
    "nix-serve.hq.c3d2.de:KZRGGnwOYzys6pxgM8jlur36RmkJQ/y8y62e52fj1ps="
  ];

  # override default nix shell nixpkgs# behaviour to use current flake lock
  nix.registry =
    let flakes = lib.filterAttrs (name: value: value ? outputs) self.inputs;
    in builtins.mapAttrs (name: v: { flake = v; }) flakes;

  nix.nixPath = lib.mapAttrsToList (name: value: "${name}=${value.outPath}") self.inputs;

  nixpkgs.config.allowUnfree = true;

  programs.ccache.enable = true;

  # SSH configuration
  users.users.root.openssh.authorizedKeys.keyFiles =
    [ ../keys/ssh/marenz1 ../keys/ssh/marenz2 ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    forwardX11 = lib.mkDefault config.programs.ssh.setXAuthLocation;
    ports = [ 22 ];
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

  # firmware update
  services.fwupd.enable = true;

  # GPG SSH Authentication and Smartcard support
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableExtraSocket = true;
    pinentryFlavor = "gnome3";
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
    # https://vim.fandom.com/wiki/256_colors_setup_for_console_Vim
    shellInit = ''
      export TERM=screen-256color
    '';
  };

  users.users.root.shell = pkgs.zsh;

  # disable ConnectionNotifier of blueman
  # https://github.com/blueman-project/blueman/issues/1556#issuecomment-882857426
  programs.dconf.enable = true;

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
  environment.variables = { EDITOR = "vim"; };

  environment.systemPackages = with pkgs; [
    ((vim_configurable.override { }).customize {
      name = "vim";
      vimrcConfig = {
        packages.myplugins = with pkgs.vimPlugins; {
          start = [
            vim-closetag
            vim-airline
            vim-airline-themes
            tagbar
            YouCompleteMe
            vim-hoogle
            haskell-vim
            elm-vim
            coc-flutter
            vim-flutter
            dart-vim-plugin
          ];
          opt = [ ];
        };
        customRC = ''
          syntax on
          colorscheme desert
          set number

          set autoindent
          set shiftwidth=2
          set tabstop=2

          au Filetype html,xml,xsd source ~/.vim/scripts/closetag.vim

          augroup vimrc_todo
            au!
            au Syntax * syn match MyTodo /\v<(FIXME|NOTE|TODO|OPTIMIZE|XXX|maybe I should|SEE):/
              \ containedin=.*Comment,vimCommentTitle
          augroup END
          hi def link MyTodo Todo

          filetype plugin indent on
          au BufNewFile,BufRead *.py set tabstop=4 softtabstop=4 shiftwidth=4 expandtab smarttab autoindent

          let g:airline_powerline_fonts = 1
          let g:airline_theme='powerlineish'
          let g:airline#extensions#tabline#enabled = 1

          let g:flutter_show_log_on_run = "tab"
          let g:flutter_use_last_run_option = 1
        '';
      };
    })
    sops
    git
  ];

  services.resolved = {
    enable = true;
    dnssec = "true";
    fallbackDns = [ "1.1.1.1" ];
  };
}
