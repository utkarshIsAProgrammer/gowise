-- Gowise Integrated Terminal Drawer (VS Code / Zed Style)
-- Persistent bottom dock with dedicated isolated Bash shell and multi-terminal tabs

local M = {}

M.height = 14

local function get_shell()
  if vim.fn.has("win32") == 1 then
    local git_bash = "C:\\Program Files\\Git\\bin\\bash.exe"
    if vim.fn.filereadable(git_bash) == 1 then
      return git_bash
    elseif vim.fn.executable("bash.exe") == 1 then
      return "bash.exe"
    elseif vim.fn.executable("pwsh.exe") == 1 then
      return "pwsh.exe -NoLogo"
    else
      return "powershell.exe -NoLogo"
    end
  else
    if vim.fn.executable("bash") == 1 then
      return "bash"
    else
      return vim.o.shell
    end
  end
end

function M.toggle()
  if Snacks and Snacks.terminal then
    local shell = get_shell()
    Snacks.terminal.toggle(shell, {
      win = {
        position = "bottom",
        height = M.height,
        border = "top",
      },
      interactive = true,
      env = {
        TERM_PROGRAM = "gowise",
        GOWISE_TERMINAL = "1",
      },
    })
  end
end

function M.new_instance()
  if Snacks and Snacks.terminal then
    local shell = get_shell()
    Snacks.terminal.open(shell, {
      win = {
        position = "bottom",
        height = M.height,
        border = "top",
      },
      interactive = true,
      env = {
        TERM_PROGRAM = "gowise",
        GOWISE_TERMINAL = "1",
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
  -- User command: :Terminal to open/toggle bash terminal drawer
  vim.api.nvim_create_user_command("Terminal", function()
    M.toggle()
  end, { desc = "Toggle Gowise Integrated Bash Terminal" })
end

return M
