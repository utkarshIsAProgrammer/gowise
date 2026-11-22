-- Minimal Core Engine Entrypoint
-- Optimized for sub-30ms startup, ultra-low memory, and pure modeless VS Code/Zed editing

-- Ensure cache directory exists before enabling loader
pcall(vim.fn.mkdir, vim.fn.stdpath("cache") .. "/luac", "p")

-- Enable fast LuaJIT bytecode loader cache
if vim.loader then
	vim.loader.enable()
end

-- Ensure NVIM_APPNAME is isolated
vim.env.NVIM_APPNAME = "minimal"

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
	"gzip",
	"zip",
	"zipPlugin",
	"tar",
	"tarPlugin",
	"getscript",
	"getscriptPlugin",
	"vimball",
	"vimballPlugin",
	"2html_plugin",
	"logipat",
	"rrhelper",
	"spellfile_plugin",
	"matchit",
	"matchparen",
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
}
for _, plugin in ipairs(disabled_builtins) do
	vim.g["loaded_" .. plugin] = 1
end

-- Filter out third-party library deprecation notifications from popups
local orig_notify = vim.notify
vim.notify = function(msg, level, opts)
	if type(msg) == "string" and (msg:find("deprecated") or msg:find("lspconfig")) then
		return
	end
	return orig_notify(msg, level, opts)
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

-- Prepend config bin to PATH so embedded terminals route 'minimal', 'nvim', 'code' to active instance
local config_bin = vim.fn.stdpath("config") .. "/bin"
if vim.fn.isdirectory(config_bin) == 1 then
	vim.env.PATH = config_bin .. ":" .. vim.env.PATH
end

-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load Core Configurations
require("minimal.core.options")
require("minimal.core.autocmds")
require("minimal.core.keymaps")
require("minimal.lsp.errorlens").setup()

-- Load Plugins and Theme Engine
require("minimal.plugins")

-- Initialize UI & Ecosystem Components
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		require("minimal.ui.statusline").setup()
		require("minimal.ui.tabline").setup()
		require("minimal.ui.winbar").setup()
		require("minimal.components.session").setup()
		require("minimal.components.terminal").setup()
		require("minimal.components.runner").setup()
	end,
})
