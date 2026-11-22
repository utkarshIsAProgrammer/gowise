-- Gowise Integrated Terminal Drawer (VS Code / Zed Style)
-- Persistent bottom dock with multi-terminal support, isolated shell, and resize controls

local M = {}

M.height = 14

function M.toggle()
  if Snacks and Snacks.terminal then
    Snacks.terminal.toggle(nil, {
      win = {
        position = "bottom",
        height = M.height,
        border = "top",
      },
    })
  end
end

function M.new_instance()
  if Snacks and Snacks.terminal then
    Snacks.terminal.open(nil, {
      win = {
        position = "bottom",
        height = M.height,
        border = "top",
      },
    })
  end
end

function M.resize(delta)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" or vim.bo[buf].filetype == "snacks_terminal" then
      local h = vim.api.nvim_win_get_height(win)
      local new_h = math.max(5, h + delta)
      vim.api.nvim_win_set_height(win, new_h)
      M.height = new_h
      break
    end
  end
end

function M.setup()
  -- Terminal is ready
end

return M
