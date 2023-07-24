{ pkgs, ... }: {
  nix.settings.auto-optimise-store = true;

  services.openssh.settings.X11Forwarding = true;

  # Service configuration
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

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

  # disable ConnectionNotifier of blueman
  # https://github.com/blueman-project/blueman/issues/1556#issuecomment-882857426
  programs.dconf.enable = true;

  fonts.fonts = with pkgs; [ powerline-fonts ];

  # VIM configuration
  programs.vim.defaultEditor = true;
  environment.variables = { EDITOR = "vim"; };

  environment.systemPackages = with pkgs; [
    nodejs
    ((vim_configurable.override { }).customize {
      name = "vim";
      vimrcConfig = {
        packages.myplugins = with pkgs.vimPlugins; {
          start = [
            vim-closetag
            vim-airline
            vim-airline-themes
            tagbar
            #YouCompleteMe
            vim-hoogle
            haskell-vim
            elm-vim
            coc-nvim
            coc-tabnine
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

}
