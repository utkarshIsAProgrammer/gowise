-- Alien Xenomorph Theme for Minimal Code Editor
-- High-contrast bioluminescent alien acid neon on deep xenomorph void (#060d09)
-- Crafted by indiedev

local c = {
  -- Base Backgrounds
  bg = "#060d09",
  bg_dark = "#030805",
  bg_sidebar = "#060d09",
  bg_status = "#0a160f",
  bg_surface = "#0e1f15",
  bg_float = "#0b1810",
  bg_highlight = "#12261a",
  bg_visual = "#1a3b27",

  -- Hierarchy & Foreground
  fg = "#dcfce7",          -- Luminous pale bio-phosphor
  fg_dark = "#86efac",     -- Secondary bio-mint
  fg_muted = "#4d7c5e",    -- Chitin muted moss
  fg_gutter = "#234e34",   -- Line numbers

  -- Borders
  border = "#132d1d",
  border_focus = "#39ff14",
  border_float = "#1c402a",

  -- Alien Syntax Accents
  lime = "#39ff14",        -- Functions, Methods, Calls, Active Cursor (Acid Lime)
  cyan = "#00f0ff",        -- Keywords, Statements, Conditionals, Imports (Neural Plasma)
  purple = "#b354ff",      -- Types, Classes, Interfaces, Enums (Mutagenic Violet)
  yellow = "#e5ff44",      -- Numbers, Booleans, Floats (Acid Slime Yellow)
  pink = "#ff3366",        -- Strings, Characters, Regex Quotes (Parasite Coral)
  amber = "#ff9900",       -- Constants, Builtins, Specials (Bio-hazard Amber)
  mint = "#00ff88",        -- Variables, Identifiers, Properties (Vivid Alien Emerald)
  teal = "#2ee5c8",        -- Parameters, Builtins, Tags (Aquatic Bio-Teal)
  delim = "#7ea88d",       -- Delimiters, Brackets, Parentheses (Chitin Slate)
  comment = "#477356",     -- Comments (Eerie Swamp Shadow, italic)

  -- Git
  git_add = "#39ff14",
  git_change = "#00f0ff",
  git_delete = "#ff3366",

  -- Diagnostics
  error = "#ff3366",
  warn = "#e5ff44",
  info = "#00f0ff",
  hint = "#2ee5c8",
}

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "alien"
vim.o.termguicolors = true

-- Background transparency configuration
local transparent
if vim.g.minimal_transparent ~= nil then
  transparent = (vim.g.minimal_transparent == true)
else
  transparent = vim.g.alien_transparent == true
end
local bg_main = transparent and "NONE" or c.bg
local bg_sidebar = transparent and "NONE" or c.bg_sidebar
local bg_float = transparent and "NONE" or c.bg_float
local bg_status = transparent and "NONE" or c.bg_status

local hl = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- ===================================================================
-- UI & Editor Basics
-- ===================================================================
hl("Normal", { fg = c.fg, bg = bg_main })
hl("NormalNC", { fg = c.fg, bg = bg_main })
hl("NormalFloat", { fg = c.fg, bg = bg_float })
hl("FloatBorder", { fg = c.border_float, bg = bg_float })
hl("FloatTitle", { fg = c.lime, bg = bg_float, bold = true })

hl("Cursor", { fg = c.bg, bg = c.lime })
hl("CursorLine", { bg = c.bg_highlight })
hl("CursorColumn", { bg = c.bg_highlight })
hl("ColorColumn", { bg = c.bg_surface })

hl("LineNr", { fg = c.fg_gutter, bg = bg_main })
hl("CursorLineNr", { fg = c.lime, bg = bg_main, bold = true })
hl("SignColumn", { fg = c.fg_gutter, bg = bg_main })
hl("FoldColumn", { fg = c.fg_gutter, bg = bg_main })
hl("Folded", { fg = c.fg_muted, bg = c.bg_surface })
hl("EndOfBuffer", { fg = c.border, bg = bg_main })

hl("VertSplit", { fg = "#132d1d" })
hl("WinSeparator", { fg = "#132d1d" })
hl("NvimTreeWinSeparator", { fg = "#132d1d" })

hl("Visual", { bg = c.bg_visual })
hl("VisualNOS", { bg = c.bg_visual })

hl("Search", { fg = c.bg, bg = c.lime, bold = true })
hl("IncSearch", { fg = c.bg, bg = c.yellow, bold = true })
hl("CurSearch", { fg = c.bg, bg = c.yellow, bold = true })

hl("StatusLine", { fg = c.fg, bg = bg_status })
hl("StatusLineNC", { fg = c.fg_muted, bg = bg_status })

hl("TabLine", { fg = c.fg_muted, bg = c.bg_status })
hl("TabLineFill", { bg = c.bg_status })
hl("TabLineSel", { fg = c.lime, bg = c.bg_surface, bold = true })

hl("Pmenu", { fg = c.fg, bg = c.bg_surface })
hl("PmenuSel", { fg = c.lime, bg = c.bg_visual, bold = true })
hl("PmenuSbar", { bg = c.bg_surface })
hl("PmenuThumb", { bg = c.border_float })

hl("MatchParen", { fg = c.lime, bg = c.bg_visual, bold = true, underline = true })
hl("Directory", { fg = c.lime, bold = true })
hl("Question", { fg = c.lime })
hl("MoreMsg", { fg = c.mint })
hl("WarningMsg", { fg = c.warn, bold = true })
hl("ErrorMsg", { fg = c.error, bold = true })
hl("NonText", { fg = c.border })
hl("SpecialKey", { fg = c.border })
hl("Whitespace", { fg = "#163422" })

-- ===================================================================
-- Standard Syntax
-- ===================================================================
hl("Comment", { fg = c.comment, italic = true })
hl("Constant", { fg = c.amber, bold = true })
hl("String", { fg = c.pink })
hl("Character", { fg = c.pink })
hl("Number", { fg = c.yellow })
hl("Boolean", { fg = c.yellow, bold = true })
hl("Float", { fg = c.yellow })

hl("Identifier", { fg = c.mint })
hl("Function", { fg = c.lime, bold = true })

hl("Statement", { fg = c.cyan, bold = true })
hl("Conditional", { fg = c.cyan, bold = true })
hl("Repeat", { fg = c.cyan, bold = true })
hl("Label", { fg = c.purple })
hl("Operator", { fg = c.lime })
hl("Keyword", { fg = c.cyan, bold = true })
hl("Exception", { fg = c.error, bold = true })

hl("PreProc", { fg = c.purple })
hl("Include", { fg = c.cyan, bold = true })
hl("Define", { fg = c.purple })
hl("Macro", { fg = c.purple })
hl("PreCondit", { fg = c.purple })

hl("Type", { fg = c.purple, bold = true })
hl("StorageClass", { fg = c.cyan })
hl("Structure", { fg = c.purple, bold = true })
hl("Typedef", { fg = c.purple, bold = true })

hl("Special", { fg = c.teal })
hl("SpecialChar", { fg = c.pink })
hl("Tag", { fg = c.cyan })
hl("Delimiter", { fg = c.delim })
hl("SpecialComment", { fg = c.comment, bold = true })
hl("Debug", { fg = c.amber })

hl("Underlined", { underline = true })
hl("Ignore", { fg = c.border })
hl("Error", { fg = c.error, bg = c.bg_surface, bold = true })
hl("Todo", { fg = c.bg, bg = c.lime, bold = true })

-- ===================================================================
-- Treesitter Semantic Highlighting
-- ===================================================================
hl("@comment", { link = "Comment" })
hl("@comment.documentation", { fg = c.fg_dark, italic = true })
hl("@error", { link = "Error" })

-- Literals
hl("@string", { link = "String" })
hl("@string.regex", { fg = c.pink })
hl("@string.escape", { fg = c.yellow, bold = true })
hl("@character", { link = "Character" })
hl("@character.special", { link = "SpecialChar" })
hl("@number", { link = "Number" })
hl("@boolean", { link = "Boolean" })
hl("@float", { link = "Float" })

-- Identifiers & Functions
hl("@variable", { fg = c.mint })
hl("@variable.builtin", { fg = c.teal, bold = true })
hl("@variable.parameter", { fg = c.teal })
hl("@variable.member", { fg = c.mint })

hl("@function", { link = "Function" })
hl("@function.builtin", { fg = c.lime, bold = true })
hl("@function.call", { fg = c.lime })
hl("@function.macro", { fg = c.purple })
hl("@method", { fg = c.lime })
hl("@method.call", { fg = c.lime })
hl("@constructor", { fg = c.purple, bold = true })

-- Keywords & Syntax Control
hl("@keyword", { link = "Keyword" })
hl("@keyword.function", { fg = c.cyan, bold = true })
hl("@keyword.operator", { fg = c.lime })
hl("@keyword.return", { fg = c.cyan, bold = true })
hl("@conditional", { link = "Conditional" })
hl("@repeat", { link = "Repeat" })
hl("@label", { link = "Label" })
hl("@include", { link = "Include" })
hl("@exception", { link = "Exception" })

-- Types & Structure
hl("@type", { link = "Type" })
hl("@type.builtin", { fg = c.purple, bold = true })
hl("@type.definition", { fg = c.purple, bold = true })
hl("@type.qualifier", { fg = c.cyan })
hl("@storageclass", { link = "StorageClass" })
hl("@structure", { link = "Structure" })
hl("@namespace", { fg = c.purple })

-- Operators & Punctuation
hl("@operator", { link = "Operator" })
hl("@punctuation.delimiter", { fg = c.delim })
hl("@punctuation.bracket", { fg = c.delim })
hl("@punctuation.special", { fg = c.teal })

-- Tags (HTML, JSX, XML)
hl("@tag", { fg = c.cyan, bold = true })
hl("@tag.attribute", { fg = c.lime })
hl("@tag.delimiter", { fg = c.delim })

-- ===================================================================
-- Diagnostics & LSP Error Lens
-- ===================================================================
hl("DiagnosticError", { fg = c.error })
hl("DiagnosticWarn", { fg = c.warn })
hl("DiagnosticInfo", { fg = c.info })
hl("DiagnosticHint", { fg = c.hint })

hl("DiagnosticUnderlineError", { undercurl = true, sp = c.error })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.warn })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = c.info })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = c.hint })

