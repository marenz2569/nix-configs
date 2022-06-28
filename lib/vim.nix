{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; 
  let
    # my_vim = (pkgs.vim_configurable.override { python = python3; });
    my_vim = pkgs.vim_configurable;
  in [
    (my_vim.customize {
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
      vimrcConfig.vam.pluginDictionaries = [
        {
          names = [
            "vim-closetag" "vim-airline"
            "tagbar"
            "YouCompleteMe"
            "hoogle" "haskell-vim"
            "elm-vim"
          ];
        }
      ];
    })
  ];
}
