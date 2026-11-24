-- ===================================================================
-- Crimson Nocturne Theme for Minimal Code Editor
-- Gothic Black Velvet, Mahogany Crypt, Dragon's Blood Ruby & Antique Silver
-- Handcrafted by indiedev
-- ===================================================================

local c = {
  -- Base Backgrounds
  bg = "#0b0709",
  bg_dark = "#070406",
  bg_sidebar = "#0b0709",
  bg_status = "#110b0e",
  bg_surface = "#191015",
  bg_float = "#1e131a",
  bg_highlight = "#271822",
  bg_visual = "#3d2235",

  -- Hierarchy & Foreground
  fg = "#e2d9dd",
  fg_dark = "#b59fad",
  fg_muted = "#7d6575",
  fg_gutter = "#4a3643",

  -- Borders
  border = "#271721",
  border_focus = "#e63946",
  border_float = "#382130",

  -- Syntax Tokens
  fn = "#e09f3e",
  type = "#b56576",
  kw = "#e63946",
  str = "#70c1b3",
  const = "#ff9f1c",
  op = "#c08497",
  preproc = "#9d4edd",
  var = "#dfd3d9",
  comment = "#78596b",

  -- Git
  git_add = "#70c1b3",
  git_change = "#e09f3e",
  git_delete = "#e63946",

  -- Diagnostics
  error = "#e63946",
  warn = "#ff9f1c",
  info = "#c08497",
  hint = "#70c1b3",

  -- Diagnostic Backgrounds
  diag_err_bg = "#291114",
  diag_warn_bg = "#281b10",
  diag_info_bg = "#22141f",
  diag_hint_bg = "#12201e",
}

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "nocturne"
vim.o.termguicolors = true

-- Background transparency configuration
local transparent
if vim.g.minimal_transparent ~= nil then
  transparent = (vim.g.minimal_transparent == true)
else
  transparent = vim.g.nocturne_transparent ~= false
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
hl("FloatTitle", { fg = c.fn, bg = bg_float, bold = true })

hl("Cursor", { fg = c.bg, bg = c.fn })
hl("CursorLine", { bg = c.bg_highlight })
hl("CursorColumn", { bg = c.bg_highlight })
hl("ColorColumn", { bg = c.bg_surface })

hl("LineNr", { fg = c.fg_gutter, bg = bg_main })
hl("CursorLineNr", { fg = c.fn, bg = bg_main, bold = true })
hl("SignColumn", { fg = c.fg_gutter, bg = bg_main })
hl("FoldColumn", { fg = c.fg_gutter, bg = bg_main })
hl("Folded", { fg = c.fg_muted, bg = c.bg_surface })
hl("EndOfBuffer", { fg = c.border, bg = bg_main })

hl("VertSplit", { fg = "#2d3139" })
hl("WinSeparator", { fg = "#2d3139" })

hl("Visual", { bg = c.bg_visual })
hl("VisualNOS", { bg = c.bg_visual })

hl("Search", { fg = c.bg, bg = c.fn, bold = true })
hl("IncSearch", { fg = c.bg, bg = c.const, bold = true })
hl("CurSearch", { fg = c.bg, bg = c.const, bold = true })

hl("StatusLine", { fg = c.fg, bg = bg_status })
hl("StatusLineNC", { fg = c.fg_muted, bg = bg_status })

hl("TabLine", { fg = c.fg_muted, bg = bg_status })
hl("TabLineFill", { bg = bg_status })
hl("TabLineSel", { fg = c.fn, bg = c.bg_surface, bold = true })

hl("Pmenu", { fg = c.fg, bg = c.bg_surface })
hl("PmenuSel", { fg = c.fn, bg = c.bg_visual, bold = true })
hl("PmenuSbar", { bg = c.bg_surface })
hl("PmenuThumb", { bg = c.border_float })

hl("MatchParen", { fg = c.fn, bg = c.bg_visual, bold = true, underline = true })
hl("Directory", { fg = c.type, bold = true })
hl("Question", { fg = c.fn })
hl("MoreMsg", { fg = c.fn })
hl("ModeMsg", { fg = c.fn, bold = true })
hl("WarningMsg", { fg = c.warn, bold = true })
hl("ErrorMsg", { fg = c.error, bold = true })
hl("Title", { fg = c.fn, bold = true })
hl("Conceal", { fg = c.fg_muted })
hl("NonText", { fg = c.fg_gutter })
hl("SpecialKey", { fg = c.fg_gutter })
hl("Whitespace", { fg = c.border })

