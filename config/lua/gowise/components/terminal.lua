-- Gowise Integrated Terminal Drawer (VS Code / Zed Style)
-- Persistent bottom dock with multi-terminal support, isolated shell, and resize controls

local M = {}

M.height = 14
M.terminal_buf = nil
M.terminal_win = nil
M.terminals = {}
M.current_idx = 1

local function get_shell()
  if vim.fn.has("win32") == 1 then
    if vim.fn.executable("pwsh.exe") == 1 then
      return "pwsh.exe -NoLogo"
    elseif vim.fn.executable("powershell.exe") == 1 then
      return "powershell.exe -NoLogo"
    else
      return "cmd.exe"
    end
  else
    local user_shell = os.getenv("SHELL")
    if user_shell and vim.fn.executable(user_shell) == 1 then
      return user_shell
    elseif vim.fn.executable("bash") == 1 then
      return "bash"
    else
      return "sh"
    end
  end
end

function M.create_instance()
  local shell = get_shell()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "terminal"

  local chan_id = vim.fn.jobstart(shell, {
    term = true,
    env = { TERM_PROGRAM = "gowise", GOWISE_TERMINAL = "1" },
  })

  table.insert(M.terminals, { buf = buf, chan_id = chan_id, name = "term-" .. #M.terminals + 1 })
  M.current_idx = #M.terminals
  return buf
end

function M.open()
  if #M.terminals == 0 or not vim.api.nvim_buf_is_valid(M.terminals[M.current_idx].buf) then
    M.create_instance()
  end

  local buf = M.terminals[M.current_idx].buf

  -- Open persistent split at the bottom
  vim.cmd("botright " .. M.height .. "split")
  M.terminal_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(M.terminal_win, buf)

  -- Window options
  vim.wo[M.terminal_win].winfixheight = true
  vim.wo[M.terminal_win].number = false
  vim.wo[M.terminal_win].relativenumber = false
  vim.wo[M.terminal_win].signcolumn = "no"

  vim.cmd("startinsert")
end

function M.close()
  if M.terminal_win and vim.api.nvim_win_is_valid(M.terminal_win) then
    vim.api.nvim_win_close(M.terminal_win, false)
    M.terminal_win = nil
  end
end

function M.toggle()
  if M.terminal_win and vim.api.nvim_win_is_valid(M.terminal_win) then
    M.close()
  else
    M.open()
  end
end

function M.new_instance()
  M.create_instance()
  if M.terminal_win and vim.api.nvim_win_is_valid(M.terminal_win) then
    vim.api.nvim_win_set_buf(M.terminal_win, M.terminals[M.current_idx].buf)
    vim.cmd("startinsert")
  else
    M.open()
  end
end

function M.resize(delta)
  if M.terminal_win and vim.api.nvim_win_is_valid(M.terminal_win) then
    local current_h = vim.api.nvim_win_get_height(M.terminal_win)
    local new_h = math.max(5, current_h + delta)
    vim.api.nvim_win_set_height(M.terminal_win, new_h)
    M.height = new_h
  end
end

function M.setup()
  -- Terminal is ready
end

return M
