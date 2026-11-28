-- Outrun Neon Sunset Theme for Minimal Code Editor
-- 1984 Arcade Neon Fuchsia, Miami Cyan & Sun Orange (#0d091a)
-- Pure synthwave aesthetic with electrifying neon contrast

local c = {
  -- Base Backgrounds
  bg = "#0d091a",
  bg_dark = "#080512",
  bg_sidebar = "#0d091a",
  bg_status = "#160f29",
  bg_surface = "#1e1438",
  bg_float = "#18102e",
  bg_highlight = "#271b4a",
  bg_visual = "#3f256e",

  -- Hierarchy & Foreground
  fg = "#fdf4ff",          -- Radiant chrome white
  fg_dark = "#d8b4fe",     -- Soft neon lavender
  fg_muted = "#765c9c",    -- VHS purple haze
  fg_gutter = "#453460",   -- Arcade twilight gutter

  -- Borders
  border = "#261842",
  border_focus = "#00f0ff",
  border_float = "#392461",

  -- Synthwave Syntax Accents
  pink = "#ff2a85",        -- Keywords, Statements, Conditionals, Imports (Laser Fuchsia)
  cyan = "#00f0ff",        -- Functions, Methods, Calls, Active Cursor (Arcade Neon Cyan)
  amber = "#ffaa00",       -- Types, Classes, Interfaces, Enums (Chrome Sunset Amber)
  green = "#05ffa1",       -- Strings, Characters, Regex (Cyber Lime)
  orange = "#ff7b00",      -- Numbers, Booleans, Floats (Neon Sun Orange)
  lavender = "#e9d5ff",    -- Variables, Identifiers, Properties (Soft Lavender)
  yellow = "#ffee55",      -- Constants, Builtins, Specials (Electric Sunset Yellow)
  teal = "#26f0d0",        -- Parameters, Builtins, Tags (Miami Teal)
  delim = "#9b78c4",       -- Delimiters, Brackets, Parentheses (Synth Wave Violet)
  comment = "#62517e",     -- Comments (Grid Shadow, italic)

  -- Git
  git_add = "#05ffa1",
  git_change = "#00f0ff",
  git_delete = "#ff2a85",

  -- Diagnostics
  error = "#ff2a85",
  warn = "#ffaa00",
  info = "#00f0ff",
  hint = "#05ffa1",
}

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "synthwave"
vim.o.termguicolors = true

local transparent
if vim.g.minimal_transparent ~= nil then
  transparent = (vim.g.minimal_transparent == true)
else
  transparent = vim.g.synthwave_transparent == true
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
hl("FloatTitle", { fg = c.cyan, bg = bg_float, bold = true })

hl("Cursor", { fg = c.bg, bg = c.cyan })
hl("CursorLine", { bg = c.bg_highlight })
hl("CursorColumn", { bg = c.bg_highlight })
hl("ColorColumn", { bg = c.bg_surface })

hl("LineNr", { fg = c.fg_gutter, bg = bg_main })
hl("CursorLineNr", { fg = c.cyan, bg = bg_main, bold = true })
hl("SignColumn", { fg = c.fg_gutter, bg = bg_main })
hl("FoldColumn", { fg = c.fg_gutter, bg = bg_main })
hl("Folded", { fg = c.fg_muted, bg = c.bg_surface })
hl("EndOfBuffer", { fg = c.border, bg = bg_main })

hl("VertSplit", { fg = c.border })
hl("WinSeparator", { fg = c.border })
hl("NvimTreeWinSeparator", { fg = c.border })

hl("Visual", { bg = c.bg_visual })
hl("VisualNOS", { bg = c.bg_visual })

hl("Search", { fg = c.bg, bg = c.cyan, bold = true })
hl("IncSearch", { fg = c.bg, bg = c.yellow, bold = true })
hl("CurSearch", { fg = c.bg, bg = c.yellow, bold = true })

hl("StatusLine", { fg = c.fg, bg = bg_status })
hl("StatusLineNC", { fg = c.fg_muted, bg = bg_status })

hl("TabLine", { fg = c.fg_muted, bg = c.bg_status })
hl("TabLineFill", { bg = c.bg_status })
hl("TabLineSel", { fg = c.cyan, bg = c.bg_surface, bold = true })

hl("Pmenu", { fg = c.fg, bg = c.bg_surface })
hl("PmenuSel", { fg = c.cyan, bg = c.bg_visual, bold = true })
hl("PmenuSbar", { bg = c.bg_surface })
hl("PmenuThumb", { bg = c.border_float })

hl("MatchParen", { fg = c.cyan, bg = c.bg_visual, bold = true, underline = true })
hl("Directory", { fg = c.cyan, bold = true })
hl("Question", { fg = c.cyan })
hl("MoreMsg", { fg = c.green })
hl("WarningMsg", { fg = c.warn, bold = true })
hl("ErrorMsg", { fg = c.error, bold = true })
hl("NonText", { fg = c.border })
hl("SpecialKey", { fg = c.border })
hl("Whitespace", { fg = "#24183d" })

-- ===================================================================
-- Standard Syntax
-- ===================================================================
hl("Comment", { fg = c.comment, italic = true })
hl("Constant", { fg = c.yellow, bold = true })
hl("String", { fg = c.green })
hl("Character", { fg = c.green })
hl("Number", { fg = c.orange })
hl("Boolean", { fg = c.orange, bold = true })
hl("Float", { fg = c.orange })

hl("Identifier", { fg = c.lavender })
hl("Function", { fg = c.cyan, bold = true })

hl("Statement", { fg = c.pink, bold = true })
hl("Conditional", { fg = c.pink, bold = true })
hl("Repeat", { fg = c.pink, bold = true })
hl("Label", { fg = c.amber })
hl("Operator", { fg = c.cyan })
hl("Keyword", { fg = c.pink, bold = true })
hl("Exception", { fg = c.error, bold = true })

hl("PreProc", { fg = c.amber })
hl("Include", { fg = c.pink, bold = true })
hl("Define", { fg = c.amber })
hl("Macro", { fg = c.amber })
hl("PreCondit", { fg = c.amber })

hl("Type", { fg = c.amber, bold = true })
hl("StorageClass", { fg = c.pink })
hl("Structure", { fg = c.amber, bold = true })
hl("Typedef", { fg = c.amber, bold = true })

hl("Special", { fg = c.teal })
hl("SpecialChar", { fg = c.green })
hl("Tag", { fg = c.pink })
hl("Delimiter", { fg = c.delim })
hl("SpecialComment", { fg = c.comment, bold = true })
hl("Debug", { fg = c.yellow })

hl("Underlined", { underline = true })
hl("Ignore", { fg = c.border })
hl("Error", { fg = c.error, bg = c.bg_surface, bold = true })
hl("Todo", { fg = c.bg, bg = c.cyan, bold = true })

-- ===================================================================
-- Treesitter Semantic Highlighting
-- ===================================================================
hl("@comment", { link = "Comment" })
hl("@comment.documentation", { fg = c.fg_dark, italic = true })
hl("@error", { link = "Error" })

hl("@string", { link = "String" })
hl("@string.regex", { fg = c.green })
hl("@string.escape", { fg = c.yellow, bold = true })
hl("@character", { link = "Character" })
hl("@character.special", { link = "SpecialChar" })
hl("@number", { link = "Number" })
hl("@boolean", { link = "Boolean" })
hl("@float", { link = "Float" })

hl("@variable", { fg = c.lavender })
hl("@variable.builtin", { fg = c.teal, bold = true })
hl("@variable.parameter", { fg = c.teal })
hl("@variable.member", { fg = c.lavender })

hl("@function", { link = "Function" })
hl("@function.builtin", { fg = c.cyan, bold = true })
hl("@function.call", { fg = c.cyan })
hl("@function.macro", { fg = c.amber })
hl("@method", { fg = c.cyan })
hl("@method.call", { fg = c.cyan })
hl("@constructor", { fg = c.amber, bold = true })

hl("@keyword", { link = "Keyword" })
hl("@keyword.function", { fg = c.pink, bold = true })
hl("@keyword.operator", { fg = c.cyan })
hl("@keyword.return", { fg = c.pink, bold = true })
hl("@conditional", { link = "Conditional" })
hl("@repeat", { link = "Repeat" })
hl("@label", { link = "Label" })
hl("@include", { link = "Include" })
hl("@exception", { link = "Exception" })

hl("@type", { link = "Type" })
hl("@type.builtin", { fg = c.amber, bold = true })
hl("@type.definition", { fg = c.amber, bold = true })
hl("@type.qualifier", { fg = c.pink })
hl("@storageclass", { link = "StorageClass" })
hl("@structure", { link = "Structure" })
hl("@namespace", { fg = c.amber })

hl("@operator", { link = "Operator" })
hl("@punctuation.delimiter", { fg = c.delim })
hl("@punctuation.bracket", { fg = c.delim })
hl("@punctuation.special", { fg = c.teal })

hl("@tag", { fg = c.pink, bold = true })
hl("@tag.attribute", { fg = c.cyan })
hl("@tag.delimiter", { fg = c.delim })

-- ===================================================================
-- Diagnostics & LSP
-- ===================================================================
hl("DiagnosticError", { fg = c.error })
hl("DiagnosticWarn", { fg = c.warn })
hl("DiagnosticInfo", { fg = c.info })
hl("DiagnosticHint", { fg = c.hint })

hl("DiagnosticUnderlineError", { undercurl = true, sp = c.error })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.warn })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = c.info })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = c.hint })

