-- Gowise Automatic Session & Workspace Persistence Engine
-- Automatically restores the last active workspace, open files, tabs, layout and cursor lines

local M = {}

local state_dir = vim.fn.stdpath("state")
local sessions_dir = state_dir .. "/sessions"
local last_workspace_file = state_dir .. "/last_workspace.txt"
local last_file_path = state_dir .. "/last_file.txt"

local function ensure_state_dirs()
  if vim.fn.isdirectory(sessions_dir) == 0 then
    pcall(vim.fn.mkdir, sessions_dir, "p")
  end
end

function M.get_project_root(path)
  path = path or vim.fn.getcwd()
  local root = vim.fs.root(path, { ".git", "package.json", "go.mod", "Cargo.toml", "Makefile", ".root" })
  if root and root ~= "" and vim.fn.isdirectory(root) == 1 then
    return root
  end
  if vim.fn.isdirectory(path) == 1 then
    return path
  end
  local parent = vim.fs.dirname(path)
  if parent and parent ~= "" and vim.fn.isdirectory(parent) == 1 then
    return parent
  end
  return vim.fn.getcwd()
end

local function get_session_file(dir)
  dir = dir or vim.fn.getcwd()
  local hash = vim.fn.sha256(dir):sub(1, 12)
  local name = vim.fn.fnamemodify(dir, ":t"):gsub("[^%w_]", "_")
  return sessions_dir .. "/" .. name .. "_" .. hash .. ".vim"
end

function M.save_active_location()
  local buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local bt = vim.bo[buf].buftype
  local ft = vim.bo[buf].filetype

  if bt == "" and ft ~= "snacks_dashboard" and buf_name ~= "" then
    if vim.fn.filereadable(buf_name) == 1 then
      pcall(vim.fn.writefile, { buf_name }, last_file_path)
    end
    local root = M.get_project_root(buf_name)
    if root and root ~= "" and vim.fn.isdirectory(root) == 1 then
      pcall(vim.fn.writefile, { root }, last_workspace_file)
    end
  else
    local cwd = vim.fn.getcwd()
    if cwd ~= "" and cwd ~= vim.env.HOME and vim.fn.isdirectory(cwd) == 1 then
      pcall(vim.fn.writefile, { cwd }, last_workspace_file)
    end
  end
end

function M.save()
  ensure_state_dirs()
  M.save_active_location()

  -- Check if there are real modifiable file buffers open
  local has_real_buffers = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      has_real_buffers = true
      break
    end
  end

  if has_real_buffers then
    local session_file = get_session_file(vim.fn.getcwd())
    pcall(function()
      vim.cmd("mksession! " .. vim.fn.fnameescape(session_file))
    end)
    -- Also save global last session
    local global_session = sessions_dir .. "/global_last_session.vim"
    pcall(function()
      vim.cmd("mksession! " .. vim.fn.fnameescape(global_session))
    end)
  end
end

function M.restore()
  ensure_state_dirs()

  -- Only auto-restore when launched without file/directory arguments
  if vim.fn.argc() > 0 then
    return
  end

  local target_dir = nil
  if vim.fn.filereadable(last_workspace_file) == 1 then
    local lines = vim.fn.readfile(last_workspace_file)
    if lines and lines[1] and lines[1]:match("%S") then
      local saved = vim.trim(lines[1])
      if vim.fn.isdirectory(saved) == 1 and saved ~= vim.env.HOME then
        target_dir = saved
      end
    end
  end

  if target_dir and vim.fn.getcwd() ~= target_dir then
    pcall(vim.fn.chdir, target_dir)
  end

  -- Attempt to restore workspace session
  local active_dir = vim.fn.getcwd()
  local session_file = get_session_file(active_dir)
  local global_session = sessions_dir .. "/global_last_session.vim"

  local restored = false
  if vim.fn.filereadable(session_file) == 1 then
    local ok = pcall(function()
      vim.cmd("silent! source " .. vim.fn.fnameescape(session_file))
    end)
    if ok then restored = true end
  elseif vim.fn.filereadable(global_session) == 1 then
    local ok = pcall(function()
      vim.cmd("silent! source " .. vim.fn.fnameescape(global_session))
    end)
    if ok then restored = true end
  end

  -- If session didn't open any buffers, check if last file is available
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  local valid_files = 0
  for _, b in ipairs(bufs) do
    if b.name ~= "" and vim.bo[b.bufnr].buftype == "" then
      valid_files = valid_files + 1
    end
  end

  if valid_files == 0 and vim.fn.filereadable(last_file_path) == 1 then
    local lines = vim.fn.readfile(last_file_path)
    if lines and lines[1] and lines[1]:match("%S") then
      local file = vim.trim(lines[1])
      if vim.fn.filereadable(file) == 1 then
        pcall(vim.cmd, "edit " .. vim.fn.fnameescape(file))
      end
    end
  end
end

function M.setup()
  ensure_state_dirs()
  local session_group = vim.api.nvim_create_augroup("GowiseSession", { clear = true })

  -- Continuously track active workspace & file
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "DirChanged" }, {
    group = session_group,
    callback = function()
      M.save_active_location()
    end,
  })

  -- Auto save on exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = session_group,
    callback = function()
      M.save()
    end,
  })

  -- Run restore immediately if Neovim already loaded, or on VimEnter
  if vim.v.vim_did_enter == 1 then
    M.restore()
  else
    vim.api.nvim_create_autocmd("VimEnter", {
      group = session_group,
      nested = true,
      callback = function()
        M.restore()
      end,
    })
  end
end

return M
