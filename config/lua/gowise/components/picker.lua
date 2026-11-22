-- Gowise Unified Search & Navigation Pickers
-- Bridges Command Palette, File Finder, Symbol Search, and Live Grep

local M = {}

function M.files()
  if Snacks and Snacks.picker then
    Snacks.picker.files()
  else
    vim.cmd("find")
  end
end

function M.commands()
  if Snacks and Snacks.picker then
    Snacks.picker.commands()
  end
end

function M.grep()
  if Snacks and Snacks.picker then
    Snacks.picker.grep()
  end
end

function M.symbols()
  if Snacks and Snacks.picker then
    Snacks.picker.lsp_symbols()
  end
end

return M
