vim9script

source $VIMRUNTIME/defaults.vim

# Set some global options
set secure
set hidden
set noswapfile
set undofile
set expandtab
set shiftwidth=4
set textwidth=88
set colorcolumn=+1
set smoothscroll
set breakindent
set linebreak
set showbreak=»\ 
set number
set relativenumber
set cursorline
set cursorlineopt=number
set signcolumn=number
set noshowmode
set hlsearch
set splitbelow
set splitright
set fillchars=vert:│
set shortmess=aoOtTI
set wildmode=list:longest,full
set wildignore=*.o,*.pyc,*.pyo
set formatoptions=tcroqlnj
set cinoptions=:0,l1,g0.5s,h0.5s,N-s,E-s,t0,+2s,(0,u0,w1,W2s,j1
set termguicolors
set ttymouse=sgr
set pastetoggle=<F11>

# https://sw.kovidgoyal.net/kitty/faq/#using-a-color-theme-with-a-background-color-does-not-work-well-in-vim
if &term == 'xterm-kitty'
    set balloonevalterm
    # Styled and colored underline support
    &t_AU = "\e[58:5:%dm"
    &t_8u = "\e[58:2:%lu:%lu:%lum"
    &t_Us = "\e[4:2m"
    &t_Cs = "\e[4:3m"
    &t_ds = "\e[4:4m"
    &t_Ds = "\e[4:5m"
    &t_Ce = "\e[4:0m"
    # Strikethrough
    &t_Ts = "\e[9m"
    &t_Te = "\e[29m"
    # Truecolor support
    &t_8f = "\e[38:2:%lu:%lu:%lum"
    &t_8b = "\e[48:2:%lu:%lu:%lum"
    &t_RF = "\e]10;?\e\\"
    &t_RB = "\e]11;?\e\\"
    # Cursor control
    &t_RC = "\e[?12$p"
    &t_SH = "\e[%d q"
    &t_RS = "\eP$q q\e\\"
    &t_SI = "\e[5 q"
    &t_SR = "\e[3 q"
    &t_EI = "\e[1 q"
    &t_VS = "\e[?12l"
    # Focus tracking
    &t_fe = "\e[?1004h"
    &t_fd = "\e[?1004l"
    # Window title
    &t_ST = "\e[22;2t"
    &t_RT = "\e[23;2t"
    # Fix background color rendering
    &t_ut = ''
endif

# Put all autocommands defined in this file into a "vimrc" group, and clear that
# group. This ensures the autocommands don't get defined multiple times when
# re-sourcing this file.
augroup vimrc
autocmd!

autocmd WinEnter * set cursorline
autocmd WinLeave * set nocursorline

autocmd VimEnter * if &diff | exe "windo set norelativenumber" | endif

# Replace the "jump to last cursor position" feature from defaults.vim with an improved
# version that skips it when diffing:
autocmd! vimStartup BufReadPost * {
    const l = line("'\"")
    if 1 <= l && l <= line('$') && &ft !~ 'commit' && index(['xxd', 'gitrebase'], &ft) == -1 && !&diff
        # &diff is not yet set at this point when using vimdiff, so we need to also
        # check this a different way:
        if fnamemodify(v:argv[0], ':t') != 'vimdiff' && index(v:argv, '-d') == -1
            exe 'normal! g`"'
        endif
    endif
}

packadd! editorconfig

# Set up plugins via vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'lifepillar/vim-gruvbox8'
Plug 'itchyny/lightline.vim'
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
Plug 'derekwyatt/vim-fswitch'
Plug 'junegunn/fzf.vim'
Plug 'Olical/vim-enmasse'
Plug 'jasonccox/vim-wayland-clipboard'
Plug 'mhinz/vim-startify'
Plug 'cespare/vim-toml'
Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'raimon49/requirements.txt.vim'
Plug 'jeetsukumaran/vim-pythonsense'
Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }
Plug 'fatih/vim-go'  # , { 'do': ':GoUpdateBinaries' }
Plug 'rust-lang/rust.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'chrisbra/vim_faq'
plug#end()

# Set color scheme
set background=dark
colorscheme gruvbox8

# Configure lightline
g:lightline = {
        'colorscheme': 'gruvbox8',
        'active': { 'right': [ ['lineinfo'], ['percent'], ['filetype'] ] }
    }

# Configure vim-lsp
g:lsp_auto_enable = v:false
autocmd BufEnter *.py if !&diff | lsp#enable() | endif
g:lsp_fold_enabled = v:false
g:lsp_diagnostics_echo_cursor = v:true
g:lsp_diagnostics_echo_delay = 150
autocmd User lsp_setup lsp#register_server({
 \      'name': 'pylsp',
 \      'cmd': ['pylsp'],
 \      'allowlist': ['python'],
 \      'workspace_config': {
 \          'pylsp': {
 \              'plugins': {
 \                  'pycodestyle': { 'enabled': v:false },
 \                  'mccabe': { 'enabled': v:false },
 \                  'pyflakes': { 'enabled': v:false },
 \                  'flake8': { 'enabled': v:true },
 \                  'black': { 'enabled': v:true }
 \              },
 \              'configurationSources': ['flake8']
 \          }
 \      }
 \  })
autocmd User lsp_buffer_enabled {
    setlocal omnifunc=lsp#complete tagfunc=lsp#tagfunc
    nnoremap <buffer> gd <Plug>(lsp-peek-definition)
    nnoremap <buffer> gD <Plug>(lsp-definition)
    nnoremap <buffer> <C-W>gD <Cmd>vsplit<CR><Plug>(lsp-definition)
    nnoremap <buffer> gr <Plug>(lsp-references)
    nnoremap <buffer> gs <Plug>(lsp-document-symbol-search)
    nnoremap <buffer> gS <Plug>(lsp-workspace-symbol-search)
    nnoremap <buffer> <Leader>r <Plug>(lsp-rename)
    nnoremap <buffer> [g <Plug>(lsp-previous-diagnostic)
    nnoremap <buffer> ]g <Plug>(lsp-next-diagnostic)
    nnoremap <buffer> K <Plug>(lsp-hover)
    autocmd BufWritePre <buffer> LspDocumentFormatSync
}

# Configure vim-go
g:go_fmt_command = 'golines'
g:go_fmt_options = { 'golines': '-m 88' }

# Configure startify
g:startify_change_to_dir = v:false
g:startify_fortune_use_unicode = v:true
g:startify_custom_header = ''

# Custom commands
command! Cx :Chmod +x

# Custom keybindings
nnoremap Q <Cmd>qa<CR>
nnoremap Y y$
nnoremap ' `
nnoremap ; :
nnoremap <silent> <S-Right> <Cmd>bn<CR>
nnoremap <silent> <S-Left> <Cmd>bp<CR>
nnoremap <Leader>s :%s/\<<C-R><C-W>\>//cg<Left><Left><Left>

# Asyncomplete keybindings
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR>    pumvisible() ? asyncomplete#close_popup() : "\<CR>"

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
autocmd BufWritePre ~/private/* setlocal noundofile

# HTML/CSS file handling
autocmd FileType html,css,jinja setlocal shiftwidth=2 textwidth&

# C/C++ file handling
autocmd BufEnter /usr/include/c++/* setf cpp
autocmd FileType c,cpp {
        # Builtin ftplugin "c.vim" sets fo-=t so we need to restore it
        setlocal formatoptions+=t commentstring=//\ %s
        # Abbreviations
        iab <buffer> #i #include 
        iab <buffer> #d #define 
        iab <buffer> #u #undef 
}
