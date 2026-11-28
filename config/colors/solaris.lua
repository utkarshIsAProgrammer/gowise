-- Solaris Amber CRT Theme for Minimal Code Editor
-- Retro-futuristic Apollo mission control & Blade Runner 2049 amber phosphor (#080604)
-- Designed specifically for zero blue-light eye comfort and rich glowing warmth

local c = {
  -- Base Backgrounds
  bg = "#080604",
  bg_dark = "#050302",
  bg_sidebar = "#080604",
  bg_status = "#120d09",
  bg_surface = "#1a130d",
  bg_float = "#140e0a",
  bg_highlight = "#1e150f",
  bg_visual = "#332214",

  -- Hierarchy & Foreground
  fg = "#ffd280",          -- Warm luminous phosphor amber
  fg_dark = "#d49b4b",     -- Secondary warm ochre
  fg_muted = "#805826",    -- Muted smoked bronze
  fg_gutter = "#4d3417",   -- Gutter amber shadow

  -- Borders
  border = "#261a0d",
  border_focus = "#ffaa00",
  border_float = "#382513",

  -- Solaris Syntax Accents
  amber = "#ffaa00",       -- Functions, Methods, Calls, Active Cursor (Amber Laser)
  orange = "#ff7700",      -- Keywords, Statements, Conditionals, Imports (Molten Orange)
  copper = "#ff9e59",      -- Types, Classes, Interfaces, Enums (Warm Terracotta)
  yellow = "#ffea78",      -- Numbers, Booleans, Floats (Sunburst Honey)
  coral = "#ff8566",       -- Strings, Characters, Regex Quotes (Burnt Terracotta)
  gold = "#e5b800",        -- Constants, Builtins, Specials (Golden Solar)
  wheat = "#e6bb85",       -- Variables, Identifiers, Properties (Pale Wheat)
  brass = "#cca052",       -- Parameters, Builtins, Tags (Spun Brass)
  delim = "#99734d",       -- Delimiters, Brackets, Parentheses (Smoked Amber)
  comment = "#7c5635",     -- Comments (Burnt Parchment Shadow, italic)

  -- Git
  git_add = "#ffaa00",
  git_change = "#ffea78",
  git_delete = "#ff5522",

  -- Diagnostics
  error = "#ff5522",
  warn = "#ffaa00",
  info = "#ffea78",
  hint = "#cca052",
}

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "solaris"
vim.o.termguicolors = true

local transparent
if vim.g.minimal_transparent ~= nil then
  transparent = (vim.g.minimal_transparent == true)
else
  transparent = vim.g.solaris_transparent == true
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
hl("FloatTitle", { fg = c.amber, bg = bg_float, bold = true })

hl("Cursor", { fg = c.bg, bg = c.amber })
hl("CursorLine", { bg = c.bg_highlight })
hl("CursorColumn", { bg = c.bg_highlight })
hl("ColorColumn", { bg = c.bg_surface })

hl("LineNr", { fg = c.fg_gutter, bg = bg_main })
hl("CursorLineNr", { fg = c.amber, bg = bg_main, bold = true })
hl("SignColumn", { fg = c.fg_gutter, bg = bg_main })
hl("FoldColumn", { fg = c.fg_gutter, bg = bg_main })
hl("Folded", { fg = c.fg_muted, bg = c.bg_surface })
hl("EndOfBuffer", { fg = c.border, bg = bg_main })

hl("VertSplit", { fg = c.border })
hl("WinSeparator", { fg = c.border })
hl("NvimTreeWinSeparator", { fg = c.border })

hl("Visual", { bg = c.bg_visual })
hl("VisualNOS", { bg = c.bg_visual })

hl("Search", { fg = c.bg, bg = c.amber, bold = true })
hl("IncSearch", { fg = c.bg, bg = c.yellow, bold = true })
hl("CurSearch", { fg = c.bg, bg = c.yellow, bold = true })

hl("StatusLine", { fg = c.fg, bg = bg_status })
hl("StatusLineNC", { fg = c.fg_muted, bg = bg_status })

hl("TabLine", { fg = c.fg_muted, bg = c.bg_status })
hl("TabLineFill", { bg = c.bg_status })
hl("TabLineSel", { fg = c.amber, bg = c.bg_surface, bold = true })

hl("Pmenu", { fg = c.fg, bg = c.bg_surface })
hl("PmenuSel", { fg = c.amber, bg = c.bg_visual, bold = true })
hl("PmenuSbar", { bg = c.bg_surface })
hl("PmenuThumb", { bg = c.border_float })

hl("MatchParen", { fg = c.amber, bg = c.bg_visual, bold = true, underline = true })
hl("Directory", { fg = c.amber, bold = true })
hl("Question", { fg = c.amber })
hl("MoreMsg", { fg = c.yellow })
hl("WarningMsg", { fg = c.warn, bold = true })
hl("ErrorMsg", { fg = c.error, bold = true })
hl("NonText", { fg = c.border })
hl("SpecialKey", { fg = c.border })
hl("Whitespace", { fg = "#21160a" })

-- ===================================================================
-- Standard Syntax
-- ===================================================================
hl("Comment", { fg = c.comment, italic = true })
hl("Constant", { fg = c.gold, bold = true })
hl("String", { fg = c.coral })
hl("Character", { fg = c.coral })
hl("Number", { fg = c.yellow })
hl("Boolean", { fg = c.yellow, bold = true })
hl("Float", { fg = c.yellow })

hl("Identifier", { fg = c.wheat })
hl("Function", { fg = c.amber, bold = true })

hl("Statement", { fg = c.orange, bold = true })
hl("Conditional", { fg = c.orange, bold = true })
hl("Repeat", { fg = c.orange, bold = true })
hl("Label", { fg = c.copper })
hl("Operator", { fg = c.amber })
hl("Keyword", { fg = c.orange, bold = true })
hl("Exception", { fg = c.error, bold = true })

hl("PreProc", { fg = c.copper })
hl("Include", { fg = c.orange, bold = true })
hl("Define", { fg = c.copper })
hl("Macro", { fg = c.copper })
hl("PreCondit", { fg = c.copper })

hl("Type", { fg = c.copper, bold = true })
hl("StorageClass", { fg = c.orange })
hl("Structure", { fg = c.copper, bold = true })
hl("Typedef", { fg = c.copper, bold = true })

hl("Special", { fg = c.brass })
hl("SpecialChar", { fg = c.coral })
hl("Tag", { fg = c.orange })
hl("Delimiter", { fg = c.delim })
hl("SpecialComment", { fg = c.comment, bold = true })
hl("Debug", { fg = c.gold })

hl("Underlined", { underline = true })
hl("Ignore", { fg = c.border })
hl("Error", { fg = c.error, bg = c.bg_surface, bold = true })
hl("Todo", { fg = c.bg, bg = c.amber, bold = true })

-- ===================================================================
-- Treesitter Semantic Highlighting
-- ===================================================================
hl("@comment", { link = "Comment" })
hl("@comment.documentation", { fg = c.fg_dark, italic = true })
hl("@error", { link = "Error" })

hl("@string", { link = "String" })
hl("@string.regex", { fg = c.coral })
hl("@string.escape", { fg = c.yellow, bold = true })
hl("@character", { link = "Character" })
hl("@character.special", { link = "SpecialChar" })
hl("@number", { link = "Number" })
hl("@boolean", { link = "Boolean" })
hl("@float", { link = "Float" })

hl("@variable", { fg = c.wheat })
hl("@variable.builtin", { fg = c.brass, bold = true })
hl("@variable.parameter", { fg = c.brass })
hl("@variable.member", { fg = c.wheat })

hl("@function", { link = "Function" })
hl("@function.builtin", { fg = c.amber, bold = true })
hl("@function.call", { fg = c.amber })
hl("@function.macro", { fg = c.copper })
hl("@method", { fg = c.amber })
hl("@method.call", { fg = c.amber })
hl("@constructor", { fg = c.copper, bold = true })

hl("@keyword", { link = "Keyword" })
hl("@keyword.function", { fg = c.orange, bold = true })
hl("@keyword.operator", { fg = c.amber })
hl("@keyword.return", { fg = c.orange, bold = true })
hl("@conditional", { link = "Conditional" })
hl("@repeat", { link = "Repeat" })
hl("@label", { link = "Label" })
hl("@include", { link = "Include" })
hl("@exception", { link = "Exception" })

hl("@type", { link = "Type" })
hl("@type.builtin", { fg = c.copper, bold = true })
hl("@type.definition", { fg = c.copper, bold = true })
hl("@type.qualifier", { fg = c.orange })
hl("@storageclass", { link = "StorageClass" })
hl("@structure", { link = "Structure" })
hl("@namespace", { fg = c.copper })

hl("@operator", { link = "Operator" })
hl("@punctuation.delimiter", { fg = c.delim })
hl("@punctuation.bracket", { fg = c.delim })
hl("@punctuation.special", { fg = c.brass })

hl("@tag", { fg = c.orange, bold = true })
hl("@tag.attribute", { fg = c.amber })
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

hl("DiagnosticVirtualTextError", { fg = c.error, bg = "#29120c", bold = true })
hl("DiagnosticVirtualTextWarn", { fg = c.warn, bg = "#291d0c", bold = true })
hl("DiagnosticVirtualTextInfo", { fg = c.info, bg = "#29240c", bold = true })
hl("DiagnosticVirtualTextHint", { fg = c.hint, bg = "#211a0c", bold = true })

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
hl("NvimTreeRootFolder", { fg = c.amber, bold = true })
hl("NvimTreeFolderName", { fg = c.fg_dark, bold = true })
hl("NvimTreeFolderIcon", { fg = c.amber })
hl("NvimTreeOpenedFolderName", { fg = c.amber, bold = true })
hl("NvimTreeEmptyFolderName", { fg = c.fg_muted })
hl("NvimTreeIndentMarker", { fg = "#261a0d" })

hl("NvimTreeGitDirty", { fg = c.yellow, bold = true })
hl("NvimTreeGitStaged", { fg = c.amber, bold = true })
hl("NvimTreeGitNew", { fg = c.amber, bold = true })
hl("NvimTreeGitDeleted", { fg = c.error })
hl("NvimTreeGitRenamed", { fg = c.copper })

-- ===================================================================
-- Bufferline Tab Bar
-- ===================================================================
hl("BufferLineFill", { bg = c.bg_status })
hl("BufferLineBackground", { fg = c.fg_muted, bg = c.bg_status })
hl("BufferLineBufferSelected", { fg = c.amber, bg = c.bg, bold = true })
hl("BufferLineIndicatorSelected", { fg = c.amber, bg = c.bg })
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
hl("CmpItemAbbrMatch", { fg = c.amber, bold = true })
hl("CmpItemKindFunction", { fg = c.amber })
hl("CmpItemKindMethod", { fg = c.amber })
hl("CmpItemKindVariable", { fg = c.wheat })
hl("CmpItemKindKeyword", { fg = c.orange })
hl("CmpItemKindClass", { fg = c.copper })
hl("CmpItemKindInterface", { fg = c.copper })
hl("CmpItemKindProperty", { fg = c.wheat })

-- ===================================================================
-- Rainbow Indents
-- ===================================================================
hl("RainbowRed", { fg = "#ff5522", bg = "#29120c" })
hl("RainbowYellow", { fg = "#ffea78", bg = "#29240c" })
hl("RainbowBlue", { fg = "#ffaa00", bg = "#291d0c" })
hl("RainbowOrange", { fg = "#ff7700", bg = "#29160c" })
hl("RainbowGreen", { fg = "#e5b800", bg = "#29210c" })
hl("RainbowViolet", { fg = "#ff9e59", bg = "#261710" })
hl("RainbowCyan", { fg = "#cca052", bg = "#211a0c" })

hl("RainbowRedBg", { bg = "#29120c" })
hl("RainbowYellowBg", { bg = "#29240c" })
hl("RainbowBlueBg", { bg = "#291d0c" })
hl("RainbowOrangeBg", { bg = "#29160c" })
hl("RainbowGreenBg", { bg = "#29210c" })
hl("RainbowVioletBg", { bg = "#261710" })
hl("RainbowCyanBg", { bg = "#211a0c" })