-- ===================================================================
-- Standard Vim Syntax Highlighting
-- ===================================================================
hl("Comment", { fg = c.comment, italic = true })

hl("Constant", { fg = c.const })
hl("String", { fg = c.str })
hl("Character", { fg = c.str })
hl("Number", { fg = c.const })
hl("Boolean", { fg = c.const, bold = true })
hl("Float", { fg = c.const })

hl("Identifier", { fg = c.var })
hl("Function", { fg = c.fn, bold = true })

hl("Statement", { fg = c.kw, bold = true })
hl("Conditional", { fg = c.kw, bold = true })
hl("Repeat", { fg = c.kw, bold = true })
hl("Label", { fg = c.kw })
hl("Operator", { fg = c.op })
hl("Keyword", { fg = c.kw, bold = true })
hl("Exception", { fg = c.kw, bold = true })

hl("PreProc", { fg = c.preproc })
hl("Include", { fg = c.kw, bold = true })
hl("Define", { fg = c.preproc })
hl("Macro", { fg = c.preproc })
hl("PreCondit", { fg = c.preproc })

hl("Type", { fg = c.type, bold = true })
hl("StorageClass", { fg = c.kw })
hl("Structure", { fg = c.type, bold = true })
hl("Typedef", { fg = c.type })

hl("Special", { fg = c.const })
hl("SpecialChar", { fg = c.const })
hl("Tag", { fg = c.kw })
hl("Delimiter", { fg = c.op })
hl("SpecialComment", { fg = c.fn, italic = true })
hl("Debug", { fg = c.kw })

hl("Underlined", { underline = true })
hl("Bold", { bold = true })
hl("Italic", { italic = true })
hl("Ignore", { fg = c.fg_muted })
hl("Error", { fg = c.error, bg = c.bg_surface, bold = true })
hl("Todo", { fg = c.bg, bg = c.fn, bold = true })

-- ===================================================================
-- Tree-sitter Standard & Extended Groups
-- ===================================================================
hl("@variable", { fg = c.var })
hl("@variable.builtin", { fg = c.type, italic = true })
hl("@variable.parameter", { fg = c.var })
hl("@variable.member", { fg = c.var })

hl("@constant", { fg = c.const })
hl("@constant.builtin", { fg = c.const, bold = true })
hl("@constant.macro", { fg = c.const })

hl("@module", { fg = c.type })
hl("@label", { fg = c.kw })

hl("@string", { fg = c.str })
hl("@string.regex", { fg = c.const })
hl("@string.escape", { fg = c.type, bold = true })
hl("@string.special", { fg = c.const })
hl("@character", { fg = c.str })
hl("@character.special", { fg = c.type })

hl("@number", { fg = c.const })
hl("@number.float", { fg = c.const })
hl("@boolean", { fg = c.const, bold = true })

hl("@function", { fg = c.fn, bold = true })
hl("@function.builtin", { fg = c.fn })
hl("@function.call", { fg = c.fn })
hl("@function.macro", { fg = c.fn })
hl("@function.method", { fg = c.fn })
hl("@constructor", { fg = c.type, bold = true })

hl("@operator", { fg = c.op })

hl("@keyword", { fg = c.kw, bold = true })
hl("@keyword.function", { fg = c.kw, bold = true })
hl("@keyword.operator", { fg = c.kw })
hl("@keyword.import", { fg = c.kw, bold = true })
hl("@keyword.return", { fg = c.kw, bold = true })
hl("@keyword.conditional", { fg = c.kw, bold = true })
hl("@keyword.repeat", { fg = c.kw, bold = true })
hl("@keyword.exception", { fg = c.kw, bold = true })

hl("@punctuation.delimiter", { fg = c.op })
hl("@punctuation.bracket", { fg = c.op })
hl("@punctuation.special", { fg = c.fn })

hl("@comment", { fg = c.comment, italic = true })
hl("@comment.documentation", { fg = c.fg_dark, italic = true })

hl("@type", { fg = c.type, bold = true })
hl("@type.builtin", { fg = c.type })
hl("@type.definition", { fg = c.type, bold = true })
hl("@type.qualifier", { fg = c.kw })

hl("@tag", { fg = c.kw, bold = true })
hl("@tag.attribute", { fg = c.fn })
hl("@tag.delimiter", { fg = c.op })

