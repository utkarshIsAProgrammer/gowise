-- Minimal Automatic Session & Workspace Persistence Engine
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
  local active_dir = vim.fn.getcwd()
  local session_file = get_session_file(active_dir)
  local global_session = sessions_dir .. "/global_last_session.vim"

  if vim.fn.filereadable(session_file) == 1 then
    pcall(function()
      vim.cmd("silent! source " .. vim.fn.fnameescape(session_file))
    end)
    vim.notify("✓ Workspace session restored", vim.log.levels.INFO, { title = "Minimal" })
  elseif vim.fn.filereadable(global_session) == 1 then
    pcall(function()
      vim.cmd("silent! source " .. vim.fn.fnameescape(global_session))
    end)
    vim.notify("✓ Last session restored", vim.log.levels.INFO, { title = "Minimal" })
  else
    vim.notify("No saved session found for this workspace", vim.log.levels.INFO, { title = "Minimal" })
  end
end

function M.setup()
  ensure_state_dirs()
  local session_group = vim.api.nvim_create_augroup("MinimalSession", { clear = true })

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

  -- User command to restore session on demand
  vim.api.nvim_create_user_command("SessionRestore", function()
    M.restore()
  end, { desc = "Restore last saved workspace session" })
end

return M
