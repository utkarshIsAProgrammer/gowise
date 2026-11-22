-- Gowise Bespoke Theme 6: Cobalt Nebula
-- Deep cosmic navy with starlit silver, indigo ray, aquamarine, and ruby laser

local M = {
  name = "nebula",
  label = "Gowise Cobalt Nebula",
  palette = {
    bg = "#0A0E1A",
    bg_subtle = "#11182B",
    bg_highlight = "#18223C",
    bg_active = "#233157",
    fg = "#E0E7FF",
    fg_muted = "#7E8FB2",
    fg_subtle = "#425072",
    border = "#263558",

    indigo = "#6366F1",
    cyan = "#06B6D4",
    mint = "#10B981",
    amber = "#F59E0B",
    ruby = "#F43F5E",
    purple = "#A855F7",
    comment = "#5A6C91",

    fluent_green = "#10B981",
    rainbow = {
      "#F59E0B", "#A855F7", "#06B6D4", "#6366F1", "#10B981", "#F43F5E"
    },
  },
}

function M.apply()
  local p = M.palette
  local set = vim.api.nvim_set_hl

  vim.cmd("highlight clear")
  vim.g.colors_name = "gowise-nebula"

  set(0, "Normal", { fg = p.fg, bg = p.bg })
  set(0, "NormalFloat", { fg = p.fg, bg = p.bg_subtle })
  set(0, "FloatBorder", { fg = p.border, bg = p.bg_subtle })
  set(0, "FloatTitle", { fg = p.cyan, bg = p.bg_subtle, bold = true })
  set(0, "CursorLine", { bg = p.bg_subtle })
  set(0, "CursorLineNr", { fg = p.fluent_green, bg = p.bg_subtle, bold = true })
  set(0, "LineNr", { fg = p.fg_subtle, bg = p.bg })
  set(0, "Visual", { bg = p.bg_active })
  set(0, "Search", { fg = p.bg, bg = p.amber })
  set(0, "IncSearch", { fg = p.bg, bg = p.cyan, bold = true })
  set(0, "WinSeparator", { fg = p.border, bg = p.bg })

  set(0, "StatusLine", { fg = p.fg, bg = p.bg_subtle })
  set(0, "StatusLineNC", { fg = p.fg_muted, bg = p.bg })
  set(0, "TabLineSel", { fg = p.cyan, bg = p.bg_subtle, bold = true })

  set(0, "Comment", { fg = p.comment, italic = true })
  set(0, "String", { fg = p.mint })
  set(0, "Function", { fg = p.cyan, bold = true })
  set(0, "Keyword", { fg = p.indigo, bold = true })
  set(0, "Type", { fg = p.purple, bold = true })
  set(0, "Constant", { fg = p.amber })
  set(0, "Operator", { fg = p.cyan })

  for i, col in ipairs(p.rainbow) do
    set(0, "RainbowDelimiter" .. i, { fg = col })
  end

  set(0, "SnacksIndent", { fg = p.border })
  set(0, "SnacksIndentScope", { fg = p.fluent_green })
  set(0, "DiagnosticError", { fg = p.ruby })
  set(0, "DiagnosticWarn", { fg = p.amber })
  set(0, "DiagnosticInfo", { fg = p.cyan })
  set(0, "DiagnosticHint", { fg = p.mint })
  set(0, "DiagnosticVirtualTextError", { fg = p.ruby, bg = "#2B131A", italic = true })
  set(0, "DiagnosticVirtualTextWarn", { fg = p.amber, bg = "#2B210E", italic = true })
end

return M
