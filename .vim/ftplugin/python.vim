vim9script

setlocal textwidth=88
nnoremap <buffer> K <Plug>(ale_hover)
nnoremap <buffer> gd <Plug>(ale_go_to_definition)
nnoremap <buffer> gD <Plug>(ale_go_to_type_definition)
nnoremap <buffer> [l <Plug>(ale_previous_wrap)
nnoremap <buffer> ]l <Plug>(ale_next_wrap)

b:ale_linters = ['pylsp']
b:ale_fixers = ['black']
b:ale_fix_on_save = v:true
