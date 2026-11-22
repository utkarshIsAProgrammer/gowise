-- Gowise Fluent Line & Smooth Visual Experience
-- Delivers the glowing green fluent line and smooth visual cues

local M = {}

function M.setup()
  local set = vim.api.nvim_set_hl

  -- Active cursorline: soft background with high-contrast fluent active line number
  set(0, "CursorLine", { bg = "#141822" })
  set(0, "CursorLineNr", { fg = "#00E676", bold = true })

  -- Indent guide scope highlighting (neon green fluent accent)
  set(0, "SnacksIndentScope", { fg = "#00E676", bold = true })
  set(0, "SnacksIndent", { fg = "#202836" })

  -- Cursor line pulse/fluency on insert enter / leave
  local fluent_group = vim.api.nvim_create_augroup("GowiseFluent", { clear = true })

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = fluent_group,
    callback = function()
      set(0, "CursorLineNr", { fg = "#00E5FF", bold = true })
    end,
  })

  vim.api.nvim_create_autocmd("InsertLeave", {
    group = fluent_group,
    callback = function()
      set(0, "CursorLineNr", { fg = "#00E676", bold = true })
    end,
  })
end

return M
