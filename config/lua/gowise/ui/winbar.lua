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

  local ok_mini, mini_icons = pcall(require, "mini.icons")

  local breadcrumbs = {}
  for i, part in ipairs(parts) do
    if i == #parts then
      local file_icon, file_hl = "󰈔 ", "FloatTitle"
      if ok_mini and mini_icons.get then
        local ic, hl = mini_icons.get("file", part)
        if ic and ic ~= "" then file_icon = ic end
        if hl and hl ~= "" then file_hl = hl end
      end
      table.insert(breadcrumbs, "%#" .. file_hl .. "#" .. file_icon .. "%#FloatTitle#" .. part .. "%*")
    else
      local dir_icon, dir_hl = "󰉍 ", "Directory"
      if ok_mini and mini_icons.get then
        local ic, hl = mini_icons.get("directory", part)
        if ic and ic ~= "" then dir_icon = ic end
        if hl and hl ~= "" then dir_hl = hl end
      end
      table.insert(breadcrumbs, "%#" .. dir_hl .. "#" .. dir_icon .. "%#Comment#" .. part .. "%*")
    end
  end

  return "  " .. table.concat(breadcrumbs, " %#Comment#›%* ")
end

function M.setup()
  vim.opt.winbar = "%!v:lua.require('gowise.ui.winbar').render()"
end

return M
