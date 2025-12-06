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

-- Copy path to clipboard / open in GitHub

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
      path = vim.fs.relpath(git_root, path) or path
    end
    vim.fn.setreg('+', path)
    vim.notify('Copied "'..path..'" to system clipboard')
  end)

local function github_url_impl()
  local git_root = vim.fs.root(0, '.git')
  if not git_root then error('Not in a Git repository') end

  local function git_async(...)
    local args = {...}
    local process = vim.system(vim.list_extend({ 'git', '-C', git_root }, args), { text = true })
    return function()
      local result = process:wait()
      if result.code == 0 then
        return result.stdout:gsub('%s+$', '')
      else
        error(('Git: %s: %s'):format(args[1], result.stderr))
      end
    end
  end

  local function git(...)
    return git_async(...)()
  end

  local branch_async = git_async('symbolic-ref', '--short', 'HEAD')

  local range, commit_async
  if vim.fn.mode() == 'V' then
    range = { vim.fn.line('.'), vim.fn.line('v') }
    table.sort(range)
    commit_async = git_async('rev-parse', 'HEAD')
  end

  local branch = branch_async()
  local remote = git('config', ('branch.%s.remote'):format(branch))
  local base_url = git('remote', 'get-url', remote)
    :gsub('^git@github.com:', 'https://github.com/')
    :gsub('%.git$', '')

  local path = vim.fs.relpath(git_root, vim.api.nvim_buf_get_name(0))
  if range then
    return ('%s/blob/%s/%s#L%d-L%d')
      :format(base_url, commit_async(), path, range[1], range[2])
  else
    return ('%s/blob/%s/%s'):format(base_url, branch, path)
  end
end

local function github_url()
  local ok, result = pcall(github_url_impl)
  if ok then
    return result
  else
    vim.notify(result, vim.log.levels.WARN)
  end
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
    local url = github_url()
    if url then
      vim.system({'runapp', '-c', 'Firefox', 'firefox', url},
        { stdout = false, stderr = false, detach = true },
        function() end)
    end
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
    branch = 'main',
    build = ':TSUpdate',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        opts = { move = { set_jumps = true }, },
      },
    },
    init = function()
      local langs_builtin = { 'c', 'lua', 'markdown', 'query', 'vim' }
      local langs_install = { 'bash', 'cpp', 'css', 'git_config', 'go', 'gomod', 'gosum', 'gotmpl',
        'gowork', 'hcl', 'html', 'javascript', 'jinja', 'just', 'make', 'perl', 'python', 'rust',
        'sql' }
      local langs_no_indent = { 'cpp', 'python' }
      local langs_no_move = { 'python' }

      local langs_all = vim.list_extend(vim.list_slice(langs_builtin), langs_install)

      require'nvim-treesitter'.install(langs_install)

      local function buf_set_keymap(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { buffer = true })
      end

      local function ft_callback(ev)
        -- Enable treesitter highlighting.
        vim.treesitter.start()
        -- Enable treesitter indentation.
        if not vim.list_contains(langs_no_indent, ev.match) then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
        -- Add textobject keymaps.
        local select_keymaps = {
          ['aa'] = '@parameter.outer', ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',  ['if'] = '@function.inner',
          ['ac'] = '@class.outer',     ['ic'] = '@class.inner',
        }
        local select_fn = require'nvim-treesitter-textobjects.select'.select_textobject
        for keys, object in pairs(select_keymaps) do
          buf_set_keymap({'x', 'o'}, keys, function() select_fn(object) end)
        end
        -- Add motion keymaps.
        if not vim.list_contains(langs_no_move, ev.match) then
          local move_fns = require'nvim-treesitter-textobjects.move'
          buf_set_keymap({'n', 'x', 'o'}, '[[',
            function() move_fns.goto_previous('@function.outer', 'textobjects') end
          )
          buf_set_keymap({'n', 'x', 'o'}, ']]',
            function() move_fns.goto_next('@function.outer', 'textobjects') end
          )
        end
        -- Add swap keymaps.
        local swap_fns = require'nvim-treesitter-textobjects.swap'
        buf_set_keymap('n', '<Leader><',
          function() swap_fns.swap_previous('@parameter.inner') end
        )
        buf_set_keymap('n', '<Leader>>',
          function() swap_fns.swap_next('@parameter.inner') end
        )
      end

      vim.api.nvim_create_autocmd('FileType', { pattern = langs_all, callback = ft_callback })
    end
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
        local ok, node = pcall(vim.treesitter.get_node, { pos = { row, col } })
        return not (ok and node and
          vim.list_contains(
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
        },
        win = {
          input = {
            keys = {
              ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
            },
          },
        },
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

local function cpp_switch_header()
  local file = vim.api.nvim_buf_get_name(0)
  local stem, ext = file:match('(.+)%.(%w+)$')
  if not stem then return end

  local targets = {}

  if ext == 'h' or ext == 'hpp' then
    targets = { stem .. '.cpp', stem .. '.cxx', stem .. '.cc', stem .. '.c' }
  else
    targets = { stem .. '.h', stem .. '.hpp' }
  end

  for _, candidate in ipairs(targets) do
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == candidate
      then
        vim.api.nvim_set_current_buf(buf)
        return
      end
    end
  end

  for _, candidate in ipairs(targets) do
    if vim.uv.fs_stat(candidate) then
      vim.cmd.edit(candidate)
      return
    end
  end
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp' },
  callback = function()
    vim.keymap.set('n', '<F2>', cpp_switch_header, { buffer = true })
  end,
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
