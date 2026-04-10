local M = {}

-- GitHb URL for current file / selection

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

  local branch_fut = git_async('symbolic-ref', '--short', 'HEAD')

  local range, commit_fut
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '\22' then  -- \22 = Ctrl-V
    range = { vim.fn.line('.'), vim.fn.line('v') }
    table.sort(range)
    commit_fut = git_async('rev-parse', 'HEAD')
  end

  local branch = branch_fut()
  local remote = git('config', ('branch.%s.remote'):format(branch))
  local base_url = git('remote', 'get-url', remote)
    :gsub('^git@github.com:', 'https://github.com/')
    :gsub('%.git$', '')

  local path = vim.fs.relpath(git_root, vim.api.nvim_buf_get_name(0))
  if range then
    return ('%s/blob/%s/%s#L%d-L%d'):format(base_url, commit_fut(), path, range[1], range[2])
  else
    return ('%s/blob/%s/%s'):format(base_url, branch, path)
  end
end

function M.github_url()
  local ok, result = pcall(github_url_impl)
  if ok then
    return result
  else
    vim.notify(result, vim.log.levels.WARN)
  end
end

-- Switch between .cpp / .h

function M.cpp_switch_header()
  local file = vim.api.nvim_buf_get_name(0)
  local stem, ext = vim.fs.basename(file):match('(.+)%.(%w+)$')
  if not stem then return end

  local suffixes = (ext == 'h' or ext == 'hpp')
      and { 'cpp', 'cxx', 'cc', 'c' }
      or { 'h', 'hpp' }

  local basenames = {}
  for _, s in ipairs(suffixes) do basenames[stem .. '.' .. s] = true end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf)
        and basenames[vim.fs.basename(vim.api.nvim_buf_get_name(buf))] then
      vim.api.nvim_set_current_buf(buf)
      return
    end
  end

  local dir = vim.fs.dirname(file)
  for _, s in ipairs(suffixes) do
    local candidate = dir .. '/' .. stem .. '.' .. s
    if vim.uv.fs_stat(candidate) then
      vim.cmd.edit(candidate)
      return
    end
  end
end

-- Detect if cursor is outside a comment

function M.is_cursor_outside_comment()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1      -- convert row from 1-based to 0-based; column is already 0-based
  if vim.api.nvim_get_mode().mode:sub(1, 1) == 'i' then
    col = col - 1    -- adjust column in insert mode
  end
  local ok, node = pcall(vim.treesitter.get_node, { pos = { row, col } })
  return not (ok and node and
    vim.list_contains(
      { 'comment', 'line_comment', 'block_comment', 'comment_content' }, node:type()))
end

return M

-- vim: ts=2 sts=2 sw=2 et tw=100