hl("@property", { fg = c.var })

hl("@markup.strong", { fg = c.fn, bold = true })
hl("@markup.italic", { fg = c.op, italic = true })
hl("@markup.strikethrough", { fg = c.fg_muted, strikethrough = true })
hl("@markup.underline", { underline = true })
hl("@markup.heading", { fg = c.fn, bold = true })
hl("@markup.heading.1", { fg = c.kw, bold = true })
hl("@markup.heading.2", { fg = c.fn, bold = true })
hl("@markup.heading.3", { fg = c.str, bold = true })
hl("@markup.heading.4", { fg = c.preproc, bold = true })
hl("@markup.heading.5", { fg = c.const, bold = true })
hl("@markup.heading.6", { fg = c.op, bold = true })
hl("@markup.heading.1.markdown", { fg = c.kw, bold = true })
hl("@markup.heading.2.markdown", { fg = c.fn, bold = true })
hl("@markup.heading.3.markdown", { fg = c.str, bold = true })
hl("@markup.heading.4.markdown", { fg = c.preproc, bold = true })
hl("@markup.heading.5.markdown", { fg = c.const, bold = true })
hl("@markup.heading.6.markdown", { fg = c.op, bold = true })
hl("@markup.quote", { fg = c.comment, italic = true })
hl("@markup.link", { fg = c.op, underline = true })
hl("@markup.link.label", { fg = c.op, underline = true })
hl("@markup.link.url", { fg = c.type, underline = true })
hl("@markup.list", { fg = c.kw, bold = true })
hl("@markup.list.unchecked", { fg = c.const, bold = true })
hl("@markup.list.checked", { fg = c.str, bold = true })
hl("@markup.raw", { fg = c.str, bg = "#21161d" })
hl("@markup.raw.markdown_inline", { fg = c.str, bg = "#21161d" })
hl("@markup.raw.block", { fg = c.fg })
hl("@label.markdown", { fg = c.fn, bold = true })

hl("@diff.plus", { fg = c.git_add })
hl("@diff.minus", { fg = c.git_delete })
hl("@diff.delta", { fg = c.git_change })

-- ===================================================================
-- LSP Semantic Tokens
-- ===================================================================
hl("@lsp.type.class", { fg = c.type, bold = true })
hl("@lsp.type.decorator", { fg = c.preproc })
hl("@lsp.type.enum", { fg = c.type, bold = true })
hl("@lsp.type.enumMember", { fg = c.const })
hl("@lsp.type.function", { fg = c.fn, bold = true })
hl("@lsp.type.interface", { fg = c.type, bold = true })
hl("@lsp.type.macro", { fg = c.preproc })
hl("@lsp.type.method", { fg = c.fn })
hl("@lsp.type.namespace", { fg = c.type })
hl("@lsp.type.parameter", { fg = c.var })
hl("@lsp.type.property", { fg = c.var })
hl("@lsp.type.struct", { fg = c.type, bold = true })
hl("@lsp.type.type", { fg = c.type, bold = true })
hl("@lsp.type.typeParameter", { fg = c.type, italic = true })
hl("@lsp.type.variable", { fg = c.var })

-- ===================================================================
-- LSP Diagnostics & Error Lens
-- ===================================================================
hl("DiagnosticError", { fg = c.error })
hl("DiagnosticWarn", { fg = c.warn })
hl("DiagnosticInfo", { fg = c.info })
hl("DiagnosticHint", { fg = c.hint })

hl("DiagnosticVirtualTextError", { fg = c.error, bg = c.diag_err_bg })
hl("DiagnosticVirtualTextWarn", { fg = c.warn, bg = c.diag_warn_bg })
hl("DiagnosticVirtualTextInfo", { fg = c.info, bg = c.diag_info_bg })
hl("DiagnosticVirtualTextHint", { fg = c.hint, bg = c.diag_hint_bg })

hl("DiagnosticUnderlineError", { undercurl = true, sp = c.error })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.warn })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = c.info })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = c.hint })

-- ===================================================================
-- Git Signs & Diffs
-- ===================================================================
hl("GitSignsAdd", { fg = c.git_add, bg = bg_main })
hl("GitSignsChange", { fg = c.git_change, bg = bg_main })
hl("GitSignsDelete", { fg = c.git_delete, bg = bg_main })

