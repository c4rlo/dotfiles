-- Based on: https://github.com/nvim-lua/kickstart.nvim
-- Also worth looking at: https://github.com/VonHeikemen/nvim-starter

-- Set some options

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.cursorlineopt = 'number'
vim.o.signcolumn = 'number'
vim.o.colorcolumn = '+1'
vim.o.mouse = 'a'
vim.o.mousemodel = 'extend'
vim.o.breakindent = true
vim.o.linebreak = true
vim.o.showbreak = '» '
vim.o.swapfile = false
vim.o.undofile = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.opt.formatoptions:append('roln')
vim.o.cinoptions = ':0,l1,g0.5s,h0.5s,N-s,E-s,t0,+2s,(0,u0,w1,W2s,j1'
vim.o.completeopt = 'menuone,noselect,popup,fuzzy'
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.showmode = false
vim.o.shortmess = 'aoOtTI'
vim.opt.diffopt:remove('linematch:40')
vim.opt.diffopt:append('linematch:60')
vim.o.title = true

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.no_plugin_maps = true -- recommended by nvim-treemapper-textobjects

vim.loader.enable()

-- Some autocmds

vim.api.nvim_create_autocmd('WinEnter', {
  callback = function() vim.wo.cursorline = true end
})

vim.api.nvim_create_autocmd('WinLeave', {
  callback = function() vim.wo.cursorline = false end
})

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = vim.fn.expand('~/private') .. '*',
  callback = function() vim.bo.undofile = false end
})

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.hl.on_yank() end
})

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.o.diff then
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        vim.wo[win].relativenumber = false
      end
    end
  end
})

-- Change diagnostic symbols in the sign column (gutter)

local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
local diagnostic_signs = {}
for type, icon in pairs(signs) do
  diagnostic_signs[vim.diagnostic.severity[type]] = icon
end
vim.diagnostic.config { signs = { text = diagnostic_signs }, virtual_lines = true }

-- Basic keymaps

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', "'", '`')
vim.keymap.set('n', 'Q', vim.cmd.qa)
vim.keymap.set('n', '<Leader>s', [[:%s/\<<C-R><C-W>\>//cg<Left><Left><Left>]])
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist)

-- Import utils

local utils = require('user.utils')

-- Copy path to clipboard / open in GitHub

vim.keymap.set('n', '<Leader>np',
  function()
    local path = vim.fn.expand('%')
    vim.fn.setreg('+', path)
    vim.notify(('Copied "%s" to system clipboard'):format(path))
  end)

vim.keymap.set('n', '<Leader>nn',
  function()
    local path = vim.fn.expand('%')
    local git_root = vim.fs.root(0, '.git')
    if git_root then
      path = vim.fs.relpath(git_root, path) or path
    end
    vim.fn.setreg('+', path)
    vim.notify(('Copied "%s" to system clipboard'):format(path))
  end)

vim.keymap.set({'n', 'v'}, '<Leader>ng',
  function()
    local url = utils.github_url()
    if url then
      vim.fn.setreg('+', url)
      vim.notify(('Copied "%s" to system clipboard'):format(url))
    end
  end)

vim.keymap.set({'n', 'v'}, '<Leader>nG',
  function()
    local url = utils.github_url()
    if url then
      vim.system({'runapp', '-c', 'Firefox', 'firefox', url},
        { stdout = false, stderr = false, detach = true })
    end
  end)

-- Go setup

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go', 'gomod', 'gosum', 'gowork' },
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 4
  end
})

-- C/C++ setup

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp' },
  callback = function()
    vim.bo.commentstring = '// %s' -- default is /*%s*/
    vim.keymap.set('n', '<F2>', utils.cpp_switch_header, { buffer = true })
  end,
})

-- lfrc fixup

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lf' },
  callback = function()
    vim.bo.commentstring = '# %s'
  end
})

-- Load plugins