hl("DiagnosticVirtualTextError", { fg = c.error, bg = "#250d14", bold = true })
hl("DiagnosticVirtualTextWarn", { fg = c.warn, bg = "#25240d", bold = true })
hl("DiagnosticVirtualTextInfo", { fg = c.info, bg = "#0d2125", bold = true })
hl("DiagnosticVirtualTextHint", { fg = c.hint, bg = "#0d251e", bold = true })

-- ===================================================================
-- Git Signs
-- ===================================================================
hl("GitSignsAdd", { fg = c.git_add })
hl("GitSignsChange", { fg = c.git_change })
hl("GitSignsDelete", { fg = c.git_delete })

-- ===================================================================
-- NvimTree File Sidebar
-- ===================================================================
hl("NvimTreeNormal", { fg = c.fg, bg = bg_main })
hl("NvimTreeNormalNC", { fg = c.fg, bg = bg_main })
hl("NvimTreeEndOfBuffer", { fg = c.border, bg = bg_main })
hl("NvimTreeWinSeparator", { fg = "#132d1d" })
hl("NvimTreeRootFolder", { fg = c.lime, bold = true })
hl("NvimTreeFolderName", { fg = c.fg_dark, bold = true })
hl("NvimTreeFolderIcon", { fg = c.lime })
hl("NvimTreeOpenedFolderName", { fg = c.lime, bold = true })
hl("NvimTreeEmptyFolderName", { fg = c.fg_muted })
hl("NvimTreeIndentMarker", { fg = "#163422" })

