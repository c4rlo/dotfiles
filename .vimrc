vim9script

source $VIMRUNTIME/defaults.vim

# Set some global options
set secure
set hidden
set noswapfile
set undofile
set expandtab
set shiftwidth=4
set textwidth=80
set colorcolumn=+1
set breakindent
set number
set hlsearch
set splitbelow
set splitright
set shortmess=aoOtTI
set wildmode=list:longest,full
set wildignore=*.o,*.pyc,*.pyo
set formatoptions=tcroqlnj
set cinoptions=:0,l1,g0.5s,h0.5s,N-s,E-s,t0,+2s,(0,u0,w1,W2s,j1
set ttymouse=sgr
set pastetoggle=<F11>

if &term == 'xterm-kitty'
    # https://sw.kovidgoyal.net/kitty/faq/#using-a-color-theme-with-a-background-color-does-not-work-well-in-vim
    &t_ut = ''
endif

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
Plug 'jasonccox/vim-wayland-clipboard'
Plug 'cespare/vim-toml'
Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'raimon49/requirements.txt.vim'
Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }
Plug 'fatih/vim-go'  # , { 'do': ':GoUpdateBinaries' }
Plug 'rust-lang/rust.vim'
Plug 'dense-analysis/ale'
plug#end()

# Set color scheme
set background=dark
colorscheme gruvbox

# Configure ALE
g:ale_python_pylsp_config = {
    'pylsp': {
        'plugins': {
            'pycodestyle': { 'enabled': v:false },
            'mccabe': { 'enabled': v:false },
            'pyflakes': { 'enabled': v:false },
            'flake8': { 'enabled': v:true },
            'black': { 'enabled': v:true }
        },
        'configurationSources': ['flake8']
    }
}
g:ale_completion_enabled = 1
set omnifunc=ale#completion#OmniFunc
g:airline#extensions#ale#enabled = 1

# Configure vim-go
# g:go_fmt_command = "goimports"
g:go_fmt_command = "golines"
g:go_fmt_options = { 'golines': '-m 88' }

# Custom keybindings
nnoremap Q <Cmd>qa<CR>
nnoremap Y y$
nnoremap ' `
nnoremap ; :
nnoremap <silent> <S-Right> <Cmd>bn<CR>
nnoremap <silent> <S-Left> <Cmd>bp<CR>
nnoremap <CR> o<Esc>
# nnoremap <S-CR> O<Esc>  # Does't work: Terminal emulator does not see the Shift
nnoremap <Leader>s :%s/\<<C-R><C-W>\>//cg<Left><Left><Left>

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

# Disable persistent undo for private files
au BufWritePre ~/private/* setlocal noundofile

# HTML/CSS file handling
au FileType html,css,jinja setlocal shiftwidth=2 textwidth&

# C/C++ file handling
au BufEnter /usr/include/c++/* setf cpp
au FileType c,cpp {
        # Builtin ftplugin "c.vim" sets fo-=t so we need to restore it
        setlocal formatoptions+=t commentstring=//\ %s
        # Abbreviations
        iab <buffer> #i #include 
        iab <buffer> #d #define 
        iab <buffer> #u #undef 
    }
