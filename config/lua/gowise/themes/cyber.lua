-- Gowise Bespoke Theme 3: Cyber Synth
-- Neon dark matter with laser magenta, hyper cyan, electric lime, and cyber yellow

local M = {
  name = "cyber",
  label = "Gowise Cyber Synth",
  palette = {
    bg = "#120E1E",
    bg_subtle = "#1A142D",
    bg_highlight = "#261D42",
    bg_active = "#372A5E",
    fg = "#F5E8FF",
    fg_muted = "#9E87BA",
    fg_subtle = "#5D4977",
    border = "#413264",

    magenta = "#FF007F",   -- Laser Magenta
    cyan = "#00F5FF",      -- Hyper Cyan
    lime = "#39FF14",      -- Electric Lime
    yellow = "#FFE600",    -- Cyber Yellow
    purple = "#BD00FF",    -- Deep Neon Purple
    orange = "#FF5500",
    comment = "#7C639E",

    fluent_green = "#39FF14",
    rainbow = {
      "#FFE600", "#FF007F", "#00F5FF", "#39FF14", "#BD00FF", "#FF5500"
    },
  },
}

function M.apply()
  local p = M.palette
  local set = vim.api.nvim_set_hl

  vim.cmd("highlight clear")
  vim.g.colors_name = "gowise-cyber"

  set(0, "Normal", { fg = p.fg, bg = p.bg })
  set(0, "NormalFloat", { fg = p.fg, bg = p.bg_subtle })
  set(0, "FloatBorder", { fg = p.border, bg = p.bg_subtle })
  set(0, "FloatTitle", { fg = p.magenta, bg = p.bg_subtle, bold = true })
  set(0, "CursorLine", { bg = p.bg_subtle })
  set(0, "CursorLineNr", { fg = p.fluent_green, bg = p.bg_subtle, bold = true })
  set(0, "LineNr", { fg = p.fg_subtle, bg = p.bg })
  set(0, "Visual", { bg = p.bg_active })
  set(0, "Search", { fg = p.bg, bg = p.yellow })
  set(0, "IncSearch", { fg = p.bg, bg = p.cyan, bold = true })
  set(0, "WinSeparator", { fg = p.border, bg = p.bg })

  set(0, "StatusLine", { fg = p.fg, bg = p.bg_subtle })
  set(0, "StatusLineNC", { fg = p.fg_muted, bg = p.bg })
  set(0, "TabLineSel", { fg = p.magenta, bg = p.bg_subtle, bold = true })

  set(0, "Comment", { fg = p.comment, italic = true })
  set(0, "String", { fg = p.lime })
  set(0, "Function", { fg = p.cyan, bold = true })
  set(0, "Keyword", { fg = p.magenta, bold = true })
  set(0, "Type", { fg = p.yellow, bold = true })
  set(0, "Constant", { fg = p.orange })
  set(0, "Operator", { fg = p.cyan })

  for i, col in ipairs(p.rainbow) do
    set(0, "RainbowDelimiter" .. i, { fg = col })
  end

  set(0, "SnacksIndent", { fg = p.border })
  set(0, "SnacksIndentScope", { fg = p.fluent_green })
  set(0, "DiagnosticError", { fg = p.magenta })
  set(0, "DiagnosticWarn", { fg = p.yellow })
  set(0, "DiagnosticInfo", { fg = p.cyan })
  set(0, "DiagnosticHint", { fg = p.lime })
  set(0, "DiagnosticVirtualTextError", { fg = p.magenta, bg = "#330A1C", italic = true })
  set(0, "DiagnosticVirtualTextWarn", { fg = p.yellow, bg = "#332A08", italic = true })
end

return M
