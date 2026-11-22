-- Gowise Theme Engine & Live Preview Switcher
-- Manages custom signature themes with persistent settings and live previews

local M = {}

M.themes = {
  obsidian = require("gowise.themes.obsidian"),
  aurora   = require("gowise.themes.aurora"),
  cyber    = require("gowise.themes.cyber"),
  titanium = require("gowise.themes.titanium"),
  espresso = require("gowise.themes.espresso"),
  nebula   = require("gowise.themes.nebula"),
}

local settings_path = vim.fn.stdpath("config") .. "/settings.json"

function M.get_current_theme_name()
  if vim.fn.filereadable(settings_path) == 1 then
    local content = vim.fn.readfile(settings_path)
    local ok, parsed = pcall(vim.fn.json_decode, table.concat(content, ""))
    if ok and parsed and parsed.theme and M.themes[parsed.theme] then
      return parsed.theme
    end
  end
  return "obsidian"
end

function M.save_theme(theme_name)
  local data = { theme = theme_name }
  if vim.fn.filereadable(settings_path) == 1 then
    local content = vim.fn.readfile(settings_path)
    local ok, parsed = pcall(vim.fn.json_decode, table.concat(content, ""))
    if ok and type(parsed) == "table" then
      data = parsed
      data.theme = theme_name
    end
  end
  local encoded = vim.fn.json_encode(data)
  vim.fn.writefile({ encoded }, settings_path)
end

function M.apply(theme_name)
  local theme = M.themes[theme_name] or M.themes["obsidian"]
  theme.apply()
  vim.g.gowise_active_theme = theme.name

  local p = theme.palette
  local set = vim.api.nvim_set_hl

  -- Dashboard highlights tuned to active theme
  local primary = p.cyan or p.emerald or p.magenta or p.blue or p.tangerine or "#00E5FF"
  local accent = p.fluent_green or p.mint or p.lime or "#00E676"
  local key_color = p.yellow or p.amber or p.cyan or "#FFD600"
  local title_color = p.purple or p.violet or p.indigo or "#9D4EDD"

  set(0, "SnacksDashboardHeader", { fg = primary, bold = true })
  set(0, "SnacksDashboardIcon", { fg = accent, bold = true })
  set(0, "SnacksDashboardKey", { fg = key_color, bold = true })
  set(0, "SnacksDashboardDesc", { fg = p.fg })
  set(0, "SnacksDashboardTitle", { fg = title_color, bold = true })
  set(0, "SnacksDashboardFooter", { fg = p.fg_muted, italic = true })
end

function M.setup()
  local active = M.get_current_theme_name()
  M.apply(active)
end

-- Live Interactive Theme Picker
function M.theme_picker()
  local original = M.get_current_theme_name()
  local items = {
    { text = "Gowise Obsidian Void (Deep Space & Cyan)", theme = "obsidian" },
    { text = "Gowise Aurora Teal (Glacier & Emerald)", theme = "aurora" },
    { text = "Gowise Cyber Synth (Laser Magenta & Lime)", theme = "cyber" },
    { text = "Gowise Monolith Titanium (Graphite & Cobalt)", theme = "titanium" },
    { text = "Gowise Velvet Espresso (Roasted Mocha & Tangerine)", theme = "espresso" },
    { text = "Gowise Cobalt Nebula (Deep Cosmic Navy & Indigo)", theme = "nebula" },
  }

  if Snacks and Snacks.picker then
    Snacks.picker({
      title = "Gowise Color Themes",
      items = items,
      format = "text",
      preview = function(ctx)
        local item = ctx.item
        if item and item.theme then
          M.apply(item.theme)
        end
      end,
      confirm = function(picker, item)
        picker:close()
        if item and item.theme then
          M.apply(item.theme)
          M.save_theme(item.theme)
          vim.notify("Theme set to: " .. item.text, vim.log.levels.INFO, { title = "Gowise Themes" })
        end
      end,
      cancel = function()
        M.apply(original)
      end,
    })
  else
    -- Fallback simple UI select
    local names = {}
    for _, it in ipairs(items) do table.insert(names, it.text) end
    vim.ui.select(names, { prompt = "Select Gowise Theme:" }, function(choice, idx)
      if idx and items[idx] then
        M.apply(items[idx].theme)
        M.save_theme(items[idx].theme)
      else
        M.apply(original)
      end
    end)
  end
end

-- Bind Theme Switcher to Ctrl+K Ctrl+T (VS Code standard)
vim.keymap.set({ "n", "i" }, "<C-k><C-t>", M.theme_picker, { desc = "Preferences: Color Theme" })

return M