hl("diffAdded", { fg = c.git_add })
hl("diffRemoved", { fg = c.git_delete })
hl("diffChanged", { fg = c.git_change })
hl("diffFile", { fg = c.type, bold = true })
hl("diffNewFile", { fg = c.git_add, bold = true })
hl("diffLine", { fg = c.comment })

-- ===================================================================
-- Snacks.nvim (Dashboard, Explorer, Indent, Pickers)
-- ===================================================================
hl("SnacksNormal", { fg = c.fg, bg = bg_main })
hl("SnacksNormalNC", { fg = c.fg, bg = bg_main })
hl("SnacksWinSeparator", { fg = c.border, bg = bg_main })
hl("SnacksPicker", { fg = c.fg, bg = bg_main })
hl("SnacksPickerNormal", { fg = c.fg, bg = bg_main })
hl("SnacksPickerList", { fg = c.fg, bg = bg_main })
hl("SnacksPickerBorder", { fg = c.border, bg = bg_main })
hl("SnacksPickerInput", { fg = c.fg, bg = bg_main })
hl("SnacksPickerInputBorder", { fg = c.border, bg = bg_main })
hl("SnacksPickerListBorder", { fg = c.border, bg = bg_main })
hl("SnacksPickerBox", { fg = c.fg, bg = bg_main })
hl("SnacksPickerBoxBorder", { fg = c.border, bg = bg_main })
hl("SnacksPickerPreview", { fg = c.fg, bg = bg_main })
hl("SnacksPickerPrompt", { fg = c.fn, bg = bg_main })
hl("SnacksPickerTitle", { fg = c.fn, bg = bg_main, bold = true })
hl("SnacksPickerDirectory", { fg = c.type, bold = true })
hl("SnacksPickerDir", { fg = c.type, bold = true })
hl("SnacksPickerFile", { fg = c.fg })
hl("SnacksPickerTree", { fg = c.border })
hl("SnacksPickerSelected", { fg = c.fn, bg = c.bg_visual, bold = true })
hl("SnacksPickerMatch", { fg = c.const, bold = true })
hl("SnacksPickerGitStatusAdded", { fg = c.git_add, bold = true })
hl("SnacksPickerGitStatusModified", { fg = c.git_change, bold = true })
hl("SnacksPickerGitStatusDeleted", { fg = c.git_delete, bold = true })
hl("SnacksPickerGitStatusUntracked", { fg = c.const, bold = true })
hl("SnacksPickerGitStatusStaged", { fg = c.str, bold = true })
hl("SnacksPickerGitStatusUnmerged", { fg = c.error, bold = true })
hl("SnacksPickerGitStatusRenamed", { fg = c.preproc, bold = true })
hl("SnacksPickerGitStatusCopied", { fg = c.fn, bold = true })
hl("SnacksPickerGitStatusIgnored", { fg = c.comment })
hl("SnacksPickerPathIgnored", { fg = c.comment })
hl("SnacksPickerPathHidden", { fg = c.border })

hl("SnacksDashboardHeader", { fg = c.fn, bold = true })
hl("SnacksDashboardDesc", { fg = c.fg_dark })
hl("SnacksDashboardIcon", { fg = c.type })
hl("SnacksDashboardKey", { fg = c.kw, bold = true })
hl("SnacksIndent", { fg = c.border })
hl("SnacksIndentScope", { fg = c.fn, bold = true })

-- ===================================================================
-- Terminal & Embedded Shell Background (strictly identical to editor background)
-- ===================================================================
hl("Terminal", { fg = c.fg, bg = bg_main })
hl("TerminalNormal", { fg = c.fg, bg = bg_main })
hl("TerminalNormalNC", { fg = c.fg, bg = bg_main })
hl("StatusLineTerm", { fg = c.fg_muted, bg = bg_main })
hl("StatusLineTermNC", { fg = c.fg_muted, bg = bg_main })

-- Terminal ANSI Palette
local term_bg = (bg_main ~= "NONE") and bg_main or c.bg
vim.g.terminal_color_0 = term_bg
vim.g.terminal_color_1 = c.kw
vim.g.terminal_color_2 = c.git_add
vim.g.terminal_color_3 = c.const
vim.g.terminal_color_4 = c.type
vim.g.terminal_color_5 = c.preproc
vim.g.terminal_color_6 = c.str
vim.g.terminal_color_7 = c.fg
vim.g.terminal_color_8 = c.bg_highlight
vim.g.terminal_color_9 = c.error
vim.g.terminal_color_10 = c.git_add
vim.g.terminal_color_11 = c.fn
vim.g.terminal_color_12 = c.type
vim.g.terminal_color_13 = c.preproc
vim.g.terminal_color_14 = c.str
vim.g.terminal_color_15 = "#ffffff"

