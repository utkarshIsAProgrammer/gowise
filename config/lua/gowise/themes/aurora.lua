-- Gowise Bespoke Theme 2: Aurora Teal
-- Nordic deep sea with glacier mist, emerald aurora, and starlight amber

local M = {
  name = "aurora",
  label = "Gowise Aurora Teal",
  palette = {
    bg = "#0B151C",
    bg_subtle = "#11202A",
    bg_highlight = "#182D3B",
    bg_active = "#223F52",
    fg = "#E6F1F5",
    fg_muted = "#7B9EA8",
    fg_subtle = "#47616A",
    border = "#264251",

    emerald = "#34D399",   -- Primary Aurora Green
    glacier = "#38BDF8",   -- Functions & Sky Crystal
    orchid = "#F472B6",    -- Keywords & Highlights
    amber = "#FBBF24",     -- Strings & Solar Accents
    coral = "#FB7185",     -- Errors & Warnings
    violet = "#A78BFA",    -- Types & Structures
    comment = "#5C7E8A",

    fluent_green = "#34D399",
    rainbow = {
      "#FBBF24", "#A78BFA", "#38BDF8", "#34D399", "#F472B6", "#FB7185"
    },
  },
}

function M.apply()
  local p = M.palette
  local set = vim.api.nvim_set_hl

  vim.cmd("highlight clear")
  vim.g.colors_name = "gowise-aurora"

  set(0, "Normal", { fg = p.fg, bg = p.bg })
  set(0, "NormalFloat", { fg = p.fg, bg = p.bg_subtle })
  set(0, "FloatBorder", { fg = p.border, bg = p.bg_subtle })
  set(0, "FloatTitle", { fg = p.emerald, bg = p.bg_subtle, bold = true })
  set(0, "CursorLine", { bg = p.bg_subtle })
  set(0, "CursorLineNr", { fg = p.fluent_green, bg = p.bg_subtle, bold = true })
  set(0, "LineNr", { fg = p.fg_subtle, bg = p.bg })
  set(0, "Visual", { bg = p.bg_active })
  set(0, "Search", { fg = p.bg, bg = p.amber })
  set(0, "IncSearch", { fg = p.bg, bg = p.emerald, bold = true })
  set(0, "WinSeparator", { fg = p.border, bg = p.bg })

  set(0, "StatusLine", { fg = p.fg, bg = p.bg_subtle })
  set(0, "StatusLineNC", { fg = p.fg_muted, bg = p.bg })
  set(0, "TabLineSel", { fg = p.emerald, bg = p.bg_subtle, bold = true })

  set(0, "Comment", { fg = p.comment, italic = true })
  set(0, "String", { fg = p.emerald })
  set(0, "Function", { fg = p.glacier, bold = true })
  set(0, "Keyword", { fg = p.orchid, bold = true })
  set(0, "Type", { fg = p.violet, bold = true })
  set(0, "Constant", { fg = p.amber })
  set(0, "Operator", { fg = p.glacier })

  for i, col in ipairs(p.rainbow) do
    set(0, "RainbowDelimiter" .. i, { fg = col })
  end

  set(0, "SnacksIndent", { fg = p.border })
  set(0, "SnacksIndentScope", { fg = p.fluent_green })
  set(0, "DiagnosticError", { fg = p.coral })
  set(0, "DiagnosticWarn", { fg = p.amber })
  set(0, "DiagnosticInfo", { fg = p.glacier })
  set(0, "DiagnosticHint", { fg = p.emerald })
  set(0, "DiagnosticVirtualTextError", { fg = p.coral, bg = "#291519", italic = true })
  set(0, "DiagnosticVirtualTextWarn", { fg = p.amber, bg = "#2B220F", italic = true })
end

return M
