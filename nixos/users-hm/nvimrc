" 1. run this to install vim-plug
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" or
" curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
"     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" 2. create basic vimrc
" 3. install plugins by running :PlugInstall in vim


" leader key defined somewhere else
let mapleader = "\<space>"
map <leader>ot :term ++curwin<CR>

call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'roryokane/detectindent'
Plug 'ddollar/nerdcommenter'
Plug 'dense-analysis/ale'
Plug 'tomasr/molokai'
Plug 'scrooloose/nerdtree'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'junegunn/fzf'
Plug 'ctrlpvim/ctrlp.vim' " vimscript only fuzzy search
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'Yggdroot/indentLine' " mark levels of line indentation |
Plug 'troydm/zoomwintab.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'qpkorr/vim-bufkill' " :BD is :bdelete without closing windows
call plug#end()

" detectindent
augroup DetectIndent
   autocmd!
   autocmd BufReadPost *  DetectIndent
augroup END

" ale
" dependencies/prequesites
" rustup component add rls
" rustup component add rust-analysis
" rustup component add rust-src
let g:ale_linters = {'rust': ['rls']}

" ddollar/nerdcommentar
map C <leader>ci

" tomasr/molokai
colorscheme molokai

" airline-theme
let g:airline_theme='molokai'
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

" junegunn/rainbow_parentheses.vim
au BufEnter * :RainbowParentheses<CR>

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

nnoremap <silent> <Leader><Enter> :call fzf#run({
\   'source':  reverse(<sid>buflist()),
\   'sink':    function('<sid>bufopen'),
\   'options': '+m',
\   'down':    len(<sid>buflist()) + 2
\ })<CR>

" other
map <leader>W :w<CR>
map <leader>n :NERDTree<CR>

set number 

" enable mouse for window resize
set mouse=a

" share clipboard with system
" not working
"set clipboard=unamedplus

" :tabnew to open new tab
map <C-p> :tabnext<CR>
map <C-u> :tabprevious<CR>
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