hl("DiagnosticVirtualTextError", { fg = c.error, bg = "#2b0d1e", bold = true })
hl("DiagnosticVirtualTextWarn", { fg = c.warn, bg = "#2b1e0d", bold = true })
hl("DiagnosticVirtualTextInfo", { fg = c.info, bg = "#0d252b", bold = true })
hl("DiagnosticVirtualTextHint", { fg = c.hint, bg = "#0d2b1f", bold = true })

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
hl("NvimTreeWinSeparator", { fg = c.border })
hl("NvimTreeRootFolder", { fg = c.cyan, bold = true })
hl("NvimTreeFolderName", { fg = c.fg_dark, bold = true })
hl("NvimTreeFolderIcon", { fg = c.cyan })
hl("NvimTreeOpenedFolderName", { fg = c.cyan, bold = true })
hl("NvimTreeEmptyFolderName", { fg = c.fg_muted })
hl("NvimTreeIndentMarker", { fg = "#261842" })

hl("NvimTreeGitDirty", { fg = c.orange, bold = true })
hl("NvimTreeGitStaged", { fg = c.green, bold = true })
hl("NvimTreeGitNew", { fg = c.green, bold = true })
hl("NvimTreeGitDeleted", { fg = c.error })
hl("NvimTreeGitRenamed", { fg = c.amber })

