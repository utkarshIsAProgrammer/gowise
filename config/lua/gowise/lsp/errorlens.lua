-- Gowise Error Lens & Inline Diagnostic Highlights
-- Displays elegant, non-intrusive compiler & linter diagnostics directly on line ends in real time

local M = {}

function M.setup()
  -- Apply subtle, modern highlights for Error Lens virtual text
  local hl = vim.api.nvim_set_hl
  hl(0, "DiagnosticVirtualTextError", { fg = "#f87171", italic = true })
  hl(0, "DiagnosticVirtualTextWarn", { fg = "#fbbf24", italic = true })
  hl(0, "DiagnosticVirtualTextInfo", { fg = "#38bdf8", italic = true })
  hl(0, "DiagnosticVirtualTextHint", { fg = "#34d399", italic = true })

  vim.diagnostic.config({
    virtual_text = {
      spacing = 4,
      prefix = function(diag)
        local icons = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = " ",
          [vim.diagnostic.severity.INFO] = " ",
        }
        return icons[diag.severity] or "● "
      end,
      source = "if_many",
      severity_sort = true,
      format = function(diag)
        return diag.message
      end,
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN] = " ",
        [vim.diagnostic.severity.INFO] = " ",
        [vim.diagnostic.severity.HINT] = " ",
      },
    },
    underline = true,
    update_in_insert = true, -- Crucial for modeless editor: shows errors in real time while typing
    severity_sort = true,
    float = {
      border = "rounded",
      source = "if_many",
    },
  })
end

return M
