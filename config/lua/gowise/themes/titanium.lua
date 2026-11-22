-- Gowise Bespoke Theme 4: Monolith Titanium
-- Brushed graphite with chilled steel, cobalt blue, and emerald accents

local M = {
  name = "titanium",
  label = "Gowise Monolith Titanium",
  palette = {
    bg = "#121417",
    bg_subtle = "#191C22",
    bg_highlight = "#232832",
    bg_active = "#2E3644",
    fg = "#E2E8F0",
    fg_muted = "#8B95A5",
    fg_subtle = "#4E5866",
    border = "#2D3440",

    blue = "#60A5FA",
    teal = "#2DD4BF",
    emerald = "#10B981",
    amber = "#F59E0B",
    rose = "#F43F5E",
    purple = "#C084FC",
    comment = "#64748B",

    fluent_green = "#10B981",
    rainbow = {
      "#60A5FA", "#C084FC", "#2DD4BF", "#F59E0B", "#10B981", "#F43F5E"
    },
  },
}

function M.apply()
  local p = M.palette
  local set = vim.api.nvim_set_hl

  vim.cmd("highlight clear")
  vim.g.colors_name = "gowise-titanium"

  set(0, "Normal", { fg = p.fg, bg = p.bg })
  set(0, "NormalFloat", { fg = p.fg, bg = p.bg_subtle })
  set(0, "FloatBorder", { fg = p.border, bg = p.bg_subtle })
  set(0, "FloatTitle", { fg = p.blue, bg = p.bg_subtle, bold = true })
  set(0, "CursorLine", { bg = p.bg_subtle })
  set(0, "CursorLineNr", { fg = p.fluent_green, bg = p.bg_subtle, bold = true })
  set(0, "LineNr", { fg = p.fg_subtle, bg = p.bg })
  set(0, "Visual", { bg = p.bg_active })
  set(0, "Search", { fg = p.bg, bg = p.amber })
  set(0, "IncSearch", { fg = p.bg, bg = p.blue, bold = true })
  set(0, "WinSeparator", { fg = p.border, bg = p.bg })

  set(0, "StatusLine", { fg = p.fg, bg = p.bg_subtle })
  set(0, "StatusLineNC", { fg = p.fg_muted, bg = p.bg })
  set(0, "TabLineSel", { fg = p.blue, bg = p.bg_subtle, bold = true })

  set(0, "Comment", { fg = p.comment, italic = true })
  set(0, "String", { fg = p.emerald })
  set(0, "Function", { fg = p.blue, bold = true })
  set(0, "Keyword", { fg = p.purple, bold = true })
  set(0, "Type", { fg = p.teal, bold = true })
  set(0, "Constant", { fg = p.amber })
  set(0, "Operator", { fg = p.blue })

  for i, col in ipairs(p.rainbow) do
    set(0, "RainbowDelimiter" .. i, { fg = col })
  end

  set(0, "SnacksIndent", { fg = p.border })
  set(0, "SnacksIndentScope", { fg = p.fluent_green })
  set(0, "DiagnosticError", { fg = p.rose })
  set(0, "DiagnosticWarn", { fg = p.amber })
  set(0, "DiagnosticInfo", { fg = p.blue })
  set(0, "DiagnosticHint", { fg = p.emerald })
  set(0, "DiagnosticVirtualTextError", { fg = p.rose, bg = "#2B1419", italic = true })
  set(0, "DiagnosticVirtualTextWarn", { fg = p.amber, bg = "#2B210F", italic = true })
end

return M
