-- Minimal VS Code-style Statusline
-- Blazing fast, zero dependencies, pure Lua with cached telemetry

local M = {}

local mode_names = {
  n = "NORMAL",
  i = "INSERT",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  c = "COMMAND",
  t = "TERMINAL",
}

local diag_cache = {}
local lsp_cache = {}

local function update_diag(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return end
  local errors = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
  local warns = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })
  if errors > 0 or warns > 0 then
    local diag_str = " "
    if errors > 0 then diag_str = diag_str .. " 󰅚 " .. errors end
    if warns > 0 then diag_str = diag_str .. " 󰀦 " .. warns end
    diag_cache[bufnr] = diag_str .. " "
  else
    diag_cache[bufnr] = ""
  end
end

local function update_lsp(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return end
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #clients > 0 then
    local client_names = {}
    for _, c in ipairs(clients) do
      table.insert(client_names, c.name)
    end
    lsp_cache[bufnr] = "  " .. table.concat(client_names, ", ") .. " "
  else
    lsp_cache[bufnr] = ""
  end
end

function M.render()
  local bufnr = vim.api.nvim_get_current_buf()
  local mode = mode_names[vim.fn.mode()] or "MINIMAL"

  -- Mode Indicator (Clean pill)
  local parts = { "  " .. mode .. "  " }

  -- Git Branch
  local branch = vim.b[bufnr].gitsigns_head
  if branch and branch ~= "" then
    table.insert(parts, "   " .. branch .. " ")
  end

  -- File Name & Modified status
  local name = vim.fn.expand("%:t")
  if name == "" then name = "[Untitled]" end
  local mod = vim.bo[bufnr].modified and " ●" or ""
  local ro = vim.bo[bufnr].readonly and " 🔒" or ""
  table.insert(parts, "  " .. name .. mod .. ro .. " ")

  -- Diagnostics (Cached)
  local diag_str = diag_cache[bufnr]
  if diag_str == nil then
    update_diag(bufnr)
    diag_str = diag_cache[bufnr] or ""
  end
  if diag_str ~= "" then
    table.insert(parts, diag_str)
  end

  -- Spacer
  table.insert(parts, "%=")

  -- LSP Status (Cached)
  local lsp_str = lsp_cache[bufnr]
  if lsp_str == nil then
    update_lsp(bufnr)
    lsp_str = lsp_cache[bufnr] or ""
  end
  if lsp_str ~= "" then
    table.insert(parts, lsp_str)
  end

  -- Encoding & FileType
  local ft = vim.bo[bufnr].filetype
  if ft ~= "" then
    table.insert(parts, "  " .. ft:upper() .. " ")
  end

  -- Native C Statusline Line & Column tokens (0ms overhead)
  table.insert(parts, "  Ln %l, Col %c  ")

  return table.concat(parts, "")
end

function M.setup()
  vim.opt.statusline = "%!v:lua.require('minimal.ui.statusline').render()"

  local group = vim.api.nvim_create_augroup("MinimalStatuslineCache", { clear = true })
  vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
    group = group,
    callback = function(args)
      update_diag(args.buf)
    end,
  })
  vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
    group = group,
    callback = function(args)
      update_lsp(args.buf)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = group,
    callback = function(args)
      update_diag(args.buf)
      update_lsp(args.buf)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufWipeout" }, {
    group = group,
    callback = function(args)
      diag_cache[args.buf] = nil
      lsp_cache[args.buf] = nil
    end,
  })
end

return M
