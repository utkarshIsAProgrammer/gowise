-- =============================================================================
-- Minimal Code Editor - Fast Bytecode-Cached Entrypoint (Linux)
-- Crafted by indiedev
-- =============================================================================

if vim.loader then
  vim.loader.enable()
end

-- Ensure standard local bin directories are in PATH for LSPs and formatters
do
  local home = vim.fn.expand("~")
  local local_bin = home .. "/.local/bin"
  local go_bin = home .. "/go/bin"
  local cur_path = vim.env.PATH or ""
  if not cur_path:find(local_bin, 1, true) then
    cur_path = local_bin .. ":" .. cur_path
  end
  if not cur_path:find(go_bin, 1, true) then
    cur_path = go_bin .. ":" .. cur_path
  end
  vim.env.PATH = cur_path
end

-- Disable unused legacy remote plugin providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

-- Disable unused slow built-in Vim runtime plugins
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_rplugin = 1
vim.g.loaded_man = 1
vim.g.loaded_spellfile_plugin = 1
vim.g.loaded_matchit = 1

-- Ensure standalone minimal packpath, config dir & parser runtimes are recognized without double-sourcing
local minimal_site = vim.fn.expand("~/.local/share/minimal/site")
local minimal_cfg = vim.fn.stdpath("config")
local fallback_cfg = vim.fn.expand("~/.config/minimal")
if vim.fn.isdirectory(minimal_cfg .. "/lua") == 0 and vim.fn.isdirectory(fallback_cfg .. "/lua") == 1 then
  minimal_cfg = fallback_cfg
end
if not vim.tbl_contains(vim.opt.runtimepath:get(), minimal_cfg) then
  vim.opt.runtimepath:prepend(minimal_cfg)
end

-- Migrate deferred plugins out of start/ into opt/ once so startup stays fast (~20-25ms)
local lazy_start_dir = minimal_site .. "/pack/plugins/start"
local lazy_opt_dir = minimal_site .. "/pack/plugins/opt"
if vim.fn.isdirectory(lazy_start_dir .. "/LuaSnip") == 1 then
  vim.fn.mkdir(lazy_opt_dir, "p")
  for _, plugin_name in ipairs({
    "LuaSnip", "friendly-snippets", "nvim-cmp", "cmp-buffer",
    "cmp_luasnip", "cmp-nvim-lsp", "cmp-nvim-lua", "cmp-path",
    "nvim-autopairs", "emmet-vim", "conform.nvim", "color-picker.nvim",
    "nvim-colorizer.lua", "indent-blankline.nvim", "multiple-cursors.nvim",
    "nvim-lspconfig", "nvim-treesitter", "gitsigns.nvim", "rainbow-delimiters.nvim",
  }) do
    local src = lazy_start_dir .. "/" .. plugin_name
    local dst = lazy_opt_dir .. "/" .. plugin_name
    if vim.fn.isdirectory(src) == 1 and vim.fn.isdirectory(dst) == 0 then
      vim.uv.fs_rename(src, dst)
    end
  end
end

local has_minimal_plugins = vim.fn.isdirectory(minimal_site .. "/pack/plugins/start/nvim-tree.lua") == 1
if vim.fn.isdirectory(minimal_site) == 1 then
  if not vim.tbl_contains(vim.opt.packpath:get(), minimal_site) then
    vim.opt.packpath:prepend(minimal_site)
  end
  if not vim.tbl_contains(vim.opt.runtimepath:get(), minimal_site) then
    vim.opt.runtimepath:prepend(minimal_site)
  end
end
if not has_minimal_plugins then
  local nvim_site = vim.fn.expand("~/.local/share/nvim/site")
  if vim.fn.isdirectory(nvim_site) == 1 then
    if not vim.tbl_contains(vim.opt.packpath:get(), nvim_site) then
      vim.opt.packpath:append(nvim_site)
    end
    if not vim.tbl_contains(vim.opt.runtimepath:get(), nvim_site) then
      vim.opt.runtimepath:append(nvim_site)
    end
  end
end

-- Silence deprecation warning for vim.tbl_flatten across all plugins
if vim.iter then
  vim.tbl_flatten = function(t)
    return vim.iter(t):flatten(math.huge):totable()
  end
end

-- Ensure Treesitter queries runtime is always available in runtimepath & site directory
local ts_queries_dir = minimal_site .. "/pack/plugins/opt/nvim-treesitter/runtime"
if vim.fn.isdirectory(ts_queries_dir) == 1 and not vim.tbl_contains(vim.opt.runtimepath:get(), ts_queries_dir) then
  vim.opt.runtimepath:append(ts_queries_dir)
end
if vim.fn.isdirectory(ts_queries_dir .. "/queries") == 1 and vim.fn.isdirectory(minimal_site .. "/queries") == 0 then
  pcall(vim.uv.fs_symlink, ts_queries_dir .. "/queries", minimal_site .. "/queries")
end

require("minimal_core")