-- ===================================================================
-- NeoTree & NvimTree (Sidebar File Explorer)
-- ===================================================================
hl("NeoTreeNormal", { fg = c.fg, bg = bg_main })
hl("NeoTreeNormalNC", { fg = c.fg, bg = bg_main })
hl("NeoTreeEndOfBuffer", { fg = c.border, bg = bg_main })
hl("NeoTreeWinSeparator", { fg = c.border, bg = bg_main })
hl("NeoTreeDirectoryIcon", { fg = c.type })
hl("NeoTreeDirectoryName", { fg = c.type, bold = true })
hl("NeoTreeFileName", { fg = c.fg })
hl("NeoTreeFileIcon", { fg = c.fg_dark })
hl("NeoTreeRootName", { fg = c.fn, bold = true })
hl("NeoTreeIndentMarker", { fg = c.border })
hl("NeoTreeGitAdded", { fg = c.git_add })
hl("NeoTreeGitModified", { fg = c.git_change })
hl("NeoTreeGitDeleted", { fg = c.git_delete })
hl("NeoTreeGitUntracked", { fg = c.const })

hl("NvimTreeNormal", { fg = c.fg, bg = bg_main })
hl("NvimTreeNormalNC", { fg = c.fg, bg = bg_main })
hl("NvimTreeEndOfBuffer", { fg = c.border, bg = bg_main })
hl("NvimTreeWinSeparator", { fg = "#2d3139" })

-- ===================================================================
-- Cmp / Blink Completion Menu
-- ===================================================================
hl("CmpItemAbbr", { fg = c.fg })
hl("CmpItemAbbrDeprecated", { fg = c.fg_muted, strikethrough = true })
hl("CmpItemAbbrMatch", { fg = c.fn, bold = true })
hl("CmpItemKindFunction", { fg = c.fn })
hl("CmpItemKindMethod", { fg = c.fn })
hl("CmpItemKindVariable", { fg = c.var })
hl("CmpItemKindKeyword", { fg = c.kw })
hl("CmpItemKindClass", { fg = c.type })
hl("CmpItemKindInterface", { fg = c.type })
hl("CmpItemKindProperty", { fg = c.var })

hl("BlinkCmpLabel", { fg = c.fg })
hl("BlinkCmpLabelMatch", { fg = c.fn, bold = true })
hl("BlinkCmpKindFunction", { fg = c.fn })
hl("BlinkCmpKindMethod", { fg = c.fn })
hl("BlinkCmpKindVariable", { fg = c.var })
hl("BlinkCmpKindKeyword", { fg = c.kw })
hl("BlinkCmpKindClass", { fg = c.type })

-- ===================================================================
-- Bufferline & Statusline
-- ===================================================================
hl("BufferLineFill", { bg = c.bg_status })
hl("BufferLineBackground", { fg = c.fg_muted, bg = c.bg_status })
hl("BufferLineBufferSelected", { fg = c.fn, bg = c.bg, bold = true })
hl("BufferLineIndicatorSelected", { fg = c.fn, bg = c.bg })
hl("BufferLineCloseButtonSelected", { fg = c.fg_muted, bg = c.bg })
hl("BufferLineCloseButton", { fg = c.fg_muted, bg = c.bg_status })
hl("BufferLineCloseButtonVisible", { fg = c.fg_muted, bg = c.bg_status })
hl("BufferLineModifiedSelected", { fg = c.str, bg = c.bg })
hl("BufferLineSeparator", { fg = c.bg_status, bg = c.bg_status })

-- ===================================================================
-- Mini.icons (Vibrant Crimson Nocturne Palette)
-- ===================================================================
hl("MiniIconsAzure", { fg = "#7eb6ff" })
hl("MiniIconsBlue", { fg = "#5a98d6" })
hl("MiniIconsCyan", { fg = c.str })
hl("MiniIconsGreen", { fg = c.git_add })
hl("MiniIconsGrey", { fg = c.fg_dark })
hl("MiniIconsOrange", { fg = c.const })
hl("MiniIconsPurple", { fg = c.preproc })
hl("MiniIconsRed", { fg = c.kw })
hl("MiniIconsYellow", { fg = c.fn })
