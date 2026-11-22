-- Minimal Integrated Terminal Drawer (VS Code / Zed Style)
-- Persistent bottom dock with dedicated isolated Bash shell, remembered height, and multi-terminal tabs

local M = {}

local state_file = vim.fn.stdpath("state") .. "/terminal_state.json"

local function load_saved_height()
  local f = io.open(state_file, "r")
  if f then
    local content = f:read("*a")
    f:close()
    local ok, data = pcall(vim.json.decode, content)
    if ok and data and data.height and type(data.height) == "number" and data.height >= 4 then
      return data.height
    end
  end
  return 14
end

local function save_height(height)
  pcall(function()
    vim.fn.mkdir(vim.fs.dirname(state_file), "p")
    local f = io.open(state_file, "w")
    if f then
      f:write(vim.json.encode({ height = height }))
      f:close()
    end
  end)
end

M.height = load_saved_height()

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

-- Sync M.height with active terminal windows and Snacks terminal instances
function M.sync_height()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == "terminal" or vim.bo[buf].filetype == "snacks_terminal" or vim.b[buf].snacks_terminal then
        local h = vim.api.nvim_win_get_height(win)
        if h >= 4 then
          M.height = h
          save_height(h)
        end
        break
      end
    end
  end

  if Snacks and Snacks.terminal then
    for _, term in ipairs(Snacks.terminal.list()) do
      if term and term.opts then
        term.opts.height = M.height
      end
    end
  end
end

M.current_term = nil

function M.get_target_dir()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype == "terminal" or vim.bo[buf].filetype == "snacks_terminal" or vim.b[buf].snacks_terminal then
    if vim.b[buf].minimal_term_cwd and vim.b[buf].minimal_term_cwd ~= "" then
      return vim.b[buf].minimal_term_cwd
    end
    return vim.fn.getcwd()
  end

  local buf_name = vim.api.nvim_buf_get_name(buf)
  if buf_name and buf_name ~= "" then
    local path = vim.fs.normalize(buf_name)
    if vim.fn.isdirectory(path) == 1 then
      return path
    end
    local root = vim.fs.root(path, { ".git", "package.json", "go.mod", "Cargo.toml", "Makefile", ".root" })
    if root and root ~= "" and vim.fn.isdirectory(root) == 1 then
      return root
    end
    local parent = vim.fs.dirname(path)
    if parent and parent ~= "" and vim.fn.isdirectory(parent) == 1 then
      return parent
    end
  end

  local cwd = vim.fn.getcwd()
  local root = vim.fs.root(cwd, { ".git", "package.json", "go.mod", "Cargo.toml", "Makefile", ".root" })
  if root and root ~= "" and vim.fn.isdirectory(root) == 1 then
    return root
  end
  return cwd
end

function M.toggle()
  pcall(vim.fn.mkdir, vim.fn.stdpath("cache") .. "/luac", "p")
  if not (Snacks and Snacks.terminal) then
    return
  end

  M.sync_height()

  -- Check if any terminal window is currently visible in active tabpage
  local visible_terms = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == "terminal" or vim.bo[buf].filetype == "snacks_terminal" or vim.b[buf].snacks_terminal then
        table.insert(visible_terms, { win = win, buf = buf })
      end
    end
  end

  -- If any terminal is currently open and visible: HIDE IT (Single drawer toggle)
  if #visible_terms > 0 then
    if M.current_term and M.current_term:valid() then
      M.current_term:hide()
    end
    for _, item in ipairs(visible_terms) do
      if vim.api.nvim_win_is_valid(item.win) then
        pcall(vim.api.nvim_win_close, item.win, false)
      end
    end
    return
  end

  -- Terminal is closed/hidden: open or reveal the existing terminal instance
  local shell = get_shell()
  local target_dir = M.get_target_dir()

  if M.current_term and M.current_term:buf_valid() then
    M.current_term:show():focus()
    if M.current_term.win and vim.api.nvim_win_is_valid(M.current_term.win) then
      pcall(vim.api.nvim_win_set_height, M.current_term.win, M.height)
    end
    local chan = vim.b[M.current_term.buf].terminal_job_id
    local current_term_cwd = vim.b[M.current_term.buf].minimal_term_cwd
    if chan and current_term_cwd and current_term_cwd ~= target_dir then
      pcall(vim.api.nvim_chan_send, chan, string.format(" cd %q && clear\r", target_dir))
      vim.b[M.current_term.buf].minimal_term_cwd = target_dir
    elseif chan and not current_term_cwd then
      vim.b[M.current_term.buf].minimal_term_cwd = target_dir
    end
    return
  end

  -- Create brand new terminal instance
  local term = Snacks.terminal.get(shell, {
    cwd = target_dir,
    win = {
      position = "bottom",
      height = M.height,
      border = "top",
      wo = {
        winhighlight = "Normal:SnacksNormal,NormalNC:SnacksNormalNC,WinBar:SnacksWinBar,WinBarNC:SnacksWinBarNC,FloatTitle:SnacksTitle,FloatFooter:SnacksFooter,WinSeparator:SnacksWinSeparator,StatusLine:StatusLineTerm,StatusLineNC:StatusLineTermNC",
      },
    },
    interactive = true,
    env = {
      TERM_PROGRAM = "minimal",
      MINIMAL_TERMINAL = "1",
    },
  })

  M.current_term = term

  if term and not term:valid() then
    term:show():focus()
  elseif term and term:valid() then
    term:focus()
  end

  if term and term.buf and vim.api.nvim_buf_is_valid(term.buf) then
    vim.b[term.buf].minimal_term_cwd = target_dir
  end

  vim.schedule(function()
    if term and term.win and vim.api.nvim_win_is_valid(term.win) then
      pcall(vim.api.nvim_win_set_height, term.win, M.height)
    end
  end)
