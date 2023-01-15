-- Based on https://github.com/nvim-lua/kickstart.nvim

-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
  vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'tpope/vim-unimpaired'
  use 'tpope/vim-characterize'
  use 'tpope/vim-sleuth'
  use 'tpope/vim-surround'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-eunuch'
  use 'andymass/vim-matchup'
  use { 'numToStr/Comment.nvim', config = function() require('Comment').setup() end }
  use { 'nvim-treesitter/nvim-treesitter', run = function() pcall(require('nvim-treesitter.install').update { with_sync = true }) end }
  use { 'nvim-treesitter/nvim-treesitter-textobjects', after = 'nvim-treesitter' }
  use 'neovim/nvim-lspconfig'
  use { 'hrsh7th/nvim-cmp',
    requires = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' }
  }
  use { 'nvim-telescope/telescope.nvim', branch = '0.1.x', requires = 'nvim-lua/plenary.nvim' }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }
  use 'nvim-lualine/lualine.nvim'
  use 'ellisonleao/gruvbox.nvim'
  use 'nvim-tree/nvim-web-devicons'
  use 'Vimjas/vim-python-pep8-indent'
  use 'Glench/Vim-Jinja2-Syntax'

  if is_bootstrap then require('packer').sync() end
end)

if is_bootstrap then return end

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | silent! LspStop | silent! LspStart | PackerCompile',
  group = packer_group,
  pattern = vim.fn.expand '$MYVIMRC',
})

-- Options

-- vim.o.hlsearch = false
vim.wo.number = true
vim.o.mouse = 'a'
vim.o.breakindent = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.undofile = true
vim.o.pastetoggle = '<F11>'
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true
vim.o.background = 'dark'
vim.cmd [[colorscheme gruvbox]]

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = vim.fn.expand('~/private') .. '*',
  callback = function() vim.bo.undofile = false end
})

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', "'", '`')
vim.keymap.set('n', ';', ':')
vim.keymap.set('n', 'Q', '<Cmd>qa<CR>')
vim.keymap.set('n', '<Leader>s', [[:%s/\<<C-R><C-W>\>//cg<Left><Left><Left>]])

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank() end,
  group = highlight_group,
  pattern = '*',
})

require('lualine').setup{ options = { theme = 'gruvbox_dark' } }

require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ['<esc>'] = require('telescope.actions').close,
        ['<C-k>'] = require('telescope.actions').move_selection_previous,
        ['<C-j>'] = require('telescope.actions').move_selection_next,
      }
    }
  }
}
require('telescope').load_extension('fzf')
vim.keymap.set('n', '<C-k>', require('telescope.builtin').buffers)
vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files)
vim.keymap.set('n', '<Leader>p', require('telescope.builtin').git_files)
vim.keymap.set('n', '<Leader>g', require('telescope.builtin').live_grep)
vim.keymap.set('n', '<Leader>w', require('telescope.builtin').grep_string)

require('nvim-treesitter.configs').setup {
  ensure_installed = { 'vim', 'help', 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'bash', 'markdown', 'html', 'css', 'javascript' },
  highlight = { enable = true },
  indent = { enable = true, disable = { "python" } },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<C-space>',
      node_incremental = '<C-space>',
      node_decremental = '<C-backspace>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
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
      swap_next = {
        ['<Leader>>'] = '@parameter.inner',
      },
      swap_previous = {
        ['<Leader><'] = '@parameter.inner',
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist)

-- LSP settings.
local on_attach = function(_, bufnr)
  local nmap = function(keys, func)
    vim.keymap.set('n', keys, func, { buffer = bufnr })
  end

  nmap('<Leader>r', vim.lsp.buf.rename)
  nmap('<Leader>a', vim.lsp.buf.code_action)

  nmap('gd', vim.lsp.buf.definition)
  nmap('gD', vim.lsp.buf.declaration)
  nmap('gI', vim.lsp.buf.implementation)
  nmap('gr', require('telescope.builtin').lsp_references)

  nmap('K', vim.lsp.buf.hover)
  nmap('<Leader>k', vim.lsp.buf.signature_help)

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, {})
  -- Also create a keymap for it
  nmap('<Leader>F', vim.lsp.buf.format)
end

-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities(
  vim.lsp.protocol.make_client_capabilities())

-- Enable the following language servers
local lspconfig = require 'lspconfig'
lspconfig.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}
lspconfig.pylsp.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = { enabled = false },
        mccabe = { enabled = false },
        pyflakes = { enabled = false },
        flake8 = { enabled = true },
        black = { enabled = true }
      },
      configurationSources = { 'flake8' }
    }
  },
  before_init = function(_, config)
    if not vim.env.VIRTUAL_ENV then
      local path = require('lspconfig.util').path
      local candidate = path.join(config.root_dir, '.venv')
      if path.is_dir(candidate) then
        config.settings.pylsp.plugins.jedi = { environment = candidate }
        -- maybe should also set config.settings.python.pythonPath...
      end
    end
  end
}

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- vim: ts=2 sts=2 sw=2 et
