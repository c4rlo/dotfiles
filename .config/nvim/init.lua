-- Based on: https://github.com/nvim-lua/kickstart.nvim
-- Also worth looking at: https://github.com/VonHeikemen/nvim-starter

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.cursorlineopt = 'number'
vim.o.signcolumn = 'number'
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
vim.o.completeopt = 'menuone,noselect,popup'
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.showmode = false
vim.o.shortmess = 'aoOtTI'
vim.o.diffopt = 'internal,filler,closeoff,linematch:60'

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', "'", '`')
vim.keymap.set('n', ';', ':')
vim.keymap.set('n', 'Q', '<Cmd>qa<CR>')
vim.keymap.set('n', '<Leader>s', [[:%s/\<<C-R><C-W>\>//cg<Left><Left><Left>]])
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist)

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
  callback = function() vim.highlight.on_yank() end
})

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.o.diff then
      for i, win in ipairs(vim.api.nvim_list_wins()) do
        vim.wo[win].relativenumber = false
      end
    end
  end
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'tpope/vim-unimpaired',
  'tpope/vim-characterize',
  'tpope/vim-sleuth',
  'tpope/vim-fugitive',
  'tpope/vim-eunuch',
  { 'jakemason/ouroboros', dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'kylechui/nvim-surround', version = '*', event = 'VeryLazy', opts = {} },
  { 'Wansmer/treesj',
    keys = { '<Leader>mm', '<Leader>mj', '<Leader>ms' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      local treesj = require'treesj'
      treesj.setup{ use_default_keymaps = false }
      vim.keymap.set('n', '<Leader>mm', treesj.toggle)
      vim.keymap.set('n', '<Leader>mj', treesj.join)
      vim.keymap.set('n', '<Leader>ms', treesj.split)
    end
  },
  { 'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    config = function()
      require'nvim-treesitter.configs'.setup{
        ensure_installed = { 'vim', 'vimdoc', 'c', 'cpp', 'go', 'gomod', 'lua', 'python', 'rust', 'bash', 'markdown', 'html', 'css', 'javascript' },
        highlight = { enable = true },
        indent = { enable = true, disable = { 'cpp', 'python' } },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<C-Space>',
            node_incremental = '<C-Space>',
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
            peek_definition_code = { ['<Leader>d'] = '@function.outer' },
          },
        },
      }
    end,
  },
  'neovim/nvim-lspconfig',
  { 'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip',
      { 'rafamadriz/friendly-snippets', config = function() require'luasnip.loaders.from_vscode'.lazy_load() end }
    }
  },
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim', { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' } },
    config = function()
      local telescope = require 'telescope'
      local telescope_builtin = require 'telescope.builtin'
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
      vim.keymap.set('n', '<C-k>', telescope_builtin.buffers)
      vim.keymap.set('n', '<C-p>', telescope_builtin.find_files)
      vim.keymap.set('n', '<Leader>p', telescope_builtin.git_files)
      vim.keymap.set('n', '<Leader>g', telescope_builtin.live_grep)
      vim.keymap.set('n', '<Leader>w', telescope_builtin.grep_string)
    end
  },
  { 'sindrets/diffview.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'nvim-lualine/lualine.nvim', opts = {} },
  { 'ellisonleao/gruvbox.nvim', priority = 1000, config = function() vim.cmd.colorscheme 'gruvbox' end },
  'nvim-tree/nvim-web-devicons',
  'Vimjas/vim-python-pep8-indent',
  'Glench/Vim-Jinja2-Syntax',
  'jvirtanen/vim-hcl',
})

-- Go-specific options
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'go', 'gomod', 'gosum'},
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 4
  end
})

-- C/C++-specific options
local ouroboros = require('ouroboros')
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'c', 'cpp'},
  callback = function()
    vim.bo.commentstring = '// %s'  -- default is /*%s*/
    vim.keymap.set('n', '<F2>', ouroboros.switch, { buffer = true })
  end
})

-- LSP settings.
local on_attach = function(_, bufnr)
  local nmap = function(keys, func)
    vim.keymap.set('n', keys, func, { buffer = bufnr })
  end
  local telescope_builtin = require 'telescope.builtin'

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
  settings = {
    gopls = {
      gofumpt = true
    }
  }
}
lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}
lspconfig.clangd.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}
lspconfig.pylsp.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    pylsp = {
      plugins = {
        black = { enabled = true },
        ruff = { enabled = true }
      }
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
  enabled = function()
    -- https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#disabling-completion-in-certain-contexts-such-as-comments
    if vim.api.nvim_get_mode().mode == 'c' then return true end
    if vim.bo.filetype == 'markdown' then return false end
    local context = require 'cmp.config.context'
    return not context.in_treesitter_capture('comment') and
      not context.in_syntax_group('Comment')
  end,
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = { completeopt = 'menu,menuone,noinsert' },
  mapping = cmp.mapping.preset.insert {
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<CR>'] = cmp.mapping.confirm { select = true },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-,>'] = cmp.mapping(function()
      luasnip.expand()
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- vim: ts=2 sts=2 sw=2 et
