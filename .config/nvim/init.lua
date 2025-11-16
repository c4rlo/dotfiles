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
vim.o.formatoptions = 'tcroqlnj'
vim.o.cinoptions = ':0,l1,g0.5s,h0.5s,N-s,E-s,t0,+2s,(0,u0,w1,W2s,j1'
vim.o.completeopt = 'menuone,noselect,popup,fuzzy'
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.showmode = false
vim.o.shortmess = 'aoOtTI'
vim.o.diffopt = 'internal,filler,closeoff,linematch:60'
vim.o.title = true

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Basic keymaps

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', "'", '`')
vim.keymap.set('n', 'Q', vim.cmd.qa)
vim.keymap.set('n', '<Leader>s', [[:%s/\<<C-R><C-W>\>//cg<Left><Left><Left>]])
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist)

vim.keymap.set('n', '<Leader>np',
  function()
    local path = vim.fn.expand('%')
    vim.fn.setreg('+', path)
    vim.notify('Copied "'..path..'" to system clipboard')
  end)

vim.keymap.set('n', '<Leader>nn',
  function()
    local path = vim.fn.expand('%')
    local git_root = vim.fs.root(0, '.git')
    if git_root then
      local rel_path = vim.fs.relpath(git_root, path)
      if rel_path then path = rel_path end
    end
    vim.fn.setreg('+', path)
    vim.notify('Copied "'..path..'" to system clipboard')
  end)

local function github_url()
  local path = vim.fn.expand('%')
  local file_dir = vim.fs.dirname(path)

  local git_cmds = {
    remote = { 'remote', 'get-url', '--push', 'origin' },
    branch = { 'rev-parse', '--abbrev-ref', 'HEAD' },
    commit = { 'rev-parse', 'HEAD' },
    root   = { 'rev-parse', '--show-toplevel' },
  }
  local git_jobs = {}
  for name, cmd in pairs(git_cmds) do
    git_jobs[name] = vim.system(vim.list_extend({ 'git', '-C', file_dir }, cmd),
      { text = true })
  end
  local error = false
  local git = {}
  for name, job in pairs(git_jobs) do
    local result = job:wait()
    if result.code ~= 0 then
      vim.notify(('Getting git %s: %s'):format(name, result.stderr),
        vim.log.levels.ERROR)
      error = true
    end
    git[name] = result.stdout:gsub('%s+$', '')
  end
  if error then return end

  local repo = git.remote:gsub('git@github.com:', 'https://github.com/'):gsub('%.git$', '')

  local range
  if vim.fn.mode() == 'V' then
    range = { start = vim.fn.line("'<"), finish = vim.fn.line("'>") }
  end

  local ref = range and git.commit or git.branch

  local url = ('%s/blob/%s/%s'):format(repo, ref, vim.fs.relpath(git.root, path))
  if range then
    url = ('%s#L%d-L%d'):format(url, range.start, range.finish)
  end
  return url
end

vim.keymap.set({'n', 'v'}, '<Leader>ng',
  function()
    local url = github_url()
    if url then
      vim.fn.setreg('+', url)
      vim.notify('Copied "'..url..'" to system clipboard')
    end
  end)

vim.keymap.set({'n', 'v'}, '<Leader>nG',
  function()
    vim.system({'runapp', 'firefox', github_url()},
      { stdout = false, stderr = false, detach = true },
      function() end)
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
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
  'tpope/vim-unimpaired',
  { 'tpope/vim-characterize',
    -- This plugin registers key map 'ga', but mini.align also uses that and overrides it.
    -- Instead we set up an alternative keymap:
    keys = { { '<Leader>c', '<Plug>(characterize)' } },
  },
  'tpope/vim-sleuth',
  'tpope/vim-fugitive',
  'tpope/vim-eunuch',
  { 'nvim-mini/mini.align',
    opts = {},
    keys = { { 'ga', mode = { 'n', 'x' } }, { 'gA', mode = { 'n', 'x' } } }
  },
  { 'kylechui/nvim-surround', version = '*', event = 'VeryLazy', opts = {} },
  { 'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'bash',
        'cpp',
        'css',
        'git_config',
        'go',
        'gomod',
        'gosum',
        'gowork',
        'hcl',
        'html',
        'javascript',
        'just',
        'python',
        'rust',
        'sql',
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
          goto_next_start     = { [']m'] = '@function.outer', [']]'] = '@class.outer', },
          goto_next_end       = { [']M'] = '@function.outer', [']['] = '@class.outer', },
          goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer', },
          goto_previous_end   = { ['[M'] = '@function.outer', ['[]'] = '@class.outer', },
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
        default = { 'lazydev', 'lsp' },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },
      enabled = function() -- Disable if cursor is inside a comment.
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        row = row - 1      -- convert row from 1-based to 0-based; column is already 0-based
        if vim.api.nvim_get_mode().mode:sub(1, 1) == 'i' then
          col = col - 1    -- adjust column in insert mode
        end
        local success, node = pcall(vim.treesitter.get_node, { pos = { row, col } })
        return not (success and node and
          vim.tbl_contains(
            { 'comment', 'line_comment', 'block_comment', 'comment_content' }, node:type()))
      end,
    },
  },
  { 'folke/snacks.nvim',
    priority = 1000,
    opts = {
      input = {},
      picker = {
        matcher = {
          frecency = true,
          cwd_bonus = true,
        }
      },
    },
    keys = {
      { '<C-k>',      function() require'snacks.picker'.buffers() end },
      { '<C-p>',      function() require'snacks.picker'.files() end },
      { '<Leader>g',  function() require'snacks.picker'.git_files() end },
      { '<Leader>/',  function() require'snacks.picker'.grep() end },
      { '<Leader>*',  function() require'snacks.picker'.grep_word() end },
      { 'gd',         function() require'snacks.picker'.lsp_definitions() end },
      { 'gr',         function() require'snacks.picker'.lsp_references() end, nowait = true },
      { 'gI',         function() require'snacks.picker'.lsp_implementations() end },
      { '<Leader>D',  function() require'snacks.picker'.lsp_type_definitions() end },
      { '<Leader>ds', function() require'snacks.picker'.lsp_symbols() end },
      { '<Leader>ws', function() require'snacks.picker'.lsp_workspace_symbols() end },
    },
    init = function()
      vim.api.nvim_create_user_command('Bdelete',
        function(opts) require'snacks.bufdelete'.delete({ force = opts.bang }) end,
        { bang = true }
      )
      vim.api.nvim_create_user_command('Bwipeout',
        function(opts) require'snacks.bufdelete'.delete({ wipe = true, force = opts.bang }) end,
        { bang = true }
      )
    end,
  },
  { 'nvim-lualine/lualine.nvim', opts = {} },
  { 'ellisonleao/gruvbox.nvim', priority = 1000,
    config = function() vim.cmd.colorscheme 'gruvbox' end },
  'nvim-tree/nvim-web-devicons',
  'Vimjas/vim-python-pep8-indent',
  'Glench/Vim-Jinja2-Syntax',
  { 'folke/lazydev.nvim', ft = 'lua',
    opts = { library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } } } },
}

