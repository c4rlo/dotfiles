-- Based on: https://github.com/nvim-lua/kickstart.nvim
-- Also worth looking at: https://github.com/VonHeikemen/nvim-starter

-- Set some options

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

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
vim.o.formatoptions = 'tcroqlnj'
vim.o.cinoptions = ':0,l1,g0.5s,h0.5s,N-s,E-s,t0,+2s,(0,u0,w1,W2s,j1'
vim.o.completeopt = 'menuone,noselect,popup,fuzzy'
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.showmode = false
vim.o.shortmess = 'aoOtTI'
vim.o.diffopt = 'internal,filler,closeoff,linematch:60'
vim.o.title = true

-- Basic keymaps

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', "'", '`')
-- vim.keymap.set('n', ';', ':')
vim.keymap.set('n', 'Q', '<Cmd>qa<CR>')
vim.keymap.set('n', '<Leader>s', [[:%s/\<<C-R><C-W>\>//cg<Left><Left><Left>]])
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist)
vim.keymap.set('n', '<Leader>n',
  function()
    local path = vim.fn.expand('%:p')
    vim.fn.setreg('+', path)
    vim.notify('Copied "'..path..'" to system clipboard')
  end)

-- Some autocmds

vim.api.nvim_create_autocmd('WinEnter', {
  callback = function() vim.o.cursorline = true end
})

vim.api.nvim_create_autocmd('WinLeave', {
  callback = function() vim.o.cursorline = false end
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

-- Plugins

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
  'tpope/vim-unimpaired',
  { 'tpope/vim-characterize',
    config = function()
      -- This plugin registers key map 'ga', but mini.align also uses that and overrides it.
      -- Instead we set up an alternative keymap:
      vim.keymap.set('n', '<Leader>c', '<Plug>(characterize)')
    end
  },
  'tpope/vim-sleuth',
  'tpope/vim-fugitive',
  'tpope/vim-eunuch',
  { 'echasnovski/mini.align', opts = {}, keys = { 'ga', 'gA' } },
  { 'echasnovski/mini.bufremove', cmd = { 'Bdelete', 'Bwipeout' },
    config = function()
      local bufremove = require 'mini.bufremove'
      bufremove.setup()
      for cmd, func in pairs{Bdelete = 'delete', Bwipeout = 'wipeout'} do
        vim.api.nvim_create_user_command(
          cmd,
          function(opts) bufremove[func](0, opts.bang) end,
          { bang = true })
      end
    end
  },
  { 'jakemason/ouroboros',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<F2>', function() require'ouroboros'.switch() end, ft = { 'c', 'cpp' } },
    }
  },
  { 'kylechui/nvim-surround', version = '*', event = 'VeryLazy', opts = {} },
  { 'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = { use_default_keymaps = false },
    keys = {
      { '<Leader>mm', function() require'treesj'.toggle() end },
      { '<Leader>mj', function() require'treesj'.join() end },
      { '<Leader>ms', function() require'treesj'.split() end },
    },
  },
  { 'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'css',
        'git_config',
        'go',
        'gomod',
        'gosum',
        'gowork',
        'html',
        'javascript',
        'just',
        'lua',
        'markdown',
        'python',
        'rust',
        'sql',
        'vim',
        'vimdoc',
      },
      highlight = { enable = true },
      indent = { enable = true, disable = { 'cpp', 'python' } },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-,>',
          node_incremental = '<C-,>',
          node_decremental = '<C-Backspace>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj
          keymaps = {
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']m'] = '@function.outer',
            [']]'] = '@class.outer',
          },
          goto_next_end = {
            [']M'] = '@function.outer',
            [']['] = '@class.outer',
          },
          goto_previous_start = {
            ['[m'] = '@function.outer',
            ['[['] = '@class.outer',
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            ['[]'] = '@class.outer',
          },
        },
        swap = {
          enable = true,
          swap_next = { ['<Leader>>'] = '@parameter.inner' },
          swap_previous = { ['<Leader><'] = '@parameter.inner' },
        },
        lsp_interop = {
          enable = true,
          peek_definition_code = { ['<Leader>p'] = '@function.outer' },
        },
      },
    }
  },
  'neovim/nvim-lspconfig',
  { 'saghen/blink.cmp',
    version = '1.*',
    opts = {
      keymap = {
        preset = 'enter',
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<Tab>'] = { 'accept', 'snippet_forward', 'fallback' },
      },
      completion = { documentation = { auto_show = true } },
      sources = {
        default = { 'lazydev', 'lsp', 'buffer' },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
      enabled = function() -- Disable if cursor is inside a comment.
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        row = row - 1  -- convert row from 1-based to 0-based; column is already 0-based
        if vim.api.nvim_get_mode().mode:sub(1, 1) == 'i' then
          col = col - 1  -- adjust column in insert mode
        end

        local success, node = pcall(vim.treesitter.get_node, { pos = { row, col } })
        return not (success and node and
            vim.tbl_contains({'comment', 'line_comment', 'block_comment', 'comment_content'}, node:type()))
      end,
    },
  },
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    config = function()
      local telescope = require 'telescope'
      telescope.setup{
        defaults = {
          mappings = {
            i = {
              ['<C-k>'] = 'move_selection_previous',
              ['<C-j>'] = 'move_selection_next',
              ['<Esc>'] = 'close'
            },
          },
        },
      }
      telescope.load_extension('fzf')
      telescope.load_extension('ui-select')
    end,
    keys = {
      { '<C-k>', function() require'telescope.builtin'.buffers() end },
      { '<C-p>', function() require'telescope.builtin'.find_files() end },
      { '<Leader>g', function() require'telescope.builtin'.git_files() end },
      { '<Leader>/', function() require'telescope.builtin'.live_grep() end },
      { '<Leader>*', function() require'telescope.builtin'.grep_string({ word_match = '-w'}) end },
    }
  },
  { 'hedyhli/outline.nvim',
    keys = {
      { "<Leader>o", function() require'outline'.toggle() end },
    },
    opts = {},
  },
  { 'sindrets/diffview.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'nvim-lualine/lualine.nvim', opts = {} },
  { 'ellisonleao/gruvbox.nvim', priority = 1000,
    config = function() vim.cmd.colorscheme 'gruvbox' end },
  'nvim-tree/nvim-web-devicons',
  'Vimjas/vim-python-pep8-indent',
  'Glench/Vim-Jinja2-Syntax',
  { 'folke/lazydev.nvim', ft = 'lua',
    opts = { library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } } } },
  'jvirtanen/vim-hcl',
}

