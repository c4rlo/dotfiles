vim9script

source $VIMRUNTIME/defaults.vim
augroup vimStartup | au! | augroup END  # don't jump to last cursor pos

# Set some global options
set secure
set hidden
set noswapfile
set undofile
set expandtab
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
set splitbelow
set splitright
set shortmess=aoOtTI
set ttymouse=sgr

if &term == 'xterm-kitty'
    # https://sw.kovidgoyal.net/kitty/faq/#using-a-color-theme-with-a-background-color-does-not-work-well-in-vim
    &t_ut = ''
endif

# Disable persistent undo for private files
au BufWritePre /home/carlo/private/* setl noundofile

# Set up plugins via vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/vim-easy-align'
Plug 'b4winckler/vim-angry'
Plug 'tpope/vim-characterize'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-apathy'
Plug 'tpope/vim-ragtag'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'
Plug 'derekwyatt/vim-fswitch'
Plug 'junegunn/fzf.vim'
Plug 'Olical/vim-enmasse'
Plug 'rhysd/vim-clang-format', { 'for': [ 'c', 'cpp' ] }
Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }
Plug 'raimon49/requirements.txt.vim', { 'for': 'requirements' }
Plug 'Glench/Vim-Jinja2-Syntax', { 'for': 'jinja' }
Plug 'fatih/vim-go', { 'for': 'go' }
# Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'cespare/vim-toml', { 'for': 'toml' }
Plug 'jasonccox/vim-wayland-clipboard'
plug#end()

# Set color scheme
set background=dark
colo gruvbox

# Custom keybindings
nnoremap Q <Cmd>qa<CR>
nnoremap Y y$
nnoremap ' `
nnoremap ; :
nnoremap <silent> <S-Right> <Cmd>bn<CR>
nnoremap <silent> <S-Left> <Cmd>bp<CR>
nnoremap <CR> o<Esc>
# nnoremap <S-CR> O<Esc>  # Does't work: Terminal emulator does not see the Shift
nnoremap \s <Cmd>%s/\<<C-R><C-W>\>//cg<Left><Left><Left>

# Custom commands
command Cx :Chmod +x

# EasyAlign keybindings
xmap <silent> gA <Plug>(EasyAlign)
nmap <silent> gA <Plug>(EasyAlign)
vmap <silent> gA <Plug>(EasyAlign)

# fswitch keybindings
nnoremap <silent> <F2> <Cmd>FSHere<CR>
nnoremap <silent> <C-w><F2> <Cmd>FSSplitRight<CR>

# FZF keybindings
nnoremap <C-k> <Cmd>Buffers<CR>
nnoremap <C-p> <Cmd>Files<CR>
imap <C-x><C-f> <Plug>(fzf-complete-path)
imap <C-x><C-l> <Plug>(fzf-complete-line)

# Go file handling
au FileType go setlocal noexpandtab tabstop=4 textwidth=88
au FileType go nmap <Leader>b <Plug>(go-build)
au FileType go nmap <Leader>r <Plug>(go-run)
au FileType go nmap <Leader>t <Plug>(go-test)
au FileType go nmap <Leader>c <Plug>(go-coverage-toggle)
# g:go_fmt_command = "goimports"
g:go_fmt_command = "golines"
g:go_fmt_options = { 'golines': '-m 88' }

# Python file handling
au FileType python setlocal textwidth=88

# HTML/CSS file handling
au FileType html,css,jinja setlocal shiftwidth=2 textwidth&

# C/C++ file handling
au BufEnter /usr/include/c++/* setf cpp
au FileType c,cpp Configure_c_cpp()
def Configure_c_cpp()
    # Builtin ftplugin "c.vim" sets fo-=t so we need to restore it
    setl formatoptions+=t commentstring=//\ %s
    # clang-format on buffer write for C/C++
    # ClangFormatAutoEnable
    # Abbreviations
    iab #i #include 
    iab #d #define 
    iab #u #undef 
enddef