end

function M.new_instance()
  if Snacks and Snacks.terminal then
    M.sync_height()
    local shell = get_shell()
    local target_dir = M.get_target_dir()
    local term = Snacks.terminal.open(shell, {
      cwd = target_dir,
      win = {
        position = "bottom",
        height = M.height,
        border = "top",
        wo = {
          winhighlight = "Normal:SnacksNormal,NormalNC:SnacksNormalNC,WinBar:SnacksWinBar,WinBarNC:SnacksWinBarNC,FloatTitle:SnacksTitle,FloatFooter:SnacksFooter,WinSeparator:SnacksWinSeparator,StatusLine:StatusLineTerm,StatusLineNC:StatusLineTermNC",
        },
      },
      interactive = true,
      env = {
        TERM_PROGRAM = "minimal",
        MINIMAL_TERMINAL = "1",
      },
    })
    M.current_term = term
    if term and term.buf and vim.api.nvim_buf_is_valid(term.buf) then
      vim.b[term.buf].minimal_term_cwd = target_dir
    end
  end
end

function M.resize(delta)
  local found = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == "terminal" or vim.bo[buf].filetype == "snacks_terminal" or vim.b[buf].snacks_terminal then
        local h = vim.api.nvim_win_get_height(win)
        local new_h = math.max(4, h + delta)
        vim.api.nvim_win_set_height(win, new_h)
        M.height = new_h
        save_height(new_h)
        found = true
        break
      end
    end
  end

  if Snacks and Snacks.terminal then
    for _, term in ipairs(Snacks.terminal.list()) do
      if term and term.opts then
        term.opts.height = M.height
      end
    end
  end

  return found
end

function M.setup()
  pcall(vim.fn.mkdir, vim.fn.stdpath("cache") .. "/luac", "p")
  pcall(require, "snacks.win")
  pcall(require, "snacks.terminal")

  -- Autocommand to ensure all terminal windows strictly inherit editor background
  vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("MinimalTermColors", { clear = true }),
    callback = function()
      pcall(function()
        vim.wo.winhighlight = "Normal:SnacksNormal,NormalNC:SnacksNormalNC,WinBar:SnacksWinBar,WinBarNC:SnacksWinBarNC,FloatTitle:SnacksTitle,FloatFooter:SnacksFooter,WinSeparator:SnacksWinSeparator,StatusLine:StatusLineTerm,StatusLineNC:StatusLineTermNC"
      end)
    end,
  })

  -- Autocommand to track any resize (mouse drag, :resize, split adjustments)
  vim.api.nvim_create_autocmd("WinResized", {
    group = vim.api.nvim_create_augroup("MinimalTerminalResize", { clear = true }),
    callback = function()
      M.sync_height()
    end,
  })

  -- User command: :Terminal to open/toggle bash terminal drawer
  vim.api.nvim_create_user_command("Terminal", function()
    M.toggle()
  end, { desc = "Toggle Minimal Integrated Bash Terminal" })

  -- User command: :TerminalNew to create a new instance
  vim.api.nvim_create_user_command("TerminalNew", function()
    M.new_instance()
  end, { desc = "Open New Minimal Bash Terminal Instance" })
end

return M
