" Set some global options
set secure
set showcmd
set hidden
set noswapfile
set undofile
set undodir=~/.vim/undo
if !isdirectory($HOME."/.vim/undo") | call mkdir($HOME."/.vim/undo") | endif
set expandtab
set tabstop=8
set shiftwidth=4
set number
set textwidth=80
set breakindent
set hlsearch
set cinoptions=:0,l1,g0.5s,h0.5s,N-s,E-s,t0,+2s,(0,u0,w1,W2s,j1
set formatoptions=tcroqlnj
set wildmode=list:longest,full
set wildignore=*.o,*.pyc,*.pyo
set colorcolumn=+1
set pastetoggle=<F11>
if exists('&cryptmethod')
    set cryptmethod=blowfish2
endif
set mouse=a
set ttymouse=sgr

" Set up plugins via vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'majutsushi/tagbar'
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/vim-easy-align'
Plug 'b4winckler/vim-angry'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'
Plug 'derekwyatt/vim-fswitch'
Plug 'junegunn/fzf.vim'
Plug 'rhysd/vim-clang-format'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'fatih/vim-go'  ", { 'do': ':GoUpdateBinaries' }
Plug 'rust-lang/rust.vim'
Plug 'cespare/vim-toml'
Plug 'hjson/vim-hjson'
call plug#end()

" Set color scheme
set background=dark
colo gruvbox

" Custom keybindings
nnoremap Q :qa<CR>
nnoremap Y y$
nnoremap ' `
nnoremap ; :
nnoremap <silent> <S-Right> :bn<CR>
nnoremap <silent> <S-Left> :bp<CR>
nnoremap <CR> o<Esc>
nnoremap <S-CR> O<Esc>
nnoremap \s :%s/\<<C-R><C-W>\>//cg<Left><Left><Left>

" Custom commands
command! -bang Q :qa<bang>
command! Cx :silent !chmod +x %

" EasyAlign keybindings
xmap <silent> gA <Plug>(EasyAlign)
nmap <silent> gA <Plug>(EasyAlign)
vmap <silent> gA <Plug>(EasyAlign)

" fswitch keybindings
nnoremap <silent> <F2> :FSHere<CR>
nnoremap <silent> <C-w><F2> :FSSplitRight<CR>

" FZF keybindings
nnoremap <C-k> :Buffers<CR>
nnoremap <C-p> :Files<CR>
imap <C-x><C-f> <plug>(fzf-complete-path)
imap <C-x><C-l> <plug>(fzf-complete-line)

" Go file handling
au FileType go setlocal noexpandtab tabstop=4
au FileType go nmap <Leader>b <Plug>(go-build)
au FileType go nmap <Leader>r <Plug>(go-run)
au FileType go nmap <Leader>t <Plug>(go-test)
au FileType go nmap <Leader>c <Plug>(go-coverage-toggle)
let g:go_fmt_command = "goimports"

" C/C++ file handling
au BufEnter /usr/include/c++/* setf cpp
au FileType c,cpp call <SID>configure_c_cpp()
function! s:configure_c_cpp()
    " Builtin ftplugin "c.vim" sets fo-=t so we need to restore it
    setl formatoptions+=t commentstring=//\ %s
    " clang-format on buffer write for C/C++
    " ClangFormatAutoEnable
    " Abbreviations
    iab #i #include 
    iab #d #define 
    iab #u #undef 
endfunction
