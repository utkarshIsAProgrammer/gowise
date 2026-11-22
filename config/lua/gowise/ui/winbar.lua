-- Gowise Breadcrumbs Winbar
-- Displays: folder > filename > current function/symbol

local M = {}

function M.render()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  if ft == "" or ft == "NvimTree" or ft == "snacks_terminal" then
    return ""
  end

  local full_path = vim.fn.expand("%:p")
  if full_path == "" then return "" end

  local rel_path = vim.fn.expand("%:~:.")
  local parts = vim.split(rel_path, "[/\\]")

  local breadcrumbs = {}
  for i, part in ipairs(parts) do
    if i == #parts then
      table.insert(breadcrumbs, "%#FloatTitle#" .. part .. "%*")
    else
      table.insert(breadcrumbs, "%#Comment#" .. part .. "%*")
    end
  end

  return "  " .. table.concat(breadcrumbs, " %#Comment#›%* ")
end

function M.setup()
  vim.opt.winbar = "%!v:lua.require('gowise.ui.winbar').render()"
end

return M
