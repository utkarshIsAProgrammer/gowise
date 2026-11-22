-- Gowise Docked Sidebar File Tree
-- Fixed, predictable explorer that stays open until toggled (VS Code / Zed standard)

local M = {}

M.tree_win = nil
M.tree_buf = nil
M.width = 32

function M.toggle()
  -- Check if snacks picker explorer is available
  if Snacks and Snacks.explorer then
    Snacks.explorer()
    return
  end

  -- Fallback native docked file list
  if M.tree_win and vim.api.nvim_win_is_valid(M.tree_win) then
    vim.api.nvim_win_close(M.tree_win, false)
    M.tree_win = nil
  else
    vim.cmd("topleft " .. M.width .. "vsplit")
    M.tree_win = vim.api.nvim_get_current_win()
    vim.wo[M.tree_win].winfixwidth = true
    vim.wo[M.tree_win].number = false
    vim.wo[M.tree_win].relativenumber = false
    vim.wo[M.tree_win].signcolumn = "no"
    vim.cmd("edit .")
  end
end

function M.setup()
  -- Docked tree ready
end

return M