-- Go-specific options

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go', 'gomod', 'gosum', 'gowork' },
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 4
  end
})

-- C/C++-specific options

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp' },
  callback = function()
    vim.bo.commentstring = '// %s' -- default is /*%s*/
  end
})

-- lfrc fixup
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lf' },
  callback = function()
    vim.bo.commentstring = '# %s'
  end
})

-- Language Server Protocol (LSP) support

if vim.o.diff or vim.env.NVIM_NO_LSP == '1' then
  -- Don't want LSP in diff mode
  return
end

local function on_attach(_, bufnr)
  local function nmap(keys, func)
    vim.keymap.set('n', keys, func, { buffer = bufnr })
  end

  -- Delete some default keymaps that conflict with our definition of 'gr'.
  for _, key in ipairs({ 'grn', 'grr', 'gri', 'gra', 'grt' }) do
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
  clangd = {},
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
  lua_ls = {},
  ts_ls = {},
}

local lsp_config = {
  on_attach = on_attach,
  capabilities = require('blink.cmp').get_lsp_capabilities()
}

for name, config in pairs(lss) do
  vim.lsp.config(name, vim.tbl_extend('keep', config, lsp_config))
  vim.lsp.enable(name)
end

-- vim: ts=2 sts=2 sw=2 et tw=100
