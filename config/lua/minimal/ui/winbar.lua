-- Minimal Breadcrumbs Winbar
-- Displays: folder > filename > current function/symbol
-- Cached per-buffer for instantaneous 0-lag cursor movement

local M = {}

local function build_winbar(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return "" end
  local ft = vim.bo[bufnr].filetype
  if ft == "" or ft == "NvimTree" or ft == "snacks_terminal" then
    return ""
  end

  local full_path = vim.api.nvim_buf_get_name(bufnr)
  if full_path == "" then return "" end

  local rel_path = vim.fn.fnamemodify(full_path, ":~:.")
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

function M.render()
  local bufnr = vim.api.nvim_get_current_buf()
  local cached = vim.b[bufnr].minimal_winbar
  if cached ~= nil then
    return cached
  end

  local winbar_str = build_winbar(bufnr)
  vim.b[bufnr].minimal_winbar = winbar_str
  return winbar_str
end

function M.setup()
  vim.opt.winbar = "%!v:lua.require('minimal.ui.winbar').render()"

  local group = vim.api.nvim_create_augroup("MinimalWinbarCache", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "DirChanged" }, {
    group = group,
    callback = function(args)
      local bufnr = args.buf or vim.api.nvim_get_current_buf()
      if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        vim.b[bufnr].minimal_winbar = build_winbar(bufnr)
      end
    end,
  })
end

return M
