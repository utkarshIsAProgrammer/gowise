-- Cyber Sakura Noir Theme for Minimal Code Editor
-- Velvet Nocturnal Plum & Blooming Cherry Blossom Neon (#0c0712)
-- Inspired by Neo-Tokyo nocturnal gardens under neon streetlamps

local c = {
  -- Base Backgrounds
  bg = "#0c0712",
  bg_dark = "#07040a",
  bg_sidebar = "#0c0712",
  bg_status = "#150d1f",
  bg_surface = "#1e132c",
  bg_float = "#170e22",
  bg_highlight = "#261838",
  bg_visual = "#3b2357",

  -- Hierarchy & Foreground
  fg = "#fce7f3",          -- Pale cherry petal white
  fg_dark = "#f472b6",     -- Vivid sakura pink
  fg_muted = "#7e528a",    -- Withered plum
  fg_gutter = "#46284f",   -- Twilight gutter

  -- Borders
  border = "#261533",
  border_focus = "#f472b6",
  border_float = "#371f4a",

  -- Sakura Syntax Accents
  sakura = "#f472b6",      -- Functions, Methods, Calls, Active Cursor (Neon Sakura)
  magenta = "#ec4899",     -- Keywords, Statements, Conditionals, Imports (Electric Magenta)
  wisteria = "#c084fc",    -- Types, Classes, Interfaces, Enums (Imperial Wisteria)
  gold = "#fbbf24",        -- Numbers, Booleans, Floats (Cherry Stamen Gold)
  petal = "#fbcfe8",       -- Strings, Characters, Regex (Soft Petal)
  jade = "#34d399",        -- Variables, Identifiers, Properties (Bonsai Jade)
  lilac = "#e879f9",       -- Constants, Builtins, Specials (Vivid Lilac)
  peach = "#fda4af",       -- Parameters, Builtins, Tags (Blossom Peach)
  delim = "#a3759e",       -- Delimiters, Brackets, Parentheses (Dusk Rose)
  comment = "#6b4375",     -- Comments (Plum Shadow, italic)

  -- Git
  git_add = "#34d399",
  git_change = "#f472b6",
  git_delete = "#fb7185",

  -- Diagnostics
  error = "#fb7185",
  warn = "#fbbf24",
  info = "#c084fc",
  hint = "#34d399",
}

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "sakura"
vim.o.termguicolors = true

local transparent
if vim.g.minimal_transparent ~= nil then
  transparent = (vim.g.minimal_transparent == true)
else
  transparent = vim.g.sakura_transparent == true
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
hl("FloatTitle", { fg = c.sakura, bg = bg_float, bold = true })

hl("Cursor", { fg = c.bg, bg = c.sakura })
hl("CursorLine", { bg = c.bg_highlight })
hl("CursorColumn", { bg = c.bg_highlight })
hl("ColorColumn", { bg = c.bg_surface })

hl("LineNr", { fg = c.fg_gutter, bg = bg_main })
hl("CursorLineNr", { fg = c.sakura, bg = bg_main, bold = true })
hl("SignColumn", { fg = c.fg_gutter, bg = bg_main })
hl("FoldColumn", { fg = c.fg_gutter, bg = bg_main })
hl("Folded", { fg = c.fg_muted, bg = c.bg_surface })
hl("EndOfBuffer", { fg = c.border, bg = bg_main })

hl("VertSplit", { fg = c.border })
hl("WinSeparator", { fg = c.border })
hl("NvimTreeWinSeparator", { fg = c.border })

hl("Visual", { bg = c.bg_visual })
hl("VisualNOS", { bg = c.bg_visual })

hl("Search", { fg = c.bg, bg = c.sakura, bold = true })
hl("IncSearch", { fg = c.bg, bg = c.gold, bold = true })
hl("CurSearch", { fg = c.bg, bg = c.gold, bold = true })

hl("StatusLine", { fg = c.fg, bg = bg_status })
hl("StatusLineNC", { fg = c.fg_muted, bg = bg_status })

hl("TabLine", { fg = c.fg_muted, bg = c.bg_status })
hl("TabLineFill", { bg = c.bg_status })
hl("TabLineSel", { fg = c.sakura, bg = c.bg_surface, bold = true })

hl("Pmenu", { fg = c.fg, bg = c.bg_surface })
hl("PmenuSel", { fg = c.sakura, bg = c.bg_visual, bold = true })
hl("PmenuSbar", { bg = c.bg_surface })
hl("PmenuThumb", { bg = c.border_float })

hl("MatchParen", { fg = c.sakura, bg = c.bg_visual, bold = true, underline = true })
hl("Directory", { fg = c.sakura, bold = true })
hl("Question", { fg = c.sakura })
hl("MoreMsg", { fg = c.jade })
hl("WarningMsg", { fg = c.warn, bold = true })
hl("ErrorMsg", { fg = c.error, bold = true })
hl("NonText", { fg = c.border })
hl("SpecialKey", { fg = c.border })
hl("Whitespace", { fg = "#20102b" })

-- ===================================================================
-- Standard Syntax
-- ===================================================================
hl("Comment", { fg = c.comment, italic = true })
hl("Constant", { fg = c.lilac, bold = true })
hl("String", { fg = c.petal })
hl("Character", { fg = c.petal })
hl("Number", { fg = c.gold })
hl("Boolean", { fg = c.gold, bold = true })
hl("Float", { fg = c.gold })

hl("Identifier", { fg = c.jade })
hl("Function", { fg = c.sakura, bold = true })

hl("Statement", { fg = c.magenta, bold = true })
hl("Conditional", { fg = c.magenta, bold = true })
hl("Repeat", { fg = c.magenta, bold = true })
hl("Label", { fg = c.wisteria })
hl("Operator", { fg = c.sakura })
hl("Keyword", { fg = c.magenta, bold = true })
hl("Exception", { fg = c.error, bold = true })

hl("PreProc", { fg = c.wisteria })
hl("Include", { fg = c.magenta, bold = true })
hl("Define", { fg = c.wisteria })
hl("Macro", { fg = c.wisteria })
hl("PreCondit", { fg = c.wisteria })

hl("Type", { fg = c.wisteria, bold = true })
hl("StorageClass", { fg = c.magenta })
hl("Structure", { fg = c.wisteria, bold = true })
hl("Typedef", { fg = c.wisteria, bold = true })

hl("Special", { fg = c.peach })
hl("SpecialChar", { fg = c.petal })
hl("Tag", { fg = c.magenta })
hl("Delimiter", { fg = c.delim })
hl("SpecialComment", { fg = c.comment, bold = true })
hl("Debug", { fg = c.lilac })

hl("Underlined", { underline = true })
hl("Ignore", { fg = c.border })
hl("Error", { fg = c.error, bg = c.bg_surface, bold = true })
hl("Todo", { fg = c.bg, bg = c.sakura, bold = true })

-- ===================================================================
-- Treesitter Semantic Highlighting
-- ===================================================================
hl("@comment", { link = "Comment" })
hl("@comment.documentation", { fg = c.fg_dark, italic = true })
hl("@error", { link = "Error" })

hl("@string", { link = "String" })
hl("@string.regex", { fg = c.petal })
hl("@string.escape", { fg = c.gold, bold = true })
hl("@character", { link = "Character" })
hl("@character.special", { link = "SpecialChar" })
hl("@number", { link = "Number" })
hl("@boolean", { link = "Boolean" })
hl("@float", { link = "Float" })

hl("@variable", { fg = c.jade })
hl("@variable.builtin", { fg = c.peach, bold = true })
hl("@variable.parameter", { fg = c.peach })
hl("@variable.member", { fg = c.jade })

hl("@function", { link = "Function" })
hl("@function.builtin", { fg = c.sakura, bold = true })
hl("@function.call", { fg = c.sakura })
hl("@function.macro", { fg = c.wisteria })
hl("@method", { fg = c.sakura })
hl("@method.call", { fg = c.sakura })
hl("@constructor", { fg = c.wisteria, bold = true })

hl("@keyword", { link = "Keyword" })
hl("@keyword.function", { fg = c.magenta, bold = true })
hl("@keyword.operator", { fg = c.sakura })
hl("@keyword.return", { fg = c.magenta, bold = true })
hl("@conditional", { link = "Conditional" })
hl("@repeat", { link = "Repeat" })
hl("@label", { link = "Label" })
hl("@include", { link = "Include" })
hl("@exception", { link = "Exception" })

hl("@type", { link = "Type" })
hl("@type.builtin", { fg = c.wisteria, bold = true })
hl("@type.definition", { fg = c.wisteria, bold = true })
hl("@type.qualifier", { fg = c.magenta })
hl("@storageclass", { link = "StorageClass" })
hl("@structure", { link = "Structure" })
hl("@namespace", { fg = c.wisteria })

hl("@operator", { link = "Operator" })
hl("@punctuation.delimiter", { fg = c.delim })
hl("@punctuation.bracket", { fg = c.delim })
hl("@punctuation.special", { fg = c.peach })

hl("@tag", { fg = c.magenta, bold = true })
hl("@tag.attribute", { fg = c.sakura })
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

hl("DiagnosticVirtualTextError", { fg = c.error, bg = "#2b0f1a", bold = true })
hl("DiagnosticVirtualTextWarn", { fg = c.warn, bg = "#2b210f", bold = true })
hl("DiagnosticVirtualTextInfo", { fg = c.info, bg = "#230f2b", bold = true })
hl("DiagnosticVirtualTextHint", { fg = c.hint, bg = "#0f2b1d", bold = true })

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
hl("NvimTreeRootFolder", { fg = c.sakura, bold = true })
hl("NvimTreeFolderName", { fg = c.fg_dark, bold = true })
hl("NvimTreeFolderIcon", { fg = c.sakura })
hl("NvimTreeOpenedFolderName", { fg = c.sakura, bold = true })
hl("NvimTreeEmptyFolderName", { fg = c.fg_muted })
hl("NvimTreeIndentMarker", { fg = "#261533" })

hl("NvimTreeGitDirty", { fg = c.gold, bold = true })
hl("NvimTreeGitStaged", { fg = c.jade, bold = true })
hl("NvimTreeGitNew", { fg = c.jade, bold = true })
hl("NvimTreeGitDeleted", { fg = c.error })
hl("NvimTreeGitRenamed", { fg = c.wisteria })

-- ===================================================================
-- Bufferline Tab Bar
-- ===================================================================
hl("BufferLineFill", { bg = c.bg_status })
hl("BufferLineBackground", { fg = c.fg_muted, bg = c.bg_status })
hl("BufferLineBufferSelected", { fg = c.sakura, bg = c.bg, bold = true })
hl("BufferLineIndicatorSelected", { fg = c.sakura, bg = c.bg })
hl("BufferLineCloseButtonSelected", { fg = c.fg_muted, bg = c.bg })
hl("BufferLineCloseButton", { fg = c.fg_muted, bg = c.bg_status })
hl("BufferLineCloseButtonVisible", { fg = c.fg_muted, bg = c.bg_status })
hl("BufferLineModifiedSelected", { fg = c.gold, bg = c.bg })
hl("BufferLineSeparator", { fg = c.bg_status, bg = c.bg_status })

-- ===================================================================
-- Auto-Completion (nvim-cmp)
-- ===================================================================
hl("CmpItemAbbr", { fg = c.fg })
hl("CmpItemAbbrDeprecated", { fg = c.fg_muted, strikethrough = true })
hl("CmpItemAbbrMatch", { fg = c.sakura, bold = true })
hl("CmpItemKindFunction", { fg = c.sakura })
hl("CmpItemKindMethod", { fg = c.sakura })
hl("CmpItemKindVariable", { fg = c.jade })
hl("CmpItemKindKeyword", { fg = c.magenta })
hl("CmpItemKindClass", { fg = c.wisteria })
hl("CmpItemKindInterface", { fg = c.wisteria })
hl("CmpItemKindProperty", { fg = c.jade })

-- ===================================================================
-- Rainbow Indents
-- ===================================================================
hl("RainbowRed", { fg = "#fb7185", bg = "#2b0f1a" })
hl("RainbowYellow", { fg = "#fbbf24", bg = "#2b210f" })
hl("RainbowBlue", { fg = "#c084fc", bg = "#230f2b" })
hl("RainbowOrange", { fg = "#f472b6", bg = "#2b1022" })
hl("RainbowGreen", { fg = "#34d399", bg = "#0f2b1d" })
hl("RainbowViolet", { fg = "#e879f9", bg = "#290f2b" })
hl("RainbowCyan", { fg = "#fda4af", bg = "#2b1219" })

hl("RainbowRedBg", { bg = "#2b0f1a" })
hl("RainbowYellowBg", { bg = "#2b210f" })
hl("RainbowBlueBg", { bg = "#230f2b" })
hl("RainbowOrangeBg", { bg = "#2b1022" })
hl("RainbowGreenBg", { bg = "#0f2b1d" })
hl("RainbowVioletBg", { bg = "#290f2b" })
hl("RainbowCyanBg", { bg = "#2b1219" })