-- ===================================================================
-- Bufferline Tab Bar
-- ===================================================================
hl("BufferLineFill", { bg = c.bg_status })
hl("BufferLineBackground", { fg = c.fg_muted, bg = c.bg_status })
hl("BufferLineBufferSelected", { fg = c.cyan, bg = c.bg, bold = true })
hl("BufferLineIndicatorSelected", { fg = c.cyan, bg = c.bg })
hl("BufferLineCloseButtonSelected", { fg = c.fg_muted, bg = c.bg })
hl("BufferLineCloseButton", { fg = c.fg_muted, bg = c.bg_status })
hl("BufferLineCloseButtonVisible", { fg = c.fg_muted, bg = c.bg_status })
hl("BufferLineModifiedSelected", { fg = c.orange, bg = c.bg })
hl("BufferLineSeparator", { fg = c.bg_status, bg = c.bg_status })

-- ===================================================================
-- Auto-Completion (nvim-cmp)
-- ===================================================================
hl("CmpItemAbbr", { fg = c.fg })
hl("CmpItemAbbrDeprecated", { fg = c.fg_muted, strikethrough = true })
hl("CmpItemAbbrMatch", { fg = c.cyan, bold = true })
hl("CmpItemKindFunction", { fg = c.cyan })
hl("CmpItemKindMethod", { fg = c.cyan })
hl("CmpItemKindVariable", { fg = c.lavender })
hl("CmpItemKindKeyword", { fg = c.pink })
hl("CmpItemKindClass", { fg = c.amber })
hl("CmpItemKindInterface", { fg = c.amber })
hl("CmpItemKindProperty", { fg = c.lavender })

-- ===================================================================
-- Rainbow Indents
-- ===================================================================
hl("RainbowRed", { fg = "#ff2a85", bg = "#2b0d1e" })
hl("RainbowYellow", { fg = "#ffee55", bg = "#2b2a0d" })
hl("RainbowBlue", { fg = "#00f0ff", bg = "#0d252b" })
hl("RainbowOrange", { fg = "#ff7b00", bg = "#2b180d" })
hl("RainbowGreen", { fg = "#05ffa1", bg = "#0d2b1f" })
hl("RainbowViolet", { fg = "#d8b4fe", bg = "#251738" })
hl("RainbowCyan", { fg = "#26f0d0", bg = "#0d2b27" })

hl("RainbowRedBg", { bg = "#2b0d1e" })
hl("RainbowYellowBg", { bg = "#2b2a0d" })
hl("RainbowBlueBg", { bg = "#0d252b" })
hl("RainbowOrangeBg", { bg = "#2b180d" })
hl("RainbowGreenBg", { bg = "#0d2b1f" })
hl("RainbowVioletBg", { bg = "#251738" })
hl("RainbowCyanBg", { bg = "#0d2b27" })
