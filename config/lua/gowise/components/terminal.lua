-- Gowise Integrated Terminal Drawer (VS Code / Zed Style)
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

function M.get_target_dir()
  local buf = vim.api.nvim_get_current_buf()
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
  if Snacks and Snacks.terminal then
    M.sync_height()

    local shell = get_shell()
    local target_dir = M.get_target_dir()
    local term = Snacks.terminal.toggle(shell, {
      cwd = target_dir,
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

    if term and term.buf and vim.api.nvim_buf_is_valid(term.buf) then
      local chan = vim.b[term.buf].terminal_job_id
      local current_term_cwd = vim.b[term.buf].gowise_term_cwd
      if chan and current_term_cwd and current_term_cwd ~= target_dir then
        pcall(vim.api.nvim_chan_send, chan, string.format(" cd %q && clear\r", target_dir))
        vim.b[term.buf].gowise_term_cwd = target_dir
      elseif chan and not current_term_cwd then
        vim.b[term.buf].gowise_term_cwd = target_dir
      end
    end

    if term and term.opts then
      term.opts.height = M.height
      term.opts.cwd = target_dir
    end

    vim.schedule(function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) then
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].buftype == "terminal" or vim.bo[buf].filetype == "snacks_terminal" or vim.b[buf].snacks_terminal then
            if vim.api.nvim_win_get_height(win) ~= M.height then
              pcall(vim.api.nvim_win_set_height, win, M.height)
            end
            break
          end
        end
      end
    end)
  end
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
      },
      interactive = true,
      env = {
        TERM_PROGRAM = "gowise",
        GOWISE_TERMINAL = "1",
      },
    })
    if term and term.opts then
      term.opts.height = M.height
      term.opts.cwd = target_dir
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

  -- Autocommand to track any resize (mouse drag, :resize, split adjustments)
  vim.api.nvim_create_autocmd("WinResized", {
    group = vim.api.nvim_create_augroup("GowiseTerminalResize", { clear = true }),
    callback = function()
      M.sync_height()
    end,
  })

  -- User command: :Terminal to open/toggle bash terminal drawer
  vim.api.nvim_create_user_command("Terminal", function()
    M.toggle()
  end, { desc = "Toggle Gowise Integrated Bash Terminal" })
end

return M
