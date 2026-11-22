-- Gowise Bespoke Theme 1: Obsidian Void
-- Deep abyss black with electric cyan, vivid purple, and mint green accents

local M = {
  name = "obsidian",
  label = "Gowise Obsidian Void",
  palette = {
    bg = "#090B10",
    bg_subtle = "#0F131A",
    bg_highlight = "#161C26",
    bg_active = "#1E2634",
    fg = "#F0F4FC",
    fg_muted = "#707E94",
    fg_subtle = "#475569",
    border = "#263042",

    -- Syntax Colors
    cyan = "#00E5FF",      -- Keywords & Main Accents
    purple = "#9D4EDD",    -- Types, Classes & Imports
    mint = "#00E676",      -- Strings & Success
    yellow = "#FFD600",    -- Functions & Methods
    orange = "#FF9100",    -- Constants & Numbers
    red = "#FF1744",       -- Errors & Deletions
    comment = "#5C6A7E",   -- Comments (Italic)
    pink = "#FF4081",      -- Preprocessor / Decorators
    blue = "#2979FF",      -- Operators & Brackets

    -- Fluent & Rainbow Elements
    fluent_green = "#00E676",
    rainbow = {
      "#FFD600", -- Level 1: Yellow
      "#9D4EDD", -- Level 2: Purple
      "#00E5FF", -- Level 3: Cyan
      "#FF9100", -- Level 4: Orange
      "#00E676", -- Level 5: Mint
      "#FF4081", -- Level 6: Pink
    },
  },
}

function M.apply()
  local p = M.palette
  local set = vim.api.nvim_set_hl

  vim.cmd("highlight clear")
  vim.g.colors_name = "gowise-obsidian"

  -- Editor Base
  set(0, "Normal", { fg = p.fg, bg = p.bg })
  set(0, "NormalFloat", { fg = p.fg, bg = p.bg_subtle })
  set(0, "FloatBorder", { fg = p.border, bg = p.bg_subtle })
  set(0, "FloatTitle", { fg = p.cyan, bg = p.bg_subtle, bold = true })
  set(0, "Cursor", { fg = p.bg, bg = p.cyan })
  set(0, "CursorLine", { bg = p.bg_subtle })
  set(0, "CursorLineNr", { fg = p.fluent_green, bg = p.bg_subtle, bold = true })
  set(0, "LineNr", { fg = p.fg_subtle, bg = p.bg })
  set(0, "SignColumn", { bg = p.bg })
  set(0, "ColorColumn", { bg = p.bg_subtle })
  set(0, "Visual", { bg = p.bg_active })
  set(0, "VisualNOS", { bg = p.bg_active })
  set(0, "Search", { fg = p.bg, bg = p.yellow })
  set(0, "IncSearch", { fg = p.bg, bg = p.cyan, bold = true })
  set(0, "WinSeparator", { fg = p.border, bg = p.bg })
  set(0, "VertSplit", { fg = p.border, bg = p.bg })

  -- Tabs & Status
  set(0, "StatusLine", { fg = p.fg, bg = p.bg_subtle })
  set(0, "StatusLineNC", { fg = p.fg_muted, bg = p.bg })
  set(0, "TabLine", { fg = p.fg_muted, bg = p.bg })
  set(0, "TabLineSel", { fg = p.cyan, bg = p.bg_subtle, bold = true })
  set(0, "TabLineFill", { bg = p.bg })

  -- Popup & Completion
  set(0, "Pmenu", { fg = p.fg, bg = p.bg_subtle })
  set(0, "PmenuSel", { fg = p.bg, bg = p.cyan, bold = true })
  set(0, "PmenuSbar", { bg = p.bg_highlight })
  set(0, "PmenuThumb", { bg = p.cyan })

  -- Standard Syntax
  set(0, "Comment", { fg = p.comment, italic = true })
  set(0, "Constant", { fg = p.orange })
  set(0, "String", { fg = p.mint })
  set(0, "Character", { fg = p.mint })
  set(0, "Number", { fg = p.orange })
  set(0, "Boolean", { fg = p.orange, bold = true })
  set(0, "Float", { fg = p.orange })
  set(0, "Identifier", { fg = p.fg })
  set(0, "Function", { fg = p.yellow, bold = true })
  set(0, "Statement", { fg = p.cyan, bold = true })
  set(0, "Conditional", { fg = p.cyan, bold = true })
  set(0, "Repeat", { fg = p.cyan, bold = true })
  set(0, "Label", { fg = p.cyan })
  set(0, "Operator", { fg = p.blue })
  set(0, "Keyword", { fg = p.cyan, bold = true })
  set(0, "Exception", { fg = p.red, bold = true })
  set(0, "PreProc", { fg = p.pink })
  set(0, "Type", { fg = p.purple, bold = true })
  set(0, "Structure", { fg = p.purple, bold = true })
  set(0, "Special", { fg = p.blue })
  set(0, "Delimiter", { fg = p.fg_muted })

  -- Tree-sitter Semantics
  set(0, "@variable", { fg = p.fg })
  set(0, "@variable.builtin", { fg = p.pink, bold = true })
  set(0, "@variable.parameter", { fg = p.fg_muted, italic = true })
  set(0, "@function", { fg = p.yellow, bold = true })
  set(0, "@function.builtin", { fg = p.yellow })
  set(0, "@function.method", { fg = p.yellow })
  set(0, "@keyword", { fg = p.cyan, bold = true })
  set(0, "@keyword.return", { fg = p.pink, bold = true })
  set(0, "@type", { fg = p.purple, bold = true })
  set(0, "@type.builtin", { fg = p.purple })
  set(0, "@property", { fg = p.cyan })
  set(0, "@tag", { fg = p.cyan, bold = true })
  set(0, "@tag.attribute", { fg = p.yellow })

  -- Rainbow Delimiters
  for i, col in ipairs(p.rainbow) do
    set(0, "RainbowDelimiter" .. i, { fg = col })
  end

  -- Fluent Line & Active Scope Guides
  set(0, "GowiseActiveLine", { bg = p.bg_subtle })
  set(0, "GowiseFluentGreen", { fg = p.fluent_green, bold = true })
  set(0, "SnacksIndent", { fg = p.border })
  set(0, "SnacksIndentScope", { fg = p.fluent_green })

  -- Diagnostics & Error Lens
  set(0, "DiagnosticError", { fg = p.red })
  set(0, "DiagnosticWarn", { fg = p.yellow })
  set(0, "DiagnosticInfo", { fg = p.cyan })
  set(0, "DiagnosticHint", { fg = p.mint })
  set(0, "DiagnosticVirtualTextError", { fg = p.red, bg = "#2D1016", italic = true })
  set(0, "DiagnosticVirtualTextWarn", { fg = p.yellow, bg = "#2B2411", italic = true })
  set(0, "DiagnosticVirtualTextInfo", { fg = p.cyan, bg = "#102633", italic = true })
  set(0, "DiagnosticVirtualTextHint", { fg = p.mint, bg = "#0E2B1A", italic = true })

  -- Git Gutter Signs
  set(0, "GitSignsAdd", { fg = p.mint })
  set(0, "GitSignsChange", { fg = p.yellow })
  set(0, "GitSignsDelete", { fg = p.red })
end

return M
