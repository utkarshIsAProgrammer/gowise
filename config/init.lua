-- Gowise Core Engine Entrypoint
-- Optimized for sub-30ms startup, ultra-low memory, and pure modeless VS Code/Zed editing

-- Enable fast LuaJIT bytecode loader cache
if vim.loader then
  vim.loader.enable()
end

-- Ensure NVIM_APPNAME is isolated
vim.env.NVIM_APPNAME = "gowise"

-- Ensure config directory is in runtimepath
local config_dir = vim.fn.stdpath("config")
if not vim.tbl_contains(vim.opt.rtp:get(), config_dir) then
  vim.opt.rtp:prepend(config_dir)
end

-- Prepend Mason bin directory to PATH so formatters and language servers are immediately available
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if vim.fn.isdirectory(mason_bin) == 1 then
  vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end

-- Disable unused Vim internal plugins for maximum startup speed
local disabled_builtins = {
  "gzip", "zip", "zipPlugin", "tar", "tarPlugin", "getscript", "getscriptPlugin",
  "vimball", "vimballPlugin", "2html_plugin", "logipat", "rrhelper", "spellfile_plugin",
  "matchit", "matchparen", "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers",
}
for _, plugin in ipairs(disabled_builtins) do
  vim.g["loaded_" .. plugin] = 1
end

-- Bootstrap lazy.nvim package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load Core Configurations
require("gowise.core.options")
require("gowise.core.autocmds")
require("gowise.core.keymaps")

-- Load Plugins and Theme Engine
require("gowise.plugins")

-- Initialize UI & Ecosystem Components
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("gowise.ui.statusline").setup()
    require("gowise.ui.tabline").setup()
    require("gowise.ui.winbar").setup()
    require("gowise.components.session").setup()
    require("gowise.components.terminal").setup()
    require("gowise.components.runner").setup()
  end,
})