hl("NvimTreeGitDirty", { fg = c.yellow, bold = true })
hl("NvimTreeGitStaged", { fg = c.lime, bold = true })
hl("NvimTreeGitNew", { fg = c.lime, bold = true })
hl("NvimTreeGitDeleted", { fg = c.error })
hl("NvimTreeGitRenamed", { fg = c.purple })

-- ===================================================================
-- Bufferline Tab Bar
-- ===================================================================
hl("BufferLineFill", { bg = c.bg_status })
hl("BufferLineBackground", { fg = c.fg_muted, bg = c.bg_status })
hl("BufferLineBufferSelected", { fg = c.lime, bg = c.bg, bold = true })
hl("BufferLineIndicatorSelected", { fg = c.lime, bg = c.bg })
hl("BufferLineCloseButtonSelected", { fg = c.fg_muted, bg = c.bg })
hl("BufferLineCloseButton", { fg = c.fg_muted, bg = c.bg_status })
hl("BufferLineCloseButtonVisible", { fg = c.fg_muted, bg = c.bg_status })
hl("BufferLineModifiedSelected", { fg = c.yellow, bg = c.bg })
hl("BufferLineSeparator", { fg = c.bg_status, bg = c.bg_status })

-- ===================================================================
-- Auto-Completion (nvim-cmp)
-- ===================================================================
hl("CmpItemAbbr", { fg = c.fg })
hl("CmpItemAbbrDeprecated", { fg = c.fg_muted, strikethrough = true })
hl("CmpItemAbbrMatch", { fg = c.lime, bold = true })
hl("CmpItemKindFunction", { fg = c.lime })
hl("CmpItemKindMethod", { fg = c.lime })
hl("CmpItemKindVariable", { fg = c.mint })
hl("CmpItemKindKeyword", { fg = c.cyan })
hl("CmpItemKindClass", { fg = c.purple })
hl("CmpItemKindInterface", { fg = c.purple })
hl("CmpItemKindProperty", { fg = c.mint })

-- ===================================================================
-- Rainbow Indents
-- ===================================================================
hl("RainbowRed", { fg = "#ff3366", bg = "#250d14" })
hl("RainbowYellow", { fg = "#e5ff44", bg = "#25240d" })
hl("RainbowBlue", { fg = "#00f0ff", bg = "#0d2125" })
hl("RainbowOrange", { fg = "#ff9900", bg = "#25180d" })
hl("RainbowGreen", { fg = "#39ff14", bg = "#0d2512" })
hl("RainbowViolet", { fg = "#b354ff", bg = "#1c0d25" })
hl("RainbowCyan", { fg = "#2ee5c8", bg = "#0d2522" })

hl("RainbowRedBg", { bg = "#250d14" })
hl("RainbowYellowBg", { bg = "#25240d" })
hl("RainbowBlueBg", { bg = "#0d2125" })
hl("RainbowOrangeBg", { bg = "#25180d" })
hl("RainbowGreenBg", { bg = "#0d2512" })
hl("RainbowVioletBg", { bg = "#1c0d25" })
hl("RainbowCyanBg", { bg = "#0d2522" })
