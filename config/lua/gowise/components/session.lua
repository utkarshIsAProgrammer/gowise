-- Gowise Automatic Session Persistence Engine
-- Automatically restores open files, tabs, layout and cursor lines on restart

local M = {}

local sessions_dir = vim.fn.stdpath("state") .. "/sessions"

local function get_session_file()
  local cwd = vim.fn.getcwd()
  local hash = vim.fn.sha256(cwd):sub(1, 12)
  local name = vim.fn.fnamemodify(cwd, ":t"):gsub("[^%w_]", "_")
  return sessions_dir .. "/" .. name .. "_" .. hash .. ".vim"
end

function M.save()
  if vim.fn.isdirectory(sessions_dir) == 0 then
    vim.fn.mkdir(sessions_dir, "p")
  end
  local session_file = get_session_file()
  vim.cmd("mksession! " .. vim.fn.fnameescape(session_file))
end

function M.restore()
  local session_file = get_session_file()
  if vim.fn.filereadable(session_file) == 1 and vim.fn.argc() == 0 then
    vim.cmd("silent! source " .. vim.fn.fnameescape(session_file))
  end
end

function M.setup()
  local session_group = vim.api.nvim_create_augroup("GowiseSession", { clear = true })

  -- Auto save on exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = session_group,
    callback = function()
      M.save()
    end,
  })

  -- Auto restore on startup if launched with no arguments (e.g. gowise .)
  vim.api.nvim_create_autocmd("VimEnter", {
    group = session_group,
    nested = true,
    callback = function()
      M.restore()
    end,
  })
end

return M
