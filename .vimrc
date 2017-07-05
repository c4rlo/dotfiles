" Set some global options
set secure
set showcmd
set hidden
set noswapfile
set expandtab
set tabstop=8
set shiftwidth=4
set number
set textwidth=80
set breakindent
set hlsearch
set cinoptions=l1,g0,N-s
set formatoptions=tcroqlnj
set wildmode=list:longest,full
set wildignore=*.o,*.pyc,*.pyo
set colorcolumn=+1
set diffopt+=iwhite
set cryptmethod=blowfish2
set mouse=a

" Set up plugins via vim-plug
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'chrisbra/vim_faq'
Plug 'morhetz/gruvbox'
Plug 'embear/vim-localvimrc'
Plug 'vim-airline/vim-airline'
Plug 'majutsushi/tagbar'
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/vim-easy-align'
Plug 'Shougo/neocomplete.vim'
Plug 'b4winckler/vim-angry'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'cespare/vim-toml'
Plug 'rust-lang/rust.vim'
call plug#end()

" Set color scheme
set background=dark
colo gruvbox

" neocomplete setup
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#sources#syntax#min_keyword_length = 3
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" Close popup by <Space>.
" inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

" Custom keybindings
nnoremap Y y$
nnoremap ' `
nnoremap ; :
nnoremap <C-C> "+y
nnoremap <silent> <S-Right> :bn<CR>
nnoremap <silent> <S-Left> :bp<CR>
nnoremap <CR> o<Esc>
nnoremap <S-CR> O<Esc>
nnoremap \s :%s/\<<C-R><C-W>\>//cg<Left><Left><Left>
nnoremap <silent> ,m :<C-U>exe "diffget " v:count<CR>
nnoremap <silent> ,/ :nohlsearch<CR>

" \z to duplicate
function! s:duplicate()
    exe "normal! " . v:count1 . "yy" . v:count1 . "_p"
endfunction
nnoremap \z :<C-U>call <SID>duplicate()<CR>

" Custom commands
command! -bang Q :qa<bang>
command! Cx :!chmod +x %

" Custom autocommands
" au BufEnter * lcd %:p:h

" Custom abbreviations
iab #i #include 
iab #d #define 
iab #u #undef 

" fzf keybindings
nnoremap <silent> <C-P> :Files<CR>

" EasyAlign keybindings
xmap <silent> ga <Plug>(EasyAlign)
nmap <silent> ga <Plug>(EasyAlign)
vmap <silent> ga <Plug>(EasyAlign)

" Tagbar keybindings
nmap <F8> :TagbarToggle<CR>

" airline customization
let g:airline_powerline_fonts = 1

" See changes in file so far
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
            \ | wincmd p | diffthis
command! DiffOff wincmd p | bwipe | diffoff
function! s:diff_orig_toggle()
    if &diff
        DiffOff
    else
        DiffOrig
    endif
endfun
nnoremap <F12> :call <SID>diff_orig_toggle()<CR>

" Rust file handling
autocmd FileType rust compiler cargo
let g:rust_recommended_style = 0

" C/C++ file handling
autocmd FileType cpp setlocal commentstring=//\ %s
autocmd BufEnter /usr/include/c++/* setf cpp
function! s:insert_gates()
    let gatename = "INCLUDED_" . substitute(toupper(expand('%:r')), '\.', '_', 'g')
    execute "normal! i#ifndef " . gatename
    execute "normal! o#define " . gatename
    execute "normal! Go#endif  // " . gatename
    normal! O
endfun
"
function! s:insert_self_include()
    let headername = expand('%:r') . ".h"
    execute 'normal! i#include "' . headername . '"'
endfun
"
autocmd BufNewFile *.{h,hpp} call <SID>insert_gates()
autocmd BufNewFile *.cpp call <SID>insert_self_include()
"
function! s:flip_h_cpp()
    let path = expand("%")
    if match(path, '\.c\%(pp\|c\)$') > 0
        let flipnameh   = substitute(path, '\.c\%(pp\|c\)$', '.h', '')
        let flipnamehpp = substitute(path, '\.c\%(pp\|c\)$', '.hpp', '')
        try
            exe "b " flipnameh
        catch /E94:/
            try
                exe "b " flipnamehpp
            catch /E94:/
                exe "e " flipnameh
            endtry
        endtry
    elseif match(path, '\.c$') > 0
        let flipname = substitute(path, '\.c$', '.h', '')
        try
            exe "b " flipname
        catch /E94:/
            exe "e " flipname
        endtry
    elseif match(path, '\.hpp$') > 0
        let flipname = substitute(path, '\.hpp$', '.cpp', '')
        try
            exe "b " flipname
        catch /E94:/
            exe "e " flipname
        endtry
    elseif match(path, '\.h$') > 0
        let flipnamec = substitute(path, '\.h$', '.c', '')
        let flipnamecpp = substitute(path, '\.h$', '.cpp', '')
        let flipnamecc = substitute(path, '\.h$', '.cc', '')
        try
            exe "b " flipnamecpp
        catch /E94:/
            try
                exe "b " flipnamec
            catch /E94:/
                try
                    exe "b " flipnamecc
                catch /E94:/
                    if (filereadable(flipnamec))
                        exe "e " flipnamec
                    elseif (filereadable(flipnamecc))
                        exe "e " flipnamecc
                    else
                        exe "e " flipnamecpp
                    endif
                endtry
            endtry
        endtry
    endif
endfun
"
nnoremap <silent> <F2> :call <SID>flip_h_cpp()<CR>
