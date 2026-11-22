-- Gowise Error Lens & Inline Diagnostic Highlights
-- Displays elegant, non-intrusive compiler & linter diagnostics directly on line ends

local M = {}

function M.setup()
  vim.diagnostic.config({
    virtual_text = {
      prefix = "● ",
      spacing = 4,
      severity = { min = vim.diagnostic.severity.HINT },
      format = function(diag)
        return string.format("%s", diag.message)
      end,
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "󰅚",
        [vim.diagnostic.severity.WARN] = "󰀦",
        [vim.diagnostic.severity.INFO] = "󰋼",
        [vim.diagnostic.severity.HINT] = "󰌵",
      },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = "rounded",
      source = "always",
    },
  })
end

return M
