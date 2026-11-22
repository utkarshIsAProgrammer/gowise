-- Gowise Bespoke Theme 5: Velvet Espresso
-- Roasted mocha with warm milk, tangerine flame, and soft amethyst

local M = {
  name = "espresso",
  label = "Gowise Velvet Espresso",
  palette = {
    bg = "#141115",
    bg_subtle = "#1E1A20",
    bg_highlight = "#2A242C",
    bg_active = "#3A323D",
    fg = "#FDF4E7",
    fg_muted = "#9E908D",
    fg_subtle = "#5F5452",
    border = "#3D343A",

    tangerine = "#FB923C",
    amethyst = "#E879F9",
    lime = "#A3E635",
    topaz = "#38BDF8",
    rose = "#FB7185",
    amber = "#FBBF24",
    comment = "#7C7074",

    fluent_green = "#A3E635",
    rainbow = {
      "#FBBF24", "#E879F9", "#38BDF8", "#FB923C", "#A3E635", "#FB7185"
    },
  },
}

function M.apply()
  local p = M.palette
  local set = vim.api.nvim_set_hl

  vim.cmd("highlight clear")
  vim.g.colors_name = "gowise-espresso"

  set(0, "Normal", { fg = p.fg, bg = p.bg })
  set(0, "NormalFloat", { fg = p.fg, bg = p.bg_subtle })
  set(0, "FloatBorder", { fg = p.border, bg = p.bg_subtle })
  set(0, "FloatTitle", { fg = p.tangerine, bg = p.bg_subtle, bold = true })
  set(0, "CursorLine", { bg = p.bg_subtle })
  set(0, "CursorLineNr", { fg = p.fluent_green, bg = p.bg_subtle, bold = true })
  set(0, "LineNr", { fg = p.fg_subtle, bg = p.bg })
  set(0, "Visual", { bg = p.bg_active })
  set(0, "Search", { fg = p.bg, bg = p.amber })
  set(0, "IncSearch", { fg = p.bg, bg = p.tangerine, bold = true })
  set(0, "WinSeparator", { fg = p.border, bg = p.bg })

  set(0, "StatusLine", { fg = p.fg, bg = p.bg_subtle })
  set(0, "StatusLineNC", { fg = p.fg_muted, bg = p.bg })
  set(0, "TabLineSel", { fg = p.tangerine, bg = p.bg_subtle, bold = true })

  set(0, "Comment", { fg = p.comment, italic = true })
  set(0, "String", { fg = p.lime })
  set(0, "Function", { fg = p.topaz, bold = true })
  set(0, "Keyword", { fg = p.amethyst, bold = true })
  set(0, "Type", { fg = p.tangerine, bold = true })
  set(0, "Constant", { fg = p.amber })
  set(0, "Operator", { fg = p.topaz })

  for i, col in ipairs(p.rainbow) do
    set(0, "RainbowDelimiter" .. i, { fg = col })
  end

  set(0, "SnacksIndent", { fg = p.border })
  set(0, "SnacksIndentScope", { fg = p.fluent_green })
  set(0, "DiagnosticError", { fg = p.rose })
  set(0, "DiagnosticWarn", { fg = p.amber })
  set(0, "DiagnosticInfo", { fg = p.topaz })
  set(0, "DiagnosticHint", { fg = p.lime })
  set(0, "DiagnosticVirtualTextError", { fg = p.rose, bg = "#2B161B", italic = true })
  set(0, "DiagnosticVirtualTextWarn", { fg = p.amber, bg = "#2B220F", italic = true })
end

return M
