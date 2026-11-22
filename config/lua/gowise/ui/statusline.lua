-- Gowise VS Code-style Statusline
-- Blazing fast, zero dependencies, pure Lua

local M = {}

function M.render()
  local bufnr = vim.api.nvim_get_current_buf()
  local mode_names = {
    n = "NORMAL",
    i = "INSERT",
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK",
    c = "COMMAND",
    t = "TERMINAL",
  }
  local mode = mode_names[vim.fn.mode()] or "GOWISE"

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

  -- Diagnostics
  local errors = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
  local warns = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })
  if errors > 0 or warns > 0 then
    local diag_str = " "
    if errors > 0 then diag_str = diag_str .. " 󰅚 " .. errors end
    if warns > 0 then diag_str = diag_str .. " 󰀦 " .. warns end
    table.insert(parts, diag_str .. " ")
  end

  -- Spacer
  table.insert(parts, "%=")

  -- LSP Status
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #clients > 0 then
    local client_names = {}
    for _, c in ipairs(clients) do
      table.insert(client_names, c.name)
    end
    table.insert(parts, "  " .. table.concat(client_names, ", ") .. " ")
  end

  -- Encoding & FileType
  local ft = vim.bo[bufnr].filetype
  if ft ~= "" then
    table.insert(parts, "  " .. ft:upper() .. " ")
  end

  -- Cursor Line & Column
  local line = vim.fn.line(".")
  local col = vim.fn.col(".")
  table.insert(parts, "  Ln " .. line .. ", Col " .. col .. "  ")

  return table.concat(parts, "")
end

function M.setup()
  vim.opt.statusline = "%!v:lua.require('gowise.ui.statusline').render()"
end

return M
