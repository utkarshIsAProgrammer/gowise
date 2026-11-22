-- Gowise Multi-Language Interactive Code Runner (F5 Engine)
-- Fast, persistent bottom output console with interactive stdin and zero disappearing output

local M = {}

M.runner_buf = nil
M.runner_win = nil
M.current_job = nil
M.height = 14

local function get_run_command()
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")
  local fname = vim.fn.expand("%:t")

  if ft == "go" then
    if vim.fn.filereadable(dir .. "/go.mod") == 1 then
      return "go run ."
    else
      return "go run " .. vim.fn.shellescape(file)
    end
  elseif ft == "python" then
    return (vim.fn.executable("python3") == 1 and "python3" or "python") .. " " .. vim.fn.shellescape(file)
  elseif ft == "typescript" or ft == "typescriptreact" then
    if vim.fn.executable("bun") == 1 then
      return "bun " .. vim.fn.shellescape(file)
    elseif vim.fn.executable("tsx") == 1 then
      return "npx tsx " .. vim.fn.shellescape(file)
    else
      return "npx ts-node " .. vim.fn.shellescape(file)
    end
  elseif ft == "javascript" or ft == "javascriptreact" then
    if vim.fn.executable("node") == 1 then
      return "node " .. vim.fn.shellescape(file)
    else
      return "bun " .. vim.fn.shellescape(file)
    end
  elseif ft == "rust" then
    if vim.fn.filereadable(dir .. "/Cargo.toml") == 1 or vim.fn.filereadable(dir .. "/../Cargo.toml") == 1 then
      return "cargo run"
    else
      return "rustc " .. vim.fn.shellescape(file) .. " -o /tmp/rust_bin && /tmp/rust_bin"
    end
  elseif ft == "c" then
    return "gcc -O2 " .. vim.fn.shellescape(file) .. " -o /tmp/c_bin && /tmp/c_bin"
  elseif ft == "cpp" then
    return "g++ -std=c++20 -O2 " .. vim.fn.shellescape(file) .. " -o /tmp/cpp_bin && /tmp/cpp_bin"
  elseif ft == "sh" or ft == "bash" then
    return "bash " .. vim.fn.shellescape(file)
  elseif ft == "lua" then
    return "nvim -l " .. vim.fn.shellescape(file)
  end

  return nil
end

function M.run()
  local cmd = get_run_command()
  if not cmd then
    vim.notify("No runner configured for filetype: " .. vim.bo.filetype, vim.log.levels.WARN, { title = "Gowise Runner" })
    return
  end

  -- Auto-save current file
  vim.cmd("silent! write")

  -- Close existing runner window if open
  if M.runner_win and vim.api.nvim_win_is_valid(M.runner_win) then
    vim.api.nvim_win_close(M.runner_win, false)
  end

  -- Open bottom split for execution
  vim.cmd("botright " .. M.height .. "split")
  M.runner_win = vim.api.nvim_get_current_win()
  vim.wo[M.runner_win].winfixheight = true
  vim.wo[M.runner_win].number = false
  vim.wo[M.runner_win].signcolumn = "no"

  -- Create clean terminal buffer
  M.runner_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(M.runner_win, M.runner_buf)

  local start_time = vim.uv.hrtime()
  local file_label = vim.fn.expand("%:t")

  -- Execution command wrapped with timing banner
  local wrapper_cmd = string.format(
    'printf "\\033[1;36m▶ Running %s...\\033[0m\\n\\n" && (%s); code=$?; printf "\\n\\033[1;32m✔ Process finished with exit code $code\\033[0m\\n"',
    file_label, cmd
  )

  M.current_job = vim.fn.jobstart({ "bash", "-c", wrapper_cmd }, {
    term = true,
    on_exit = function(_, exit_code)
      M.current_job = nil
    end,
  })

  vim.cmd("startinsert")
end

function M.stop()
  if M.current_job then
    vim.fn.jobstop(M.current_job)
    M.current_job = nil
    vim.notify("Execution terminated.", vim.log.levels.INFO, { title = "Gowise Runner" })
  end
end

function M.setup()
  -- Runner ready
end

return M
