# ~/.config/nixpgs/home.nix
# install home manager via: `nix-shell '<home-manager>' -A install`
{ config, lib, pkgs, ... }:

{

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "okelmann";
  home.homeDirectory = "/home/okelmann";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";

  # home.environment.variables = { EDITOR = "rvim"; };
  xdg.configFile."nvim/init.vim".source = ~/dotfiles/vimrc;
  
  programs.direnv.enable = true;
  programs.direnv.enableNixDirenvIntegration = true;

  home.packages = with pkgs; [
    antigen
    fzf
    tree
    git
    tmux
    psmisc
    libguestfs-with-appliance
    lazygit
    ack
    ripgrep
    bottom # btm
    (
      vim_configurable.customize {
        name = "vim";
        vimrcConfig.customRC = ''
          " 1. run this to install vim-plug
          " curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
          "     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
          " or
          " curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
          "     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
          " 2. create basic vimrc
          " 3. install plugins by running :PlugInstall in vim

          let &t_SI = "\<Esc>[6 q"
          let &t_SR = "\<Esc>[3 q"
          let &t_EI = "\<Esc>[0 q"
          " preferrable for Konsole?
          " let &t_SI = "\<Esc>]50;CursorShape=1\x7"
          " let &t_SR = "\<Esc>]50;CursorShape=2\x7"
          " let &t_EI = "\<Esc>]50;CursorShape=0\x7"

          " leader key defined somewhere else
          let mapleader = "\<space>"
          map <leader>ot :term ++curwin<CR>

          " detectindent
          " augroup DetectIndent
          "    autocmd!
          "    autocmd BufReadPost *  DetectIndent
          " augroup END

          " ale
          " dependencies/prequesites
          " rustup component add rls
          " rustup component add rust-analysis
          " rustup component add rust-src
          let g:ale_linters = {'rust': ['analyzer']}

          " ddollar/nerdcommentar
          map C <leader>ci

          " tomasr/molokai
          colorscheme molokai

          " airline-theme
          let g:airline_theme='molokai'
          let g:airline#extensions#tabline#enabled = 1
          let g:airline_powerline_fonts = 1

          " junegunn/rainbow_parentheses.vim
          " au BufEnter * :RainbowParentheses<CR>

          " junegunn/fzf
          map <leader>f :FZF<CR> 

          function! s:buflist()
            redir => ls
            silent ls
            redir END
            return split(ls, '\n')
          endfunction

          function! s:bufopen(e)
            execute 'buffer' matchstr(a:e, '^[ 0-9]*')
          endfunction

          " tmux navigator fix for nixos
          " let g:tmux_navigator_no_mappings = 1
          map <leader>j :TmuxNavigateDown<cr>
          nnoremap <silent> <c-h> :NERDTree
          " nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
          " nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
          " nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
          " nnoremap <silent> <c-l> :TmuxNavigateRight<cr>
          " nnoremap <silent> {Previous-Mapping} :TmuxNavigatePrevious<cr>

          nnoremap <silent> <Leader><Enter> :call fzf#run({
          \   'source':  reverse(<sid>buflist()),
          \   'sink':    function('<sid>bufopen'),
          \   'options': '+m',
          \   'down':    len(<sid>buflist()) + 2
          \ })<CR>

          " other
          map <leader>W :w<CR>
          map <leader>n :NERDTree<CR>
          let g:NERDTreeWinSize=25
          let g:ackprg = 'rg --vimgrep'

          set number 

          " enable mouse for window resize
          set mouse=a

          " share clipboard with system
          " not working
          "set clipboard=unamedplus

          " :tabnew to open new tab
          map <C-p> :tabnext<CR>
          " map <C-u> :tabprevious<CR> no thats already scroll up
          " :e to open new buffer in current window
          " :bd to close current buffer
          " :ls to list all buffers
          map <C-i> :bp<CR>
          map <C-o> :bn<CR>

          " bindings knom  
          map <s-bs> <b>

          "Remember the positions in files with some git-specific exceptions"
          autocmd BufReadPost *
            \ if line("'\"") > 0 && line("'\"") <= line("$")
            \           && expand("%") !~ "COMMIT_EDITMSG"
            \           && expand("%") !~ "ADD_EDIT.patch"
            \           && expand("%") !~ "addp-hunk-edit.diff"
            \           && expand("%") !~ "git-rebase-todo" |
            \   exe "normal g`\"" |
            \ endif

          " Changed default required by SuSE security team--be aware if enabling this
          " that it potentially can open for malicious users to do harmful things.
          set nomodeline

          " keybinds to remember
          " :source % to reload vimrc when opened
          " c-x c-f for filepath completion
          "
          " todo:
          " - list of recently edited files

          vmap y :w !xclip -se c -i<CR><CR>
          vmap p :r!xclip -se c -o<CR>
          " override (themes?) bracket highlighting []
          hi MatchParen term=reverse cterm=bold,underline ctermfg=208 ctermbg=233 gui=bold guifg=#FD971F guibg=#000000
        '';
        vimrcConfig.packages.nixbundle.start = with pkgs.vimPlugins; [ 
          vim-sensible 
          # detenctindent
          nerdcommenter
          ale
          molokai
          nerdtree
          rainbow_parentheses-vim
          fzf-vim
          gitgutter
          vim-airline
          vim-airline-themes
          indentLine
          zoomwintab-vim
          vim-tmux-navigator
          vim-bufkill
          ack-vim
        ];
#          tpope/vim-sensible
#          roryokane/detectindent
#          ddollar/nerdcommenter
#          dense-analysis/ale
#          tomasr/molokai
#          scrooloose/nerdtree
#          junegunn/rainbow_parentheses.vim
#          junegunn/fzf
#          ctrlpvim/ctrlp.vim # vimscript only fuzzy search
#          airblade/vim-gitgutter
#          vim-airline/vim-airline
#          vim-airline/vim-airline-themes
#
#          Yggdroot/indentLine # mark levels of line indentation |
#          troydm/zoomwintab.vim
#          christoomey/vim-tmux-navigator
#          qpkorr/vim-bufkill # :BD is :bdelete without closing windows
#        ];
      }
    )
    # rustup
  ];
}