local plugins = {
  'g:tpope/vim-unimpaired',
  'g:tpope/vim-characterize',
  'g:tpope/vim-sleuth',
  'g:tpope/vim-fugitive',
  'g:tpope/vim-eunuch',
  'g:nvim-mini/mini.align',
  { src = 'g:kylechui/nvim-surround', version = vim.version.range('*') },
  { src = 'g:nvim-treesitter/nvim-treesitter', version = 'main' },
  { src = 'g:nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
  'g:neovim/nvim-lspconfig',
  { src = 'g:saghen/blink.cmp', version = vim.version.range('1.*') },
  'g:folke/snacks.nvim',
  'g:nvim-lualine/lualine.nvim',
  'g:ellisonleao/gruvbox.nvim',
  'g:nvim-tree/nvim-web-devicons',
  { src = 'g:folke/lazydev.nvim', data = { skip_load = true } },
}

vim.api.nvim_create_autocmd('PackChanged', { callback = function(ev)
  local name, kind = ev.data.spec.name, ev.data.kind
  if name == 'nvim-treesitter' and kind == 'update' then
    if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
    vim.cmd.TSUpdate()
  end
end })

vim.pack.add(plugins, {
  load = function(plugin)
    if not (plugin.spec.data or {}).skip_load then
      vim.cmd('packadd! ' .. plugin.spec.name)
    end
  end
})

-- Load lazydev for .lua files only

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  once = true,
  callback = function()
    vim.cmd.packadd('lazydev.nvim')
    require('lazydev').setup {
      library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } }
    }
  end
})

-- Misc plugins setup

require('mini.align').setup()
require('nvim-surround').setup()

-- vim-characterize registers key map 'ga', but mini.align also uses that and overrides it.
-- Instead we set up an alternative keymap:
vim.keymap.set('n', '<Leader>c', '<Plug>(characterize)')

require('lualine').setup{}
vim.cmd.colorscheme('gruvbox')

-- snacks setup (mainly picker)

require('snacks').setup {
  input = {},
  picker = {
    matcher = {
      frecency = true,
      cwd_bonus = true,
    },
    win = {
      input = {
        keys = {
          ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
        },
      },
    },
  },
}

local function picker_fn(f, opts)
  return function() require'snacks.picker'[f](opts) end
end

vim.keymap.set('n', '<C-k>', picker_fn('buffers'))
vim.keymap.set('n', '<C-p>', picker_fn('files', { hidden = true }))
vim.keymap.set('n', '<Leader>g', picker_fn('git_files'))
vim.keymap.set('n', '<Leader>/', picker_fn('grep'))
vim.keymap.set('n', '<Leader>*', picker_fn('grep_word'))
vim.keymap.set('n', 'gd', picker_fn('lsp_definitions'))
vim.keymap.set('n', 'gr', picker_fn('lsp_references', { nowait = true }))
vim.keymap.set('n', 'gI', picker_fn('lsp_implementations'))
vim.keymap.set('n', '<Leader>D', picker_fn('lsp_type_definitions'))
vim.keymap.set('n', '<Leader>ds', picker_fn('lsp_symbols'))
vim.keymap.set('n', '<Leader>ws', picker_fn('lsp_workspace_symbols'))

vim.api.nvim_create_user_command('Bdelete',
  function(opts) require'snacks.bufdelete'.delete({ force = opts.bang }) end,
  { bang = true }
)
vim.api.nvim_create_user_command('Bwipeout',
  function(opts) require'snacks.bufdelete'.delete({ wipe = true, force = opts.bang }) end,
  { bang = true }
)

-- Treesitter setup

local ts_langs_builtin = { 'c', 'lua', 'markdown', 'query', 'vim' }
local ts_langs_install = { 'bash', 'cpp', 'css', 'git_config', 'go', 'gomod', 'gosum', 'gotmpl',
  'gowork', 'hcl', 'html', 'javascript', 'jinja', 'just', 'make', 'perl', 'python', 'rust', 'sql' }
local ts_langs_no_indent = { 'cpp', 'python' }
local ts_langs_no_move = { 'python' }
local ts_langs_all = vim.list_extend(vim.list_slice(ts_langs_builtin), ts_langs_install)

require('nvim-treesitter').install(ts_langs_install)