-- Go-specific options

vim.api.nvim_create_autocmd('FileType', {
  pattern = {'go', 'gomod', 'gosum', 'gowork'},
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 4
  end
})

-- C/C++-specific options

vim.api.nvim_create_autocmd('FileType', {
  pattern = {'c', 'cpp'},
  callback = function()
    vim.bo.commentstring = '// %s'  -- default is /*%s*/
  end
})

-- Language Server Protocol (LSP) support

if vim.o.diff then
  -- Don't want LSP in diff mode
  return
end

local on_attach = function(_, bufnr)
  local nmap = function(keys, func)
    vim.keymap.set('n', keys, func, { buffer = bufnr })
  end
  local telescope_builtin = require 'telescope.builtin'

  -- Delete some default keymaps that conflict with our definition of 'gr'.
  for _, key in ipairs({'grn', 'grr', 'gri', 'gra', 'grt'}) do
    pcall(vim.keymap.del, 'n', key)
  end

  nmap('<Leader>r', vim.lsp.buf.rename)
  nmap('<Leader>a', vim.lsp.buf.code_action)

  nmap('gd', telescope_builtin.lsp_definitions)
  nmap('gr', telescope_builtin.lsp_references)
  nmap('gD', vim.lsp.buf.declaration)
  nmap('<Leader>D', telescope_builtin.lsp_type_definitions)
  nmap('gI', telescope_builtin.lsp_implementations)

  nmap('<Leader>k', vim.lsp.buf.signature_help)

  nmap('<Leader>ds', telescope_builtin.lsp_document_symbols)
  nmap('<Leader>ws', telescope_builtin.lsp_dynamic_workspace_symbols)

  nmap('<F3>',  -- Toggle inlay hints
    function()
      local scope = { bufnr = bufnr }
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(scope), scope)
    end)

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, {})
  nmap('<Leader>F', vim.lsp.buf.format)
end

local capabilities = require('blink.cmp').get_lsp_capabilities()

-- Enable some Language Servers

local lss = {
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
  clangd = { },
  pylsp = {
    settings = {
      pylsp = {
        plugins = {
          ruff = { enabled = true, extendIgnore = { 'F405' } }
        }
      }
    },
    before_init = function(_, config)
      if not vim.env.VIRTUAL_ENV and config.root_dir then
        local candidate = config.root_dir .. '/.venv'
        if vim.fn.isdirectory(candidate) == 1 then
          config.settings.pylsp.plugins.jedi = { environment = candidate }
          -- maybe should also set config.settings.python.pythonPath...
        end
      end
    end
  },
  lua_ls = { },
  ts_ls = { },
}

for name, config in pairs(lss) do
  vim.lsp.config(name,
    vim.tbl_extend('keep', config, { on_attach = on_attach, capabilities = capabilities }))
  vim.lsp.enable(name)
end

-- vim: ts=2 sts=2 sw=2 et tw=100
