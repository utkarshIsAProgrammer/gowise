-- Gowise Rainbow Tabs Engine
-- Color-coded tabs with filetype icons, modified dots, and fluent active tab indicator

local M = {}

local rainbow_colors = {
  "%#RainbowDelimiter1#",
  "%#RainbowDelimiter2#",
  "%#RainbowDelimiter3#",
  "%#RainbowDelimiter4#",
  "%#RainbowDelimiter5#",
  "%#RainbowDelimiter6#",
}

function M.render()
  local s = ""
  local current_buf = vim.api.nvim_get_current_buf()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })

  for i, b in ipairs(bufs) do
    local is_active = (b.bufnr == current_buf)
    local name = vim.fn.fnamemodify(b.name, ":t")
    if name == "" then name = "[Untitled]" end

    -- Resolve big, related file icon & color
    local icon, icon_hl = "󰈔 ", (is_active and "TabLineSel" or "TabLine")
    if name ~= "[Untitled]" then
      local ok_mini, mini_icons = pcall(require, "mini.icons")
      if ok_mini and mini_icons.get then
        local ic, hl = mini_icons.get("file", name)
        if ic and ic ~= "" then icon = ic end
        if hl and hl ~= "" then icon_hl = hl end
      end
    end

    -- Rainbow accent color for tab index
    local rainbow_hl = rainbow_colors[((i - 1) % #rainbow_colors) + 1]
    local tab_hl = is_active and "%#TabLineSel#" or "%#TabLine#"

    s = s .. tab_hl .. " " .. rainbow_hl .. (is_active and "▎" or "▏") .. tab_hl .. " %#" .. icon_hl .. "#" .. icon .. tab_hl .. " " .. name

    if b.changed == 1 then
      s = s .. " %#GowiseFluentGreen#●%*"
    end

    s = s .. " %#TabLine# "
  end

  s = s .. "%#TabLineFill#%="
  return s
end

function M.setup()
  vim.opt.tabline = "%!v:lua.require('gowise.ui.tabline').render()"
  vim.opt.showtabline = 2 -- Always show tabline like VS Code & Zed
end

return M