local function ts_on_filetype(ev)
  -- Enable treesitter highlighting.
  vim.treesitter.start()

  -- Enable treesitter indentation.
  if not vim.list_contains(ts_langs_no_indent, ev.match) then
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end

  -- Add textobject select keymaps.
  local function buf_set_keymap(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, { buffer = true })
  end
  local select_fn = require'nvim-treesitter-textobjects.select'.select_textobject
  local select_keymaps = {
    ['aa'] = '@parameter.outer', ['ia'] = '@parameter.inner',
    ['af'] = '@function.outer',  ['if'] = '@function.inner',
    ['ac'] = '@class.outer',     ['ic'] = '@class.inner',
  }
  for keys, object in pairs(select_keymaps) do
    buf_set_keymap({'x', 'o'}, keys, function() select_fn(object) end)
  end

  -- Add textobject motion keymaps.
  if not vim.list_contains(ts_langs_no_move, ev.match) then
    local move_fns = require'nvim-treesitter-textobjects.move'
    buf_set_keymap({'n', 'x', 'o'}, '[[',
      function() move_fns.goto_previous('@function.outer', 'textobjects') end
    )
    buf_set_keymap({'n', 'x', 'o'}, ']]',
      function() move_fns.goto_next('@function.outer', 'textobjects') end
    )
  end

  -- Add textobject swap keymaps.
  local swap_fns = require'nvim-treesitter-textobjects.swap'
  buf_set_keymap('n', '<Leader><',
    function() swap_fns.swap_previous('@parameter.inner') end
  )
  buf_set_keymap('n', '<Leader>>',
    function() swap_fns.swap_next('@parameter.inner') end
  )
end

vim.api.nvim_create_autocmd('FileType', { pattern = ts_langs_all, callback = ts_on_filetype })

require('nvim-treesitter-textobjects').setup { move = { set_jumps = true } }

-- blink.cmp (autocomplete) setup

require('blink.cmp').setup {
  keymap = {
    preset = 'super-tab',
    ['<C-j>'] = { 'select_next', 'fallback' },
    ['<C-k>'] = { 'select_prev', 'fallback' },
  },
  completion = {
    list = { selection = { preselect = false } },
    documentation = { auto_show = true },
  },
  cmdline = { enabled = false },
  sources = {
    default = { 'lsp' },
    per_filetype = {
      lua = { inherit_defaults = true, 'lazydev' }
    },
    providers = {
      lazydev = {
        name = 'LazyDev',
        module = 'lazydev.integrations.blink',
        score_offset = 100,
      },
    },
  },
  enabled = utils.is_cursor_outside_comment,
}

-- Language Server Protocol (LSP) setup (hooked up to blink.cmp)

local lsp_configs = {
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
        usePlaceholders = true,
        analyses = {
          useany = true,
        },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          constantValues = true,
          parameterNames = true,
          rangeVariableTypes = true,
        }
      }
    }
  },
  rust_analyzer = {
    settings = {
      ['rust-analyzer'] = { check = { command = 'clippy' } }
    }
  },
  clangd = {},
  ty = {},
  lua_ls = {},
  ts_ls = {},
}

local function on_lsp_attach(_, bufnr)
  local function nmap(keys, func)
    vim.keymap.set('n', keys, func, { buffer = bufnr })
  end

  -- Delete some default keymaps that conflict with our definition of 'gr'.
  for _, key in ipairs({ 'grn', 'grr', 'gri', 'gra', 'grt', 'grx' }) do
    pcall(vim.keymap.del, 'n', key)
  end

  nmap('<Leader>r', vim.lsp.buf.rename)
  nmap('<Leader>a', vim.lsp.buf.code_action)
  nmap('gD', vim.lsp.buf.declaration)
  nmap('<Leader>k', vim.lsp.buf.signature_help)

  nmap('<F3>', -- Toggle inlay hints
    function()
      local scope = { bufnr = bufnr }
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(scope), scope)
    end)

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, {})
  nmap('<Leader>F', vim.lsp.buf.format)
end

if not (vim.o.diff or vim.env.NVIM_NO_LSP == '1') then
  local lsp_config_common = {
    on_attach = on_lsp_attach,
    capabilities = require('blink.cmp').get_lsp_capabilities()
  }
  for name, config in pairs(lsp_configs) do
    vim.lsp.config(name, vim.tbl_extend('keep', config, lsp_config_common))
    vim.lsp.enable(name)
  end
end

-- vim: ts=2 sts=2 sw=2 et tw=100
