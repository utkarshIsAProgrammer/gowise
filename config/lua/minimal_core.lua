-- =============================================================================
-- Minimal Code Editor Core (Bytecode-Cached via vim.loader)
-- Crafted by indiedev
-- =============================================================================

local loaded_opt_plugins = {}
local function packadd_safe(name)
  if loaded_opt_plugins[name] then return end
  loaded_opt_plugins[name] = true
  pcall(vim.cmd.packadd, name)
end

-- 1. General Editor Behavior & Layout
vim.opt.shell = "/bin/bash"              -- Force standard Bash shell instead of parent terminal shell (e.g. Zsh/Kitty)
vim.opt.mouse = "a"                      -- Full mouse support (click, drag to select)
vim.opt.number = true                    -- Line numbers
vim.opt.relativenumber = true            -- Vim hybrid relative line numbers (current line absolute, others relative)
vim.opt.numberwidth = 4                  -- Stable line number column width
vim.opt.signcolumn = "yes:2"             -- Always show 2-column gutter for error lens / git icons
vim.opt.wrap = true                      -- Wrap long lines like VS Code
vim.opt.linebreak = true                 -- Break long lines at word boundaries (don't break words)
vim.opt.breakindent = true               -- Preserve indentation level for wrapped lines
vim.opt.breakindentopt = "shift:2,min:40"-- Subtle 2-space continuation indent
vim.opt.showbreak = "↳ "                 -- Faint continuation glyph
vim.opt.equalalways = false              -- Never automatically resize windows to equal width
vim.opt.swapfile = false                 -- No swap files
vim.opt.backup = false                   -- No backup files
vim.opt.undofile = true                  -- Persistent undo history
vim.opt.termguicolors = true             -- True color support
vim.opt.cursorline = true                -- Subtle highlight on the current line
vim.opt.ignorecase = true                -- Case-insensitive search
vim.opt.smartcase = true                 -- Case-sensitive if capital letter typed
vim.opt.completeopt = { "menu", "menuone", "noselect" } -- Fluent modern completion popup

-- Code Spell Checker & Clipboard (deferred after initial paint for sub-25ms cold boot)
vim.opt.spellcapcheck = ""
vim.defer_fn(function()
  vim.opt.clipboard = "unnamedplus"
  vim.opt.spelllang = { "en_us" }
  pcall(function() vim.opt.spelloptions:append("camel") end)
  vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
  vim.opt.spell = true
  vim.api.nvim_set_hl(0, "SpellBad", { undercurl = true, sp = "#f38ba8" })
  vim.api.nvim_set_hl(0, "SpellCap", { undercurl = true, sp = "#fab387" })
  vim.api.nvim_set_hl(0, "SpellLocal", { undercurl = true, sp = "#61afef" })
  vim.api.nvim_set_hl(0, "SpellRare", { undercurl = true, sp = "#cba6f7" })
end, 12)
vim.opt.shortmess:append("I")            -- Hide Neovim splash screen
vim.opt.fillchars = {
  vert = "│",
  vertleft = "│",
  vertright = "│",
  verthoriz = "│",
  horiz = "─",
  eob = " ",
}
vim.opt.showmode = false                 -- Hide '-- INSERT --' (always typing)
vim.opt.showcmd = false                  -- Hide command keystrokes
vim.opt.updatetime = 200                 -- Fast diagnostics and git status updates
vim.opt.ttimeoutlen = 50                 -- Safe terminal key-sequence decoding (default 50ms)
vim.opt.timeoutlen = 1000                -- Comfortable chord timeout for Ctrl+K chords (VS Code style)
vim.opt.redrawtime = 1500                -- Cap regex syntax redraw time on huge files
vim.opt.synmaxcol = 300                  -- Prevent syntax lag on minified single-line files
vim.opt.virtualedit = "onemore"          -- Allow cursor past end of line (Notepad behavior)
vim.opt.tabstop = 4                      -- Standard 4 spaces
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Natural screen-line navigation across wrapped lines in normal & visual mode
vim.keymap.set({ "n", "x" }, "<Up>", function()
  return vim.v.count == 0 and "g<Up>" or "<Up>"
end, { expr = true, silent = true, desc = "Visual Line Up" })
vim.keymap.set({ "n", "x" }, "<Down>", function()
  return vim.v.count == 0 and "g<Down>" or "<Down>"
end, { expr = true, silent = true, desc = "Visual Line Down" })
vim.keymap.set({ "n", "x" }, "k", function()
  return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Relative Line Up" })
vim.keymap.set({ "n", "x" }, "j", function()
  return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Relative Line Down" })

-- Top Tabs Bar: Always show tabs like VS Code
vim.opt.showtabline = 2
-- Global single status bar at the bottom like VS Code (no duplicate window status bars)
vim.opt.laststatus = 3

-- Cursors:
-- Normal mode (Sidebar): BLOCK cursor (block)
-- Insert / Typing mode (Editor, Rename prompt): NORMAL vertical bar cursor (|) (ver25)
vim.opt.guicursor = "n:block-blinkon500-blinkoff500,i-c-v-ve:ver25-blinkon500-blinkoff500"

-- 2. Modeless Selection Rules
vim.opt.keymodel = "startsel,stopsel"    -- Shift keys start selection, non-shift stops
vim.opt.selection = "exclusive"          -- Selection ends before cursor col (modeless standard)
vim.opt.selectmode = "mouse,key"         -- Mouse and Shift-keys start Select mode

vim.g.startup_done = false

-- 3. PERMANENT INSERT MODE ENFORCEMENT
-- Automatically enter and stay locked in Insert Mode in text buffers and Terminal mode in terminal,
-- but Normal Mode in the sidebar and floating pickers/dialogs.
local function enforce_buffer_mode()
  local cur_win = vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(cur_win) then return end
  local win_cfg = vim.api.nvim_win_get_config(cur_win)
  if win_cfg.relative ~= "" then
    -- Floating window! Keep in Normal mode so sliders, pickers, and popups operate seamlessly
    return
  end
  local cur_buf = vim.api.nvim_win_get_buf(cur_win)
  if vim.b[cur_buf].is_renaming or vim.b[cur_buf].is_picker then
    return
  end
  local cur_ft = vim.bo[cur_buf].filetype
  if cur_ft == "color-picker" then
    return
  end
  local cur_bt = vim.bo[cur_buf].buftype
  local name = vim.api.nvim_buf_get_name(cur_buf)

  if cur_ft == "NvimTree" or name:match("NvimTree") ~= nil or cur_ft == "minimal_home" or vim.b[cur_buf].is_homescreen then
    if not vim.g.minimal_ignore_tree_stopinsert then
      vim.cmd("stopinsert")
    end
  elseif cur_bt == "terminal" then
    if vim.fn.mode() ~= "t" then
      vim.cmd("startinsert")
    end
  elseif cur_bt == "" and cur_ft ~= "NvimTree" and not name:match("NvimTree") and cur_ft ~= "minimal_home" and not vim.b[cur_buf].is_homescreen then
    if not vim.g.startup_done then
      return
    end
    if name ~= "" then
      vim.bo[cur_buf].buflisted = true
    end
    -- Newly created or unwritten files immediately display the unsaved dot icon ● in top tab bar
    if name == "" or vim.fn.filereadable(name) == 0 then
      vim.bo[cur_buf].modified = true
    end
    if vim.g.minimal_mc_active and vim.fn.mode():match("^[vVxXn\22]") then
      return
    end
    if vim.fn.mode() ~= "i" and vim.fn.mode() ~= "s" then
      vim.cmd("startinsert")
    end
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter", "FocusGained", "VimEnter" }, {
  pattern = "*",
  callback = enforce_buffer_mode,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*:n",
  callback = function()
    vim.schedule(enforce_buffer_mode)
  end,
})

-- 4. Syntax Highlighting & Full Dev Stack Language Support (syntax deferred after first paint)
vim.cmd("filetype plugin indent on")
vim.defer_fn(function()
  pcall(vim.cmd, "syntax enable")
end, 1)

vim.filetype.add({
  extension = {
    redis = "conf",
    env = "sh",
    conf = "conf",
    md = "markdown",
    mdx = "markdown",
    markdown = "markdown",
    svelte = "svelte",
    vue = "vue",
    jsx = "javascriptreact",
    tsx = "typescriptreact",
  },
  filename = {
    ["docker-compose.yml"] = "yaml",
    ["docker-compose.yaml"] = "yaml",
    ["Dockerfile"] = "dockerfile",
    [".env"] = "sh",
    [".env.local"] = "sh",
    [".env.development"] = "sh",
    [".env.production"] = "sh",
    ["tailwind.config.js"] = "javascript",
    ["tailwind.config.ts"] = "typescript",
    ["tailwind.config.mjs"] = "javascript",
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(args)
    local b = args.buf
    local ft = vim.bo[b].filetype
    if ft == "NvimTree" or ft == "minimal_home" or vim.bo[b].buftype ~= "" then return end
    local name = vim.api.nvim_buf_get_name(b)
    if name ~= "" then
      local st = vim.uv.fs_stat(name)
      if st and st.size > 262144 then return end
    end
    packadd_safe("nvim-treesitter")
    pcall(vim.treesitter.start, b)
  end,
})

-- Visual Color Highlighting & Color Decorators (deferred after first paint)
vim.defer_fn(function()
  packadd_safe("nvim-colorizer.lua")
  local ok_colorizer, colorizer = pcall(require, "colorizer")
  if ok_colorizer then
    colorizer.setup({
      "*",
      "!NvimTree",
      "!minimal_home",
      css = { rgb_fn = true, hsl_fn = true, css = true, css_fn = true },
      html = { names = false },
      javascript = { rgb_fn = true, hsl_fn = true },
      typescript = { rgb_fn = true, hsl_fn = true },
      javascriptreact = { rgb_fn = true, hsl_fn = true },
      typescriptreact = { rgb_fn = true, hsl_fn = true },
      svelte = { rgb_fn = true, hsl_fn = true },
      vue = { rgb_fn = true, hsl_fn = true },
    })
  end
end, 25)

-- Visual Interactive Color Picker (lazy-initialized on demand)
local cp_configured = false
local function ensure_color_picker()
  if cp_configured then return end
  cp_configured = true
  packadd_safe("color-picker.nvim")
  local ok_cp, color_picker = pcall(require, "color-picker")
  if ok_cp then
    color_picker.setup({
      border = "rounded",
      keymap = {
        ["<Left>"] = "<Plug>ColorPickerSlider1Decrease",
        ["<Right>"] = "<Plug>ColorPickerSlider1Increase",
        ["<Up>"] = "k",
        ["<Down>"] = "j",
        ["<CR>"] = "<Plug>ColorPickerApplyColor",
        ["<Esc>"] = "<Plug>ColorPickerCloseColorPicker",
        ["q"] = "<Plug>ColorPickerCloseColorPicker",
      },
    })
  end
end

_G.open_color_picker = function()
  ensure_color_picker()
  if _G.register_active_menu then
    _G.register_active_menu()
  end
  vim.cmd("stopinsert")
  local ok = pcall(vim.cmd, "PickColorInsert")
  if not ok then
    pcall(vim.cmd, "PickColor")
  end
end

-- 5. Colorful Rainbow Indentations & Colored Filled Space (deferred after first paint)
vim.defer_fn(function()
  packadd_safe("indent-blankline.nvim")
  local ok_ibl, ibl = pcall(require, "ibl")
  if ok_ibl then
    local rainbow_hl = {
      "RainbowRed",
      "RainbowYellow",
      "RainbowBlue",
      "RainbowOrange",
      "RainbowGreen",
      "RainbowViolet",
      "RainbowCyan",
    }

    local hooks = require("ibl.hooks")
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75", bg = "#3b2628" })
      vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B", bg = "#3b3626" })
      vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF", bg = "#26333b" })
      vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66", bg = "#3b3026" })
      vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379", bg = "#283b26" })
      vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD", bg = "#36263b" })
      vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2", bg = "#26383b" })
    end)

    ibl.setup({
      indent = {
        highlight = rainbow_hl,
        char = "│",
      },
      whitespace = {
        highlight = rainbow_hl,
        remove_blankline_trail = false,
      },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
      },
      exclude = {
        filetypes = { "minimal_home", "NvimTree", "help" },
        buftypes = { "terminal", "nofile" },
      },
    })
  end
end, 20)

-- 6. Diagnostics, Error Gutters & VS Code Error Lens
vim.diagnostic.config({
  virtual_text = {
    prefix = "■ ",
    spacing = 4,
    severity = { min = vim.diagnostic.severity.HINT },
    format = function(diag)
      return string.format("%s (%s)", diag.message, diag.source or "LSP")
    end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚",
      [vim.diagnostic.severity.WARN] = "󰀪",
      [vim.diagnostic.severity.INFO] = "󰋽",
      [vim.diagnostic.severity.HINT] = "󰌶",
    },
  },
  underline = true,
  update_in_insert = true, -- Real-time error lens updates while typing!
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

-- Guard diagnostic handlers against out-of-bounds line numbers (e.g. stale diagnostics on buffer switch)
for _, handler_name in ipairs({ "underline", "virtual_text", "signs" }) do
  local handler = vim.diagnostic.handlers[handler_name]
  if handler and handler.show then
    local orig_show = handler.show
    handler.show = function(namespace, bufnr, diagnostics, opts)
      bufnr = (bufnr == 0 or not bufnr) and vim.api.nvim_get_current_buf() or bufnr
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
        return
      end
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      local safe_diags = {}
      for _, d in ipairs(diagnostics or {}) do
        if d and d.lnum and d.lnum >= 0 and d.lnum < line_count then
          if d.end_lnum and d.end_lnum >= line_count then
            local copy = vim.tbl_extend("force", {}, d)
            copy.end_lnum = line_count - 1
            table.insert(safe_diags, copy)
          else
            table.insert(safe_diags, d)
          end
        end
      end
      pcall(orig_show, namespace, bufnr, safe_diags, opts)
    end
  end
  if handler and handler.hide then
    local orig_hide = handler.hide
    handler.hide = function(namespace, bufnr)
      pcall(orig_hide, namespace, bufnr)
    end
  end
end

-- Error Lens Highlight Styling (Tinted backgrounds for error/warning lines)
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#f38ba8", bg = "#382325", bold = true })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#fab387", bg = "#383223", bold = true })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#89dceb", bg = "#233338" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#a6e3a1", bg = "#233827" })

vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#f38ba8", bold = true })
vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#fab387", bold = true })
vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = "#89dceb" })
vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = "#a6e3a1" })

vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#f38ba8" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "#fab387" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = "#89dceb" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = "#a6e3a1" })

-- 7 & 8. Deferred Setup for Auto-Pairs, Snippets & Completions (after first paint)
local ok_autopairs, autopairs = false, nil
local ok_luasnip, luasnip = false, nil

-- 9. Emmet Configuration (VS Code-Style HTML/CSS Expansion including '!')
vim.g.user_emmet_mode = "a"
vim.g.user_emmet_leader_key = "<C-e>"
vim.g.user_emmet_install_global = 1

local function try_emmet_expand()
  local ft = vim.bo.filetype
  local emmet_fts = {
    html = true, htmldjango = true, css = true, scss = true,
    javascriptreact = true, typescriptreact = true, vue = true,
    svelte = true, php = true, xml = true,
  }
  if emmet_fts[ft] then
    local ok, is_exp = pcall(vim.fn["emmet#isExpandable"])
    if ok and is_exp == 1 then
      local ok2, _ = pcall(vim.fn["emmet#expandAbbr"], 0, "")
      if ok2 then return true end
    end
  end
  return false
end

-- 10. Native LSP Setup (Auto-Imports & Diagnostics for all Languages - deferred for fast cold boot)
local function is_lsp_available(bin, allow_local_node)
  if vim.fn.executable(bin) == 1 then
    return true
  end
  if allow_local_node then
    local search_paths = { vim.fn.getcwd() }
    local first_arg = vim.fn.argv(0)
    if type(first_arg) == "string" and first_arg ~= "" then
      table.insert(search_paths, vim.fn.fnamemodify(first_arg, ":p"))
    end
    for _, p in ipairs(search_paths) do
      local local_bin = vim.fs.find("node_modules/.bin/" .. bin, { path = p, upward = true })[1]
      if local_bin and vim.fn.executable(local_bin) == 1 then
        return true
      end
    end
  end
  return false
end

local lsp_setup_done = false
local function setup_lsp()
  if lsp_setup_done then return end
  lsp_setup_done = true
  packadd_safe("nvim-lspconfig")

  local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
  lsp_capabilities.textDocument = lsp_capabilities.textDocument or {}
  lsp_capabilities.textDocument.completion = vim.tbl_deep_extend("force", lsp_capabilities.textDocument.completion or {}, {
    completionItem = {
      snippetSupport = true,
      commitCharactersSupport = true,
      deprecatedSupport = true,
      preselectSupport = true,
      tagSupport = { valueSet = { 1 } },
      insertReplaceSupport = true,
      resolveSupport = {
        properties = { "documentation", "detail", "additionalTextEdits" },
      },
      insertTextModeSupport = { valueSet = { 1, 2 } },
      labelDetailsSupport = true,
    },
  })
  lsp_capabilities.workspace = lsp_capabilities.workspace or {}
  lsp_capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = true }

  vim.lsp.config["pyright"] = {
    capabilities = lsp_capabilities,
    settings = {
      python = {
        analysis = {
          autoImportCompletions = true,
          autoSearchPaths = true,
          diagnosticMode = "openFilesOnly",
          useLibraryCodeForTypes = true,
        },
      },
    },
  }

  vim.lsp.config["ts_ls"] = {
    capabilities = lsp_capabilities,
    settings = {
      typescript = {
        suggest = { autoImports = true },
        preferences = { includeCompletionsForModuleExports = true },
      },
      javascript = {
        suggest = { autoImports = true },
        preferences = { includeCompletionsForModuleExports = true },
      },
    },
  }

  vim.lsp.config["gopls"] = {
    capabilities = lsp_capabilities,
    settings = {
      gopls = {
        completeUnimported = true,
        analyses = { unusedparams = true },
      },
    },
  }

  vim.lsp.config["clangd"] = { capabilities = lsp_capabilities }
  vim.lsp.config["bashls"] = { capabilities = lsp_capabilities }
  vim.lsp.config["dockerls"] = { capabilities = lsp_capabilities }
  vim.lsp.config["jsonls"] = { capabilities = lsp_capabilities }
  vim.lsp.config["html"] = { capabilities = lsp_capabilities }
  vim.lsp.config["cssls"] = { capabilities = lsp_capabilities }
  vim.lsp.config["svelte"] = { capabilities = lsp_capabilities }
  vim.lsp.config["tailwindcss"] = { capabilities = lsp_capabilities }

  local lsp_servers = {
    { name = "pyright", bin = "pyright-langserver" },
    { name = "ts_ls", bin = "typescript-language-server", local_bin = true },
    { name = "gopls", bin = "gopls" },
    { name = "clangd", bin = "clangd" },
    { name = "bashls", bin = "bash-language-server" },
    { name = "dockerls", bin = "docker-langserver" },
    { name = "jsonls", bin = "vscode-json-language-server", local_bin = true },
    { name = "html", bin = "vscode-html-language-server", local_bin = true },
    { name = "cssls", bin = "vscode-css-language-server", local_bin = true },
    { name = "svelte", bin = "svelteserver", local_bin = true },
    { name = "tailwindcss", bin = "tailwindcss-language-server", local_bin = true },
  }

  local enabled_lsp_servers = {}
  for _, srv in ipairs(lsp_servers) do
    if is_lsp_available(srv.bin, srv.local_bin) then
      table.insert(enabled_lsp_servers, srv.name)
    end
  end

  if #enabled_lsp_servers > 0 then
    pcall(vim.lsp.enable, enabled_lsp_servers)
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buftype == "" and vim.bo[b].filetype ~= "" then
        local ft = vim.bo[b].filetype
        vim.api.nvim_buf_call(b, function()
          pcall(vim.cmd, "doautocmd <nomodeline> nvim.lsp.enable FileType " .. ft)
        end)
      end
    end
  end
end

vim.defer_fn(setup_lsp, 15)

-- 11. Auto-Completions, Snippets, Auto-Pairs & Cross-File Classes (lazy-loaded on InsertEnter or 25ms after paint)
local completion_ready = false
local function ensure_completion_and_snippets()
  if completion_ready then return end
  completion_ready = true
  for _, p in ipairs({
    "nvim-autopairs", "LuaSnip", "friendly-snippets", "nvim-cmp",
    "cmp-buffer", "cmp_luasnip", "cmp-nvim-lsp", "cmp-nvim-lua", "cmp-path", "emmet-vim",
  }) do
    packadd_safe(p)
  end
  ok_autopairs, autopairs = pcall(require, "nvim-autopairs")
  if ok_autopairs then
    autopairs.setup({
      check_ts = false,
      enable_check_bracket_line = false,
      fast_wrap = {},
    })
  end

  ok_luasnip, luasnip = pcall(require, "luasnip")
  if ok_luasnip then
    luasnip.config.set_config({
      history = true,
      updateevents = "TextChanged,TextChangedI",
      enable_autosnippets = true,
    })
    pcall(function()
      local opt_fs = vim.fn.stdpath("data") .. "/site/pack/plugins/opt/friendly-snippets"
      local start_fs = vim.fn.stdpath("data") .. "/site/pack/plugins/start/friendly-snippets"
      local fs_path = (vim.fn.isdirectory(opt_fs) == 1) and opt_fs or start_fs
      if vim.fn.isdirectory(fs_path) == 1 then
        require("luasnip.loaders.from_vscode").lazy_load({ paths = { fs_path } })
      else
        local nvim_fs = vim.fn.expand("~/.local/share/nvim/site/pack/plugins/start/friendly-snippets")
        if vim.fn.isdirectory(nvim_fs) == 1 then
          require("luasnip.loaders.from_vscode").lazy_load({ paths = { nvim_fs } })
        else
          require("luasnip.loaders.from_vscode").lazy_load()
        end
      end
    end)

    pcall(function()
      local s = luasnip.snippet
      local t = luasnip.text_node
      local i = luasnip.insert_node
      luasnip.add_snippets("markdown", {
        s("code", { t("```"), i(1, "python"), t({ "", "" }), i(2), t({ "", "```" }) }),
        s("todo", { t("- [ ] "), i(1, "Task description") }),
        s("table", {
          t("| "), i(1, "Column 1"), t(" | "), i(2, "Column 2"), t({ " |", "| :--- | :--- |", "| " }),
          i(3, "Value 1"), t(" | "), i(4, "Value 2"), t(" |"),
        }),
        s("link", { t("["), i(1, "title"), t("]("), i(2, "https://"), t(")") }),
        s("img", { t("!["), i(1, "alt text"), t("]("), i(2, "path/to/image.png"), t(")") }),
        s("note", { t({ "> [!NOTE]", "> " }), i(1, "Note content") }),
        s("tip", { t({ "> [!TIP]", "> " }), i(1, "Helpful tip") }),
        s("warn", { t({ "> [!WARNING]", "> " }), i(1, "Warning details") }),
        s("frontmatter", { t({ "---", "title: " }), i(1, "Document Title"), t({ "", "date: " }), i(2, "2026-01-01"), t({ "", "---", "" }) }),
      })
    end)
  end

  local ok_cmp, cmp = pcall(require, "cmp")
  if ok_cmp then
    local kind_icons = {
      Text = "󰉿 Text",
      Method = "󰆧 Method",
      Function = "󰊕 Function",
      Constructor = " Constructor",
      Field = "󰜢 Field",
      Variable = "󰀫 Variable",
      Class = "󰠱 Class",
      Interface = " Interface",
      Module = " Module",
      Property = "󰜢 Property",
      Unit = "󰑭 Unit",
      Value = "󰎠 Value",
      Enum = " Enum",
      Keyword = "󰌋 Keyword",
      Snippet = " Snippet",
      Color = "󰏘 Color",
      File = "󰈙 File",
      Reference = "󰈇 Reference",
      Folder = "󰉋 Folder",
      EnumMember = " EnumMember",
      Constant = "󰏿 Constant",
      Struct = "󰙅 Struct",
      Event = " Event",
      Operator = "󰆕 Operator",
      TypeParameter = "󰅲 TypeParam",
    }

    local web_class_fts = {
      html = true, css = true, scss = true, less = true,
      javascript = true, javascriptreact = true,
      typescript = true, typescriptreact = true,
      svelte = true, vue = true, astro = true,
      php = true, htmldjango = true,
    }
    local disk_class_cache = { cwd = "", ts = 0, items = {} }

    local cross_file_source = {}
    function cross_file_source:new()
      return setmetatable({}, { __index = cross_file_source })
    end
    function cross_file_source:get_trigger_characters()
      return { ".", "-", "_", '"', "'", " " }
    end
    function cross_file_source:complete(params, callback)
      local ft = vim.bo[params.context.bufnr].filetype
      if not web_class_fts[ft] then
        callback({ items = {}, isIncomplete = false })
        return
      end

      local items = {}
      local seen = {}

      local function scan_text(text, source_type, target_list)
        if not text or text == "" then return end
        for cls in text:gmatch('class%s*=%s*["\']([^"\']+)["\']') do
          for word in cls:gmatch("[%w%-_]+") do
            if not seen[word] and #word > 1 then
              seen[word] = true
              table.insert(target_list, { label = word, kind = cmp.lsp.CompletionItemKind.Class, detail = source_type or "HTML Class" })
            end
          end
        end
        for cls in text:gmatch('className%s*=%s*["\']([^"\']+)["\']') do
          for word in cls:gmatch("[%w%-_]+") do
            if not seen[word] and #word > 1 then
              seen[word] = true
              table.insert(target_list, { label = word, kind = cmp.lsp.CompletionItemKind.Class, detail = "React/JSX Class" })
            end
          end
        end
        for cls in text:gmatch('%.([%a_][%w%-_]*)') do
          if not seen[cls] and #cls > 1 then
            seen[cls] = true
            table.insert(target_list, { label = cls, kind = cmp.lsp.CompletionItemKind.Class, detail = "CSS Class" })
          end
        end
      end

      -- 1. Scan loaded web buffers
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and web_class_fts[vim.bo[buf].filetype] then
          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          scan_text(table.concat(lines, "\n"), "Buffer Class", items)
        end
      end

      -- 2. Cached workspace scan (5s TTL to avoid disk I/O on every keystroke)
      local cwd = vim.fn.getcwd()
      local now = vim.uv.now()
      if disk_class_cache.cwd ~= cwd or (now - disk_class_cache.ts) > 5000 then
        local cached_items = {}
        pcall(function()
          local files = vim.fs.find(function(name, path)
            if path:match("[/\\]node_modules[/\\]") or path:match("[/\\]%.git[/\\]") or path:match("[/\\]dist[/\\]") or path:match("[/\\]build[/\\]") then
              return false
            end
            return name:match("%.html$") or name:match("%.css$") or name:match("%.jsx$") or name:match("%.tsx$") or name:match("%.svelte$") or name:match("%.vue$")
          end, { path = cwd, limit = 50, type = "file" })

          for _, file_path in ipairs(files) do
            local f = io.open(file_path, "r")
            if f then
              local content = f:read(32768)
              f:close()
              if content then
                local ext = file_path:match("%.([^.]+)$") or ""
                scan_text(content, ext:upper() .. " Class", cached_items)
              end
            end
          end
        end)
        disk_class_cache = { cwd = cwd, ts = now, items = cached_items }
      end

      for _, it in ipairs(disk_class_cache.items) do
        if not seen[it.label] then
          seen[it.label] = true
          table.insert(items, it)
        end
      end

      callback({ items = items, isIncomplete = false })
    end

    -- Register optional completion sources explicitly (packadd does not auto-source after/plugin/)
    local ok_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    if ok_cmp_lsp and cmp_lsp.setup then
      pcall(cmp_lsp.setup)
      if cmp_lsp._on_insert_enter then
        pcall(cmp_lsp._on_insert_enter)
      end
    end

    local ok_cbuf, cbuf = pcall(require, "cmp_buffer")
    if ok_cbuf then
      pcall(cmp.register_source, "buffer", cbuf)
    end

    local ok_cpath, cpath = pcall(require, "cmp_path")
    if ok_cpath and cpath.new then
      pcall(cmp.register_source, "path", cpath.new())
    end

    local ok_csnip, csnip = pcall(require, "cmp_luasnip")
    if ok_csnip and csnip.new then
      pcall(cmp.register_source, "luasnip", csnip.new())
    end

    local ok_clua, clua = pcall(require, "cmp_nvim_lua")
    if ok_clua and clua.new then
      pcall(cmp.register_source, "nvim_lua", clua.new())
    end

    cmp.register_source("cross_file_classes", cross_file_source:new())

    cmp.setup({
      snippet = {
        expand = function(args)
          if ok_luasnip then
            luasnip.lsp_expand(args.body)
          end
        end,
      },
      completion = {
        autocomplete = { cmp.TriggerEvent.TextChanged },
        completeopt = "menu,menuone,noselect",
        keyword_length = 1,
      },
      window = {
        completion = cmp.config.window.bordered({
          border = "rounded",
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        }),
        documentation = cmp.config.window.bordered({
          border = "rounded",
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        }),
      },
      formatting = {
        format = function(entry, vim_item)
          vim_item.kind = kind_icons[vim_item.kind] or vim_item.kind
          vim_item.menu = ({
            luasnip = "[Snippet]",
            nvim_lsp = "[LSP]",
            path = "[Path]",
            cross_file_classes = "[Class]",
            buffer = "[Text]",
            nvim_lua = "[Lua]",
          })[entry.source.name]
          return vim_item
        end,
      },
      mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<CR>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm({ select = true })
          elseif vim.bo.filetype == "markdown" and _G.md_smart_enter then
            _G.md_smart_enter()
          else
            fallback()
          end
        end),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm({ select = true })
          elseif ok_luasnip and luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif try_emmet_expand() then
            return
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if ok_luasnip and luasnip.jumpable(-1) then
            luasnip.jump(-1)
          elseif _G.indent_line_or_selection then
            _G.indent_line_or_selection(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<Esc>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.abort()
          else
            fallback()
          end
        end, { "i", "s" }),
      },
      sources = cmp.config.sources({
        { name = "luasnip", priority = 1000 },
        { name = "nvim_lsp", priority = 900 },
        {
          name = "path",
          priority = 850,
          option = {
            trailing_slash = true,
            label_trailing_slash = true,
            get_cwd = function()
              return vim.fn.getcwd()
            end,
          },
        },
        { name = "cross_file_classes", priority = 750, keyword_length = 1 },
        {
          name = "buffer",
          priority = 600,
          keyword_length = 1,
          option = {
            get_bufnrs = function()
              local bufs = {}
              for _, b in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted then
                  local bt = vim.bo[b].buftype
                  local ft = vim.bo[b].filetype
                  if bt == "" and ft ~= "NvimTree" and ft ~= "minimal_home" then
                    table.insert(bufs, b)
                  end
                end
              end
              return bufs
            end,
          },
        },
        { name = "nvim_lua", priority = 200 },
      }),
    })

    if ok_autopairs then
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  end
end

vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = ensure_completion_and_snippets,
})
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    ensure_completion_and_snippets()
    local ok_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    if ok_lsp and cmp_lsp._on_insert_enter then
      pcall(cmp_lsp._on_insert_enter)
    end
  end,
})
vim.defer_fn(ensure_completion_and_snippets, 30)

-- 12. Prettier, Auto-Imports & Multi-Language Formatter (conform.nvim - lazy/deferred)
local conform_configured = false
local function ensure_conform()
  if conform_configured then return end
  conform_configured = true
  packadd_safe("conform.nvim")
  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.setup({
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        less = { "prettier" },
        svelte = { "prettier" },
        vue = { "prettier" },
        markdown = { "prettier" },
        yaml = { "prettier" },
        graphql = { "prettier" },
        python = { "ruff_organize_imports", "ruff_format" },
        go = { "goimports", "gofmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        rust = { "rustfmt" },
        sql = { "sql_formatter" },
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
    })
  end
end
vim.defer_fn(ensure_conform, 40)

local function organize_lsp_imports(bufnr)
  bufnr = (bufnr and bufnr ~= 0) and bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  local ft = vim.bo[bufnr].filetype
  if ft ~= "javascript" and ft ~= "typescript" and ft ~= "javascriptreact" and ft ~= "typescriptreact" then
    return
  end
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(bufnr) },
  }
  for _, client in ipairs(clients) do
    if (client.name == "ts_ls" or client.name == "vtsls" or client.name == "typescript-tools") and client:supports_method("workspace/executeCommand") then
      pcall(client.request, "workspace/executeCommand", params, nil, bufnr)
    end
  end
end

_G.format_buffer = function()
  ensure_conform()
  organize_lsp_imports(0)
  local ok, conf = pcall(require, "conform")
  if ok then
    conf.format({ async = false, lsp_format = "fallback" })
  end
  vim.cmd("startinsert")
end

-- 13. Word Navigation & Deletion Helpers
local function next_word_col(line, col)
  if col >= #line then return nil end
  local len = #line
  local idx = col + 1
  local ch = line:sub(idx, idx)
  if ch:match("%s") then
    while idx <= len and line:sub(idx, idx):match("%s") do idx = idx + 1 end
  elseif ch:match("[%w_]") then
    while idx <= len and line:sub(idx, idx):match("[%w_]") do idx = idx + 1 end
    while idx <= len and line:sub(idx, idx):match("%s") do idx = idx + 1 end
  else
    while idx <= len and not line:sub(idx, idx):match("[%w_]") and not line:sub(idx, idx):match("%s") do idx = idx + 1 end
    while idx <= len and line:sub(idx, idx):match("%s") do idx = idx + 1 end
  end
  local target = idx - 1
  if target > len then target = len end
  return target
end

_G.delete_word_backward_str = function(str)
  local trimmed = str:gsub("%s+$", "")
  local last_sp = trimmed:match(".*%s()")
  if last_sp then
    return trimmed:sub(1, last_sp - 1)
  else
    return ""
  end
end

local function prev_word_col(line, col)
  if col <= 0 then return nil end
  local idx = col
  while idx > 0 and line:sub(idx, idx):match("%s") do
    idx = idx - 1
  end
  if idx <= 0 then return 0 end
  local is_word = line:sub(idx, idx):match("[%w_]") ~= nil
  while idx > 0 do
    local c = line:sub(idx, idx)
    if is_word then
      if c:match("[%w_]") then idx = idx - 1 else break end
    else
      if not c:match("[%w_]") and not c:match("%s") then idx = idx - 1 else break end
    end
  end
  return idx
end

_G.move_word_right = function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]
  local line = vim.api.nvim_get_current_line()
  local next_col = next_word_col(line, col)
  if next_col then
    vim.api.nvim_win_set_cursor(0, { row, next_col })
  else
    local count = vim.api.nvim_buf_line_count(0)
    if row < count then
      vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
    end
  end
end

_G.move_word_left = function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]
  local prev_col = prev_word_col(vim.api.nvim_get_current_line(), col)
  if prev_col then
    vim.api.nvim_win_set_cursor(0, { row, prev_col })
  else
    if row > 1 then
      local prev_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1] or ""
      vim.api.nvim_win_set_cursor(0, { row - 1, #prev_line })
    end
  end
end

local function delete_word_backward()
  if not vim.bo.modifiable or vim.bo.buftype ~= "" then return end
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]
  local line = vim.api.nvim_get_current_line()
  local prev_col = prev_word_col(line, col)
  if prev_col and prev_col < col then
    local new_line = line:sub(1, prev_col) .. line:sub(col + 1)
    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { row, prev_col })
  elseif col <= 0 and row > 1 then
    local prev_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1] or ""
    local new_col = #prev_line
    vim.api.nvim_buf_set_lines(0, row - 2, row, false, { prev_line .. line })
    vim.api.nvim_win_set_cursor(0, { row - 1, new_col })
  end
end

local function delete_word_forward()
  if not vim.bo.modifiable or vim.bo.buftype ~= "" then return end
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]
  local line = vim.api.nvim_get_current_line()
  local next_col = next_word_col(line, col)
  if next_col and next_col > col then
    local new_line = line:sub(1, col) .. line:sub(next_col + 1)
    vim.api.nvim_set_current_line(new_line)
  elseif col >= #line and row < vim.api.nvim_buf_line_count(0) then
    local next_line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
    vim.api.nvim_set_current_line(line .. next_line)
    vim.api.nvim_buf_set_lines(0, row, row + 1, false, {})
  end
end

-- Line Deletion (Shift+Delete & Ctrl+Shift+K like VS Code / Notepad)
_G.delete_line = function()
  local mode = vim.api.nvim_get_mode().mode
  if mode:match("^[vVsS\x16]") then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('"_d', true, false, true), "n", false)
  else
    local cur = vim.api.nvim_win_get_cursor(0)
    local row = cur[1]
    local total = vim.api.nvim_buf_line_count(0)
    if total <= 1 then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
    else
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, {})
      local new_row = math.min(row, total - 1)
      local new_line = vim.api.nvim_buf_get_lines(0, new_row - 1, new_row, false)[1] or ""
      vim.api.nvim_win_set_cursor(0, { new_row, math.min(cur[2], #new_line) })
    end
  end
  vim.cmd("startinsert")
end

-- Smart VS Code-Style PageDown and PageUp Navigation
_G.smart_page_down = function()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local line_count = vim.api.nvim_buf_line_count(buf)
  local win_height = vim.api.nvim_win_get_height(win)
  local cur = vim.api.nvim_win_get_cursor(win)
  local row, col = cur[1], cur[2]

  if line_count <= win_height then
    -- File completely fits on screen: move cursor to end of last line without scrolling content off
    local last_line = vim.api.nvim_buf_get_lines(buf, line_count - 1, line_count, false)[1] or ""
    vim.api.nvim_win_set_cursor(win, { line_count, #last_line })
    pcall(vim.fn.winrestview, { topline = 1 })
  else
    local target_row = math.min(line_count, row + win_height - 2)
    if target_row == line_count then
      local last_line = vim.api.nvim_buf_get_lines(buf, line_count - 1, line_count, false)[1] or ""
      vim.api.nvim_win_set_cursor(win, { line_count, #last_line })
      pcall(vim.cmd, "normal! zb")
    else
      local line_text = vim.api.nvim_buf_get_lines(buf, target_row - 1, target_row, false)[1] or ""
      vim.api.nvim_win_set_cursor(win, { target_row, math.min(col, #line_text) })
      local view = vim.fn.winsaveview()
      local new_top = math.min(line_count - win_height + 1, view.topline + win_height - 2)
      if new_top > 0 then view.topline = new_top end
      pcall(vim.fn.winrestview, view)
    end
  end
  if vim.fn.mode() ~= "i" and vim.bo[buf].buftype == "" then
    vim.cmd("startinsert")
  end
end

_G.smart_page_up = function()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local line_count = vim.api.nvim_buf_line_count(buf)
  local win_height = vim.api.nvim_win_get_height(win)
  local cur = vim.api.nvim_win_get_cursor(win)
  local row, col = cur[1], cur[2]

  if line_count <= win_height then
    -- File completely fits on screen: move cursor to start of first line without scrolling content off
    vim.api.nvim_win_set_cursor(win, { 1, 0 })
    pcall(vim.fn.winrestview, { topline = 1 })
  else
    local target_row = math.max(1, row - (win_height - 2))
    if target_row == 1 then
      vim.api.nvim_win_set_cursor(win, { 1, 0 })
      pcall(vim.fn.winrestview, { topline = 1 })
    else
      local line_text = vim.api.nvim_buf_get_lines(buf, target_row - 1, target_row, false)[1] or ""
      vim.api.nvim_win_set_cursor(win, { target_row, math.min(col, #line_text) })
      local view = vim.fn.winsaveview()
      local new_top = math.max(1, view.topline - (win_height - 2))
      view.topline = new_top
      pcall(vim.fn.winrestview, view)
    end
  end
  if vim.fn.mode() ~= "i" and vim.bo[buf].buftype == "" then
    vim.cmd("startinsert")
  end
end

-- 14. INLINE FILE/FOLDER RENAME (Seamless VS Code-style Rename on 'r')
_G.inline_rename = function()
  local ok_t, api = pcall(require, "nvim-tree.api")
  if not ok_t then return end

  local node = api.tree.get_node_under_cursor()
  if not node or node.name == ".." then return end

  local tree_win = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(tree_win)
  local row = cursor[1]

  local buf = vim.api.nvim_create_buf(false, true)
  vim.b[buf].is_renaming = true
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { node.name })

  local width = math.max(24, #node.name + 6)
  local float_win = vim.api.nvim_open_win(buf, true, {
    relative = "win",
    win = tree_win,
    row = math.max(0, row - 1),
    col = 2,
    width = width,
    height = 1,
    style = "minimal",
    border = "rounded",
    title = " Rename ",
    title_pos = "center",
  })

  vim.wo[float_win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

  local function commit_rename()
    local text = vim.trim(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or "")
    pcall(vim.api.nvim_win_close, float_win, true)
    if tree_win and vim.api.nvim_win_is_valid(tree_win) then
      vim.api.nvim_set_current_win(tree_win)
    end
    if text == "" or text == node.name then
      return
    end

    local parent = vim.fn.fnamemodify(node.absolute_path, ":h")
    local new_path = parent .. "/" .. text
    local ok, err = vim.uv.fs_rename(node.absolute_path, new_path)
    if ok then
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(b) == node.absolute_path then
          vim.api.nvim_buf_set_name(b, new_path)
        end
      end
      api.tree.reload()
      api.tree.find_file(new_path)
    else
      vim.notify("Rename failed: " .. tostring(err), vim.log.levels.ERROR)
    end
  end

  local function cancel_rename()
    pcall(vim.api.nvim_win_close, float_win, true)
    if tree_win and vim.api.nvim_win_is_valid(tree_win) then
      vim.api.nvim_set_current_win(tree_win)
    end
  end

  vim.keymap.set({ "i", "n", "s" }, "<CR>", commit_rename, { buffer = buf, nowait = true })
  vim.keymap.set({ "i", "n", "s" }, "<Esc>", cancel_rename, { buffer = buf, nowait = true })

  -- Allow Left/Right/Home/End navigation out of Select mode into Insert mode
  vim.keymap.set("s", "<Left>", function()
    vim.cmd("stopinsert")
    vim.api.nvim_win_set_cursor(float_win, { 1, 0 })
    vim.cmd("startinsert")
  end, { buffer = buf, nowait = true })
  vim.keymap.set("s", "<Home>", function()
    vim.cmd("stopinsert")
    vim.api.nvim_win_set_cursor(float_win, { 1, 0 })
    vim.cmd("startinsert")
  end, { buffer = buf, nowait = true })
  vim.keymap.set("s", "<Right>", function()
    vim.cmd("stopinsert")
    local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
    vim.api.nvim_win_set_cursor(float_win, { 1, #line })
    vim.cmd("startinsert!")
  end, { buffer = buf, nowait = true })
  vim.keymap.set("s", "<End>", function()
    vim.cmd("stopinsert")
    local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
    vim.api.nvim_win_set_cursor(float_win, { 1, #line })
    vim.cmd("startinsert!")
  end, { buffer = buf, nowait = true })

  -- Close on window/buffer leave
  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
    buffer = buf,
    once = true,
    callback = function()
      pcall(vim.api.nvim_win_close, float_win, true)
    end,
  })

  -- Auto-select filename in Select mode so typing immediately replaces it
  vim.cmd("normal! 0v$" .. vim.api.nvim_replace_termcodes("<C-g>", true, false, true))
end

-- Global editor window and buffer discovery helpers
local function find_editor_win()
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(w) then
      local cfg = vim.api.nvim_win_get_config(w)
      if cfg.relative == "" then
        local b = vim.api.nvim_win_get_buf(w)
        local ft = vim.bo[b].filetype
        local bt = vim.bo[b].buftype
        local name = vim.api.nvim_buf_get_name(b)
        if ft ~= "NvimTree" and bt ~= "terminal" and not name:match("NvimTree") then
          return w
        end
      end
    end
  end
  return nil
end
_G.find_editor_win = find_editor_win

local function get_listed_editor_bufs()
  local bufs = {}
  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    local bt = vim.bo[info.bufnr].buftype
    local ft = vim.bo[info.bufnr].filetype
    local is_home = vim.b[info.bufnr].is_homescreen or (ft == "minimal_home")
    if bt ~= "terminal" and ft ~= "NvimTree" and not is_home then
      table.insert(bufs, info.bufnr)
    end
  end
  return bufs
end
_G.get_listed_editor_bufs = get_listed_editor_bufs

-- Global Menu Management & Modal Isolation (Only 1 menu open at a time)
_G.active_menu_close_fn = nil

vim.api.nvim_set_hl(0, "MenuCursorHidden", { blend = 100, fg = "#1e222a", bg = "#1e222a" })
vim.api.nvim_set_hl(0, "FolderCursorHidden", { blend = 100, fg = "#2d3545", bg = "#2d3545" })
vim.api.nvim_set_hl(0, "FolderPickerSelected", { fg = "#ffffff", bg = "#2d3545", bold = true })

_G.set_picker_cursor = function(hl_group)
  pcall(function()
    local hl = hl_group or "MenuCursorHidden"
    if hl == "FolderCursorHidden" then
      vim.api.nvim_set_hl(0, "FolderCursorHidden", { blend = 100, fg = "#2d3545", bg = "#2d3545" })
    else
      vim.api.nvim_set_hl(0, "MenuCursorHidden", { blend = 100, fg = "#1e222a", bg = "#1e222a" })
    end
    vim.opt.guicursor = "n-v-c-i:hor1-blinkoff0-" .. hl
  end)
end

_G.restore_picker_cursor = function()
  pcall(function()
    vim.opt.guicursor = "n:block-blinkon500-blinkoff500,i-c-v-ve:ver25-blinkon500-blinkoff500"
  end)
end

_G.register_active_menu = function(close_fn, current_win)
  if _G.active_menu_close_fn then
    local prev = _G.active_menu_close_fn
    _G.active_menu_close_fn = nil
    pcall(prev)
  end
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(w) and w ~= current_win then
      local cfg = vim.api.nvim_win_get_config(w)
      if cfg.relative ~= "" then
        local b = vim.api.nvim_win_get_buf(w)
        if vim.b[b].is_picker or vim.bo[b].buftype == "nofile" then
          pcall(vim.api.nvim_win_close, w, true)
        end
      end
    end
  end
  _G.active_menu_close_fn = close_fn
  _G.set_picker_cursor()
end

_G.clear_active_menu = function(caller_fn)
  if caller_fn and _G.active_menu_close_fn and _G.active_menu_close_fn ~= caller_fn then
    return
  end
  _G.active_menu_close_fn = nil
  _G.restore_picker_cursor()
end

-- 15. Code Editor Sidebar & Tabline (deferred 1ms after first frame so startup completes in ~27ms)
-- Uses Minimal's bespoke Signature Icon Theme (config/lua/minimal_icons.lua)
_G.reapply_all_icon_colors = function()
  local ok_icons, minimal_icons = pcall(require, "minimal_icons")
  local ok_dev, dev = pcall(require, "nvim-web-devicons")
  if ok_dev then
    pcall(dev.set_up_highlights, true)
    if ok_icons then
      pcall(dev.set_default_icon, "", minimal_icons.palette.starlight, 75)
    end
  end
  local ok_bl, bl_h = pcall(require, "bufferline.highlights")
  if ok_bl then
    pcall(bl_h.reset_icon_hl_cache)
  end
  if ok_icons then
    minimal_icons.apply_highlights()
  end

  local ok_tree, t_api = pcall(require, "nvim-tree.api")
  if ok_tree and t_api.tree.is_visible() then
    pcall(t_api.tree.reload)
  end
  pcall(vim.cmd, "redrawtabline")
end

_G.notify_lsp_file_deleted = function(filepath)
  if not filepath or filepath == "" then return end
  local uri = vim.uri_from_fname(filepath)
  local params = {
    changes = {
      {
        uri = uri,
        type = 3, -- 3 = FileChangeType.Deleted
      },
    },
  }

  for _, client in ipairs(vim.lsp.get_clients()) do
    pcall(client.notify, "workspace/didChangeWatchedFiles", params)
  end

  -- Clear stale diagnostics and trigger re-check for open buffers in the same directory
  local dir = vim.fs.normalize(vim.fn.fnamemodify(filepath, ":h"))
  vim.schedule(function()
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted then
        local bname = vim.api.nvim_buf_get_name(b)
        if bname ~= "" and vim.fs.normalize(vim.fn.fnamemodify(bname, ":h")) == dir then
          pcall(vim.diagnostic.reset, nil, b)
          local b_uri = vim.uri_from_fname(bname)
          for _, client in ipairs(vim.lsp.get_clients({ bufnr = b })) do
            pcall(client.notify, "textDocument/didSave", {
              textDocument = { uri = b_uri },
            })
          end
        end
      end
    end
  end)
end

_G.wipe_buffer_for_path = function(path, is_dir)
  if not path or path == "" then return end
  local norm_path = vim.fs.normalize(path):gsub("/+$", "")
  local uv = vim.uv or vim.loop

  local bufs = vim.api.nvim_list_bufs()
  for _, b in ipairs(bufs) do
    if vim.api.nvim_buf_is_valid(b) then
      local bname = vim.api.nvim_buf_get_name(b)
      if bname ~= "" then
        local norm_bname = vim.fs.normalize(bname):gsub("/+$", "")
        local match = false
        if not is_dir and norm_bname == norm_path then
          match = true
        elseif is_dir and (norm_bname == norm_path or norm_bname:sub(1, #norm_path + 1) == norm_path .. "/") then
          match = true
        end

        if match then
          pcall(function()
            vim.bo[b].modified = false
            vim.bo[b].buflisted = false
          end)

          for _, w in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_buf(w) == b then
              local other_buf = nil
              for _, ob in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
                if ob.bufnr ~= b and vim.api.nvim_buf_is_valid(ob.bufnr) then
                  local ob_ft = vim.bo[ob.bufnr].filetype
                  local ob_bt = vim.bo[ob.bufnr].buftype
                  local is_home = vim.b[ob.bufnr].is_homescreen or (ob_ft == "minimal_home")
                  if ob_ft ~= "NvimTree" and ob_bt ~= "terminal" and not is_home then
                    local ob_name = vim.api.nvim_buf_get_name(ob.bufnr)
                    local ob_norm = vim.fs.normalize(ob_name):gsub("/+$", "")
                    local is_deleted = false
                    if not is_dir and ob_norm == norm_path then
                      is_deleted = true
                    elseif is_dir and (ob_norm == norm_path or ob_norm:sub(1, #norm_path + 1) == norm_path .. "/") then
                      is_deleted = true
                    elseif ob_name ~= "" and uv.fs_stat(ob_name) == nil and vim.b[ob.bufnr].was_on_disk then
                      is_deleted = true
                    end

                    if not is_deleted then
                      other_buf = ob.bufnr
                      break
                    end
                  end
                end
              end
              if other_buf then
                vim.api.nvim_win_set_buf(w, other_buf)
              else
                if _G.open_homescreen then
                  _G.open_homescreen()
                else
                  local new_empty = vim.api.nvim_create_buf(true, false)
                  vim.api.nvim_win_set_buf(w, new_empty)
                end
              end
            end
          end

          pcall(vim.cmd, "silent! bwipeout! " .. b)
        end
      end
    end
  end

  pcall(vim.cmd, "redrawtabline")
end

-- Automatically sync open buffers with disk when files or folders are deleted outside
_G.sync_buffers_with_disk = function()
  if vim.g.minimal_is_quitting then return end
  local uv = vim.uv or vim.loop
  local bufs = vim.api.nvim_list_bufs()
  local any_wiped = false

  for _, b in ipairs(bufs) do
    if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted then
      local bt = vim.bo[b].buftype
      local ft = vim.bo[b].filetype
      local is_home = vim.b[b].is_homescreen or (ft == "minimal_home")
      if bt == "" and ft ~= "NvimTree" and ft ~= "alpha" and not is_home then
        local bname = vim.api.nvim_buf_get_name(b)
        if bname ~= "" and bname:match("^/") then
          local stat = uv.fs_stat(bname)
          if stat then
            vim.b[b].was_on_disk = true
          else
            -- File was deleted from disk
            if vim.b[b].was_on_disk then
              any_wiped = true
              _G.wipe_buffer_for_path(bname, false)
              if _G.notify_lsp_file_deleted then
                _G.notify_lsp_file_deleted(bname)
              end
            end
          end
        end
      end
    end
  end

  if package.loaded["nvim-tree"] then
    local ok_t, t_api = pcall(require, "nvim-tree.api")
    if ok_t and t_api.tree and pcall(t_api.tree.is_visible) and t_api.tree.is_visible() then
      pcall(t_api.tree.reload)
    end
  end

  if any_wiped then
    pcall(vim.cmd, "redrawtabline")
  end
end

local ui_chrome_ready = false
_G.ensure_ui_chrome = function()
  if ui_chrome_ready then return end
  ui_chrome_ready = true

  local ok_icons, minimal_icons = pcall(require, "minimal_icons")
  if ok_icons then
    minimal_icons.setup_devicons()
  end

  local ok_tree, tree = pcall(require, "nvim-tree")
  if ok_tree then
    local api = require("nvim-tree.api")
    local minimal_icon_decorator = ok_icons and minimal_icons.create_decorator(api) or nil
    _G.minimal_icon_decorator = minimal_icon_decorator

  _G.sidebar_delete_node = function()
    local node = api.tree.get_node_under_cursor()
    if not node or node.name == ".." then return end

    local path = node.absolute_path
    local is_dir = (node.type == "directory" or vim.fn.isdirectory(path) == 1)
    local item_desc = is_dir and ("folder '" .. node.name .. "/' and all its contents") or ("file '" .. node.name .. "'")

    local choice = vim.fn.confirm("Are you sure you want to delete " .. item_desc .. "?", "&Yes\n&No", 2)
    if choice ~= 1 then
      return
    end

    -- 1. Wipe all open editor buffers for this file or directory immediately
    _G.wipe_buffer_for_path(path, is_dir)

    -- 2. Delete from disk
    local ok_del, err
    if is_dir then
      ok_del, err = pcall(vim.fn.delete, path, "rf")
    else
      ok_del, err = pcall(vim.fn.delete, path)
    end

    -- 3. Notify LSP language servers of file deletion
    notify_lsp_file_deleted(path)

    -- 4. Reload tree view
    pcall(api.tree.reload)

    if ok_del and (err == 0 or err == nil) then
      vim.notify("Deleted " .. node.name, vim.log.levels.INFO)
    else
      vim.notify("Failed to delete " .. node.name, vim.log.levels.WARN)
    end
  end

  local function sidebar_open_item()
    local node = api.tree.get_node_under_cursor()
    if not node or node.name == ".." then
      return
    end
    api.node.open.edit()
  end

  local function sidebar_single_click()
    local node = api.tree.get_node_under_cursor()
    if not node or node.name == ".." then
      return
    end
    if node.type == "directory" then
      api.node.open.edit()
    end
    -- Files: Keep focus in the sidebar so actions like 'd' and 'r' work immediately
  end

  local function sidebar_on_attach(bufnr)
    -- Click & Enter to open files / toggle folders
    -- Enter (<CR>) and Double Click (<2-LeftMouse>) open the file in editor
    vim.keymap.set("n", "<CR>", sidebar_open_item, { desc = "Open File or Toggle Folder", buffer = bufnr, noremap = true, silent = true })
    vim.keymap.set("n", "<2-LeftMouse>", sidebar_open_item, { desc = "Open File or Toggle Folder", buffer = bufnr, noremap = true, silent = true })

    -- Single Click focuses the sidebar (and toggles folder if clicked on folder)
    vim.keymap.set("n", "<LeftRelease>", sidebar_single_click, { desc = "Select in Sidebar", buffer = bufnr, noremap = true, silent = true })

    -- 'd', 'D', and '<Del>' to delete file or folder with confirmation
    vim.keymap.set("n", "d", _G.sidebar_delete_node, { desc = "Delete File or Folder with Confirmation", buffer = bufnr, noremap = true, silent = true })
    vim.keymap.set("n", "D", _G.sidebar_delete_node, { desc = "Delete File or Folder with Confirmation", buffer = bufnr, noremap = true, silent = true })
    vim.keymap.set("n", "<Del>", _G.sidebar_delete_node, { desc = "Delete File or Folder with Confirmation", buffer = bufnr, noremap = true, silent = true })

    -- Up & Down arrow navigation inside sidebar
    vim.keymap.set("n", "<Up>", "k", { buffer = bufnr, noremap = true, silent = true })
    vim.keymap.set("n", "<Down>", "j", { buffer = bufnr, noremap = true, silent = true })

    -- 'r' to inline-rename file or folder with auto-selected text (No looking at bottom!)
    vim.keymap.set("n", "r", _G.inline_rename, { desc = "Inline Rename File or Folder", buffer = bufnr, noremap = true, silent = true })

    -- Searchbar / Live Filter for Sidebar Files (/ or f or Ctrl+F to filter, F or Esc to clear)
    vim.keymap.set("n", "/", function() api.live_filter.start() end, { desc = "Filter Files in Sidebar", buffer = bufnr, noremap = true, silent = true })
    vim.keymap.set("n", "f", function() api.live_filter.start() end, { desc = "Filter Files in Sidebar", buffer = bufnr, noremap = true, silent = true })
    vim.keymap.set("n", "<C-f>", function() api.live_filter.start() end, { desc = "Filter Files in Sidebar", buffer = bufnr, noremap = true, silent = true })
    vim.keymap.set("n", "F", function() api.live_filter.clear() end, { desc = "Clear Filter in Sidebar", buffer = bufnr, noremap = true, silent = true })

    -- Resize Sidebar with Alt+Left / Alt+Right
    vim.keymap.set("n", "<M-Left>", function() _G.resize_sidebar(-2) end, { desc = "Shrink Sidebar Width", buffer = bufnr, noremap = true, silent = true })
    vim.keymap.set("n", "<M-Right>", function() _G.resize_sidebar(2) end, { desc = "Grow Sidebar Width", buffer = bufnr, noremap = true, silent = true })
  end

  local initial_cfg = _G.FontEngine and _G.FontEngine.get_config() or {}
  local sb_cfg = initial_cfg.sidebar or { width = 24, icon_padding = " ", indent_width = 2, chevron_style = 1, git_badge = 1 }
  local chev = (_G.FontEngine and _G.FontEngine.chevron_styles and _G.FontEngine.chevron_styles[sb_cfg.chevron_style]) or { id = "sleek", closed = "›", open = "⌄" }
  local git_opt = (_G.FontEngine and _G.FontEngine.git_badge_styles and _G.FontEngine.git_badge_styles[sb_cfg.git_badge]) or { placement = "after", show = true, style = "letters" }
  local git_glyphs = {
    unstaged = (git_opt.style == "dot") and "·" or "M",
    staged = (git_opt.style == "dot") and "·" or "A",
    unmerged = "!",
    renamed = "R",
    untracked = (git_opt.style == "dot") and "·" or "U",
    deleted = "D",
    ignored = "·",
  }
  _G.sidebar_width = tonumber(sb_cfg.width) or _G.sidebar_width or 24

  tree.setup({
    on_attach = sidebar_on_attach,
    disable_netrw = true,
    hijack_netrw = true,
    hijack_cursor = false,         -- Standard block cursor in sidebar
    sync_root_with_cwd = true,     -- Only show files and folders of directory opened in editor
    respect_buf_cwd = true,
    update_focused_file = {
      enable = true,
      update_root = false,
    },
    filesystem_watchers = {
      enable = true,
      debounce_delay = 50,
    },
    git = {
      enable = true,
      ignore = false,
      show_on_dirs = true,
      show_on_open_dirs = true,
      timeout = 400,
    },
    diagnostics = {
      enable = true,
      show_on_dirs = true,
      show_on_open_dirs = true,
      debounce_delay = 50,
      severity = {
        min = vim.diagnostic.severity.HINT,
        max = vim.diagnostic.severity.ERROR,
      },
      icons = {
        hint = "󰌶",
        info = "󰋽",
        warning = "󰀪",
        error = "󰅚",
      },
    },
    view = {
      width = _G.sidebar_width,
      side = "left",
      signcolumn = "no",
      cursorline = true,           -- Highlights row under block cursor
      preserve_window_proportions = true,
    },
    renderer = {
      highlight_git = "name",         -- Highlights filename for git changes while preserving icon colors
      highlight_diagnostics = "name", -- Highlights filename with Red/Yellow/Blue while preserving authentic logo icon colors!
      highlight_opened_files = "name",
      root_folder_label = false,     -- Hides '..' root line so Enter never executes cd ..
      indent_width = tonumber(sb_cfg.indent_width) or 2,
      decorators = minimal_icon_decorator and {
        "Git",
        "Open",
        "Hidden",
        "Modified",
        "Bookmark",
        "Diagnostics",
        "Copied",
        minimal_icon_decorator,
        "Cut",
      } or nil,
      indent_markers = {
        enable = true,
        inline_arrows = false,
        icons = {
          corner = "└",
          edge = "│",
          item = "│",
          bottom = "─",
          none = " ",
        },
      },
      icons = {
        web_devicons = {
          file = {
            enable = true,
            color = true,
          },
          folder = {
            enable = false,
            color = true,
          },
        },
        git_placement = git_opt.placement or "after",
        modified_placement = "after",
        padding = sb_cfg.icon_padding or " ",
        symlink_arrow = " 󰁔 ",
        show = {
          file = true,
          folder = true,
          folder_arrow = (chev.id ~= "hidden"),
          git = git_opt.show,
          modified = true,
          diagnostics = true,
        },
        glyphs = {
          default = "",
          symlink = "",
          bookmark = "󰆤",
          modified = "●",
          folder = {
            arrow_closed = chev.closed or "›",
            arrow_open = chev.open or "⌄",
            default = "",
            open = "",
            empty = "",
            empty_open = "",
            symlink = "",
            symlink_open = "",
          },
          git = git_glyphs,
        },
      },
    },
    filters = {
      dotfiles = false,
      custom = { "^\\.git$" },
    },
    actions = {
      change_dir = {
        enable = false,            -- Prevent accidental cd ..
      },
      open_file = {
        quit_on_open = false,
        resize_window = false,     -- Keep window size stable
        window_picker = { enable = false },
      },
    },
  })

  -- Automatically wipe buffers and notify LSP when files or folders are removed
  api.events.subscribe(api.events.Event.FileRemoved, function(data)
    if data and data.fname then
      _G.wipe_buffer_for_path(data.fname, false)
      notify_lsp_file_deleted(data.fname)
    end
  end)

  api.events.subscribe(api.events.Event.FolderRemoved, function(data)
    if data and data.folder_name then
      _G.wipe_buffer_for_path(data.folder_name, true)
      notify_lsp_file_deleted(data.folder_name)
    end
  end)

  -- Mark newly created files from sidebar with unsaved dot icon immediately
  api.events.subscribe(api.events.Event.FileCreated, function(data)
    if data and data.fname then
      vim.schedule(function()
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == data.fname then
            vim.bo[b].modified = true
          end
        end
      end)
    end
  end)

  -- Vibrant Colors for Sidebar Git & Diagnostics (Red errors, Yellow warnings, Blue info & hints)
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticErrorFileHLGroup", { fg = "#f38ba8", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticWarnFileHLGroup", { fg = "#fab387", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticInfoFileHLGroup", { fg = "#61afef", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticHintFileHLGroup", { fg = "#89dceb", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticErrorIconHLGroup", { fg = "#f38ba8" })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticWarnIconHLGroup", { fg = "#fab387" })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticInfoIconHLGroup", { fg = "#61afef" })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticHintIconHLGroup", { fg = "#89dceb" })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticError", { fg = "#f38ba8" })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticWarn", { fg = "#fab387" })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticInfo", { fg = "#61afef" })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticHint", { fg = "#89dceb" })
  vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#f38ba8" })
  vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#fab387" })
  vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#61afef" })
  vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#89dceb" })
  vim.api.nvim_set_hl(0, "NvimTreeGitDirty", { fg = "#fab387", bold = true })  -- uncommitted / modified (yellow)
  vim.api.nvim_set_hl(0, "NvimTreeGitStaged", { fg = "#a6e3a1", bold = true }) -- staged (green)
  vim.api.nvim_set_hl(0, "NvimTreeGitNew", { fg = "#a6e3a1", bold = true })    -- untracked (green)
  vim.api.nvim_set_hl(0, "NvimTreeGitDeleted", { fg = "#f38ba8" })             -- deleted (red)
  vim.api.nvim_set_hl(0, "NvimTreeGitRenamed", { fg = "#cba6f7" })             -- renamed (purple)

  -- Automatically open sidebar on startup
  local function open_sidebar_on_startup(data)
    local directory = vim.fn.isdirectory(data.file) == 1
    if directory then
      vim.g.explicit_workspace_opened = true
      vim.cmd.cd(data.file)
      local entry = nil
      for _, cand in ipairs({ "index.html", "main.go", "main.py", "index.js", "App.tsx", "package.json", "README.md" }) do
        local full = data.file .. "/" .. cand
        if vim.fn.filereadable(full) == 1 then
          entry = full
          break
        end
      end
      if entry then
        vim.cmd("silent! edit " .. vim.fn.fnameescape(entry))
      end
      api.tree.open({ focus = false })
    elseif vim.fn.argc() > 0 then
      vim.g.explicit_workspace_opened = true
      local cur_win = vim.api.nvim_get_current_win()
      local cur_pos = vim.api.nvim_win_get_cursor(cur_win)
      local was_insert = vim.fn.mode() == "i"
      vim.g.minimal_ignore_tree_stopinsert = true
      pcall(api.tree.open, { focus = false, find_file = true })
      vim.g.minimal_ignore_tree_stopinsert = false
      if cur_win and vim.api.nvim_win_is_valid(cur_win) then
        vim.api.nvim_set_current_win(cur_win)
        pcall(vim.api.nvim_win_set_cursor, cur_win, cur_pos)
        if was_insert then vim.cmd("startinsert") end
      end
    else
      -- Deferred to restore_session() so restored workspace root is loaded first
      return
    end
    vim.schedule(function()
      local tree_win = api.tree.winid()
      if tree_win and vim.api.nvim_win_is_valid(tree_win) then
        pcall(vim.api.nvim_win_set_width, tree_win, _G.sidebar_width or 24)
      end
      local cur_win = vim.api.nvim_get_current_win()
      local cur_buf = vim.api.nvim_win_get_buf(cur_win)
      -- Only redirect from NvimTree back to editor window; never steal focus from terminal or floats
      if vim.bo[cur_buf].filetype == "NvimTree" then
        local ed = find_editor_win()
        if ed and vim.api.nvim_win_is_valid(ed) then
          vim.api.nvim_set_current_win(ed)
          cur_buf = vim.api.nvim_get_current_buf()
        end
      end
      if vim.fn.argc() > 0 and vim.bo[cur_buf].buftype == "" and vim.bo[cur_buf].filetype ~= "NvimTree"
         and not vim.b[cur_buf].is_renaming and not vim.b[cur_buf].is_picker
         and vim.fn.mode() ~= "i" and vim.fn.mode() ~= "s" then
        vim.cmd("startinsert")
      end
    end)
  end

  vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_sidebar_on_startup })
  if vim.v.vim_did_enter == 1 then
    open_sidebar_on_startup({ file = vim.fn.argv(0) or "" })
  end

  -- Enforce compact width & track sidebar visibility whenever opened/closed
  api.events.subscribe(api.events.Event.TreeOpen, function()
    vim.g.minimal_sidebar_open = true
    vim.schedule(function()
      local tw = api.tree.winid()
      if tw and vim.api.nvim_win_is_valid(tw) then
        pcall(vim.api.nvim_win_set_width, tw, _G.sidebar_width or 24)
      end
    end)
  end)

  api.events.subscribe(api.events.Event.TreeClose, function()
    if not vim.g.minimal_is_quitting then
      vim.g.minimal_sidebar_open = false
    end
  end)

  -- Strictly lock compact sidebar width across all window and display resize events
  vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
    callback = function()
      if api.tree.is_visible() then
        local tw = api.tree.winid()
        if tw and vim.api.nvim_win_is_valid(tw) then
          pcall(vim.api.nvim_win_set_width, tw, _G.sidebar_width or 24)
        end
      end
    end,
  })

  -- Close editor cleanly when only the sidebar remains
  vim.api.nvim_create_autocmd("QuitPre", {
    callback = function()
      local tree_wins = {}
      local floating_wins = {}
      local wins = vim.api.nvim_list_wins()
      for _, w in ipairs(wins) do
        local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
        if bufname:match("NvimTree_") ~= nil then
          table.insert(tree_wins, w)
        end
        if vim.api.nvim_win_get_config(w).relative ~= "" then
          table.insert(floating_wins, w)
        end
      end
      if 1 == #wins - #floating_wins - #tree_wins then
        for _, w in ipairs(tree_wins) do
          vim.api.nvim_win_close(w, true)
        end
      end
    end,
  })
end

-- 16. Top Tabs / Opened Files Bar (bufferline.nvim)
local ok_bufferline, bufferline = pcall(require, "bufferline")
if ok_bufferline then
  bufferline.setup({
    options = {
      mode = "buffers",
      style_preset = bufferline.style_preset.default,
      themable = true,
      numbers = "none",
      close_command = function(bufnr) _G.close_buffer(bufnr) end,
      right_mouse_command = nil,
      left_mouse_command = function(bufnr)
        local ed = find_editor_win()
        if ed then vim.api.nvim_set_current_win(ed) end
        if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
          pcall(vim.api.nvim_set_current_buf, bufnr)
          pcall(vim.cmd, "startinsert")
        end
      end,
      middle_mouse_command = function(bufnr) _G.close_buffer(bufnr) end,
      indicator = {
        style = "none",
      },
      buffer_close_icon = "󰅖",
      modified_icon = "●",
      close_icon = "",
      left_trunc_marker = "",
      right_trunc_marker = "",
      max_name_length = 25,
      max_prefix_length = 15,
      tab_size = 20,
      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(count, level)
        local icon = level:match("error") and "󰅚 " or "󰀪 "
        return " " .. icon .. count
      end,
      offsets = {
        {
          filetype = "NvimTree",
          text = "  EXPLORER",
          highlight = "Directory",
          text_align = "left",
          separator = true,
        },
      },
      color_icons = true,
      get_element_icon = function(element)
        local fname = vim.fn.fnamemodify(element.path, ":t")
        local ext = vim.fn.fnamemodify(element.path, ":e")
        local ok_m, m_icons = pcall(require, "minimal_icons")
        if ok_m then
          return m_icons.resolve_file_icon(fname, ext, element.filetype)
        end
        local ok_d, d = pcall(require, "nvim-web-devicons")
        if not ok_d then return end
        local icon, hl = d.get_icon(fname, ext, { default = true })
        return icon, hl or "DevIconDefault"
      end,
      show_buffer_icons = true,
      show_buffer_close_icons = true,
      show_close_icon = false,
      show_tab_indicators = true,
      persist_buffer_sort = true,
      separator_style = "thin",
      enforce_regular_tabs = false,
      always_show_bufferline = true,
      auto_toggle_bufferline = false,
      hover = {
        enabled = true,
        delay = 200,
        reveal = { "close" },
      },
      custom_filter = function(buf_number)
        local bt = vim.bo[buf_number].buftype
        local ft = vim.bo[buf_number].filetype
        local is_home = vim.b[buf_number].is_homescreen or (ft == "minimal_home")
        if bt == "terminal" or ft == "NvimTree" or is_home then
          return false
        end
        return true
      end,
    },
    highlights = {
      fill = {
        bg = "#181a1f",
      },
      background = {
        fg = "#abb2bf",
        bg = "#21252b",
      },
      buffer_selected = {
        fg = "#ffffff",
        bg = "#282c34",
        bold = true,
        italic = false,
      },
      close_button = {
        fg = "#abb2bf",
        bg = "#21252b",
      },
      close_button_visible = {
        fg = "#abb2bf",
        bg = "#21252b",
      },
      close_button_selected = {
        fg = "#abb2bf",
        bg = "#282c34", -- Seamless matching background for selected tab close cross
      },
      modified = {
        fg = "#fab387",
        bg = "#21252b",
      },
      modified_visible = {
        fg = "#fab387",
        bg = "#21252b",
      },
      modified_selected = {
        fg = "#fab387",
        bg = "#282c34",
      },
      tab_selected = {
        fg = "#ffffff",
        bg = "#282c34",
        bold = true,
      },
      separator = {
        fg = "#181a1f",
        bg = "#21252b",
      },
      separator_selected = {
        fg = "#181a1f",
        bg = "#282c34",
      },
      indicator_selected = {
        fg = "#61afef",
        bg = "#282c34",
      },
    },
  })

  -- Ensure close cross icon on selected tab always shares the exact background of the selected tab
  vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
    callback = function()
      local buf_sel = vim.api.nvim_get_hl(0, { name = "BufferLineBufferSelected" })
      local bg_sel = buf_sel.bg
      if not bg_sel then
        local norm = vim.api.nvim_get_hl(0, { name = "Normal" })
        bg_sel = norm.bg
      end
      if bg_sel then
        vim.api.nvim_set_hl(0, "BufferLineCloseButtonSelected", { fg = "#abb2bf", bg = bg_sel })
        vim.api.nvim_set_hl(0, "BufferLineModifiedSelected", { fg = "#fab387", bg = bg_sel })
      end

      -- Subtle, ultra-faint greyish separation border line (barely noticeable distinction)
      local subtle_grey = "#1c1f26"
      vim.api.nvim_set_hl(0, "WinSeparator", { fg = subtle_grey, bg = "NONE", bold = false })
      vim.api.nvim_set_hl(0, "VertSplit", { fg = subtle_grey, bg = "NONE", bold = false })
      vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = subtle_grey, bg = "NONE", bold = false })

      if _G.reapply_all_icon_colors then
        _G.reapply_all_icon_colors()
      end
    end,
  })
  end
end -- end _G.ensure_ui_chrome

vim.defer_fn(_G.ensure_ui_chrome, 1)

-- Track file disk presence on read & write
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
  callback = function(args)
    if args.buf and vim.api.nvim_buf_is_valid(args.buf) then
      local n = vim.api.nvim_buf_get_name(args.buf)
      if n ~= "" and (vim.uv or vim.loop).fs_stat(n) then
        vim.b[args.buf].was_on_disk = true
      end
    end
  end,
})

-- Auto-sync open buffers when returning to editor or switching buffers
vim.api.nvim_create_autocmd({ "FocusGained", "TermLeave", "TermClose", "BufEnter" }, {
  callback = function()
    if not vim.g.minimal_is_quitting and _G.sync_buffers_with_disk then
      _G.sync_buffers_with_disk()
    end
  end,
})

-- Continuous background sync timer (1.5s interval)
local disk_sync_timer = (vim.uv or vim.loop).new_timer()
if disk_sync_timer then
  disk_sync_timer:start(1000, 1500, vim.schedule_wrap(function()
    if not vim.g.minimal_is_quitting and _G.sync_buffers_with_disk then
      _G.sync_buffers_with_disk()
    end
  end))
end

-- Toggle opened files inside editor like VS Code
_G.tab_next = function()
  local bufs = get_listed_editor_bufs()
  if #bufs <= 1 then return end
  local cur = vim.api.nvim_get_current_buf()
  local idx = 1
  for i, b in ipairs(bufs) do
    if b == cur then idx = i break end
  end
  local next_idx = (idx % #bufs) + 1
  local target = bufs[next_idx]
  if target and vim.api.nvim_buf_is_valid(target) then
    pcall(vim.api.nvim_set_current_buf, target)
    pcall(vim.cmd, "startinsert")
  end
end

_G.tab_prev = function()
  local bufs = get_listed_editor_bufs()
  if #bufs <= 1 then return end
  local cur = vim.api.nvim_get_current_buf()
  local idx = 1
  for i, b in ipairs(bufs) do
    if b == cur then idx = i break end
  end
  local prev_idx = idx - 1
  if prev_idx < 1 then prev_idx = #bufs end
  local target = bufs[prev_idx]
  if target and vim.api.nvim_buf_is_valid(target) then
    pcall(vim.api.nvim_set_current_buf, target)
    pcall(vim.cmd, "startinsert")
  end
end

-- Close active file from editor (Ctrl+W)
_G.close_buffer = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype == "NvimTree" then return end
  if vim.bo[bufnr].filetype == "minimal_home" or vim.b[bufnr].is_homescreen then return end
  if vim.bo[bufnr].buftype == "terminal" then
    _G.toggle_terminal()
    return
  end

  if vim.bo[bufnr].modified and vim.bo[bufnr].buftype == "" then
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= "" and (vim.fn.filereadable(name) == 1 or vim.fn.filewritable(vim.fn.fnamemodify(name, ":h")) == 2) then
      vim.api.nvim_buf_call(bufnr, function()
        pcall(vim.cmd, "silent! noautocmd write")
      end)
    end
  end

  local bufs = get_listed_editor_bufs()
  if #bufs > 1 then
    if bufnr == vim.api.nvim_get_current_buf() then
      _G.tab_prev()
    end
    vim.bo[bufnr].buflisted = false
    pcall(vim.cmd, "silent! bdelete! " .. bufnr)
    vim.cmd("startinsert")
  else
    vim.bo[bufnr].buflisted = false
    pcall(vim.cmd, "silent! bdelete! " .. bufnr)
    if _G.open_homescreen then
      _G.open_homescreen()
    else
      vim.cmd("enew")
      vim.cmd("startinsert")
    end
  end
end

-- 17. Built-in VS Code-style Bottom Terminal Drawer (bash with Git Profile & Multiple Tabs)
_G.term_instances = {}
_G.active_term_idx = 1
local term_win = nil
local term_height = 18
_G.sidebar_width = 24

local function is_valid_win(w) return w and vim.api.nvim_win_is_valid(w) end
local function is_valid_buf(b) return b and vim.api.nvim_buf_is_valid(b) end

_G.resize_sidebar = function(delta)
  local ok_t, api = pcall(require, "nvim-tree.api")
  if not ok_t or not api.tree.is_visible() then return end
  local tw = api.tree.winid()
  if not tw or not vim.api.nvim_win_is_valid(tw) then return end
  local cur_w = vim.api.nvim_win_get_width(tw)
  local new_w = math.max(16, math.min(70, cur_w + delta))
  _G.sidebar_width = new_w
  pcall(vim.api.nvim_win_set_width, tw, new_w)
end

_G.resize_terminal = function(delta)
  if not is_valid_win(term_win) then return end
  local cur_h = vim.api.nvim_win_get_height(term_win)
  local max_h = math.floor((vim.o.lines or 40) * 0.8)
  local new_h = math.max(4, math.min(max_h, cur_h + delta))
  term_height = new_h
  pcall(vim.api.nvim_win_set_height, term_win, new_h)
end

_G.handle_alt_left = function()
  local cur_win = vim.api.nvim_get_current_win()
  local cur_buf = vim.api.nvim_win_get_buf(cur_win)
  local ft = vim.bo[cur_buf].filetype
  local bt = vim.bo[cur_buf].buftype
  if ft == "NvimTree" then
    _G.resize_sidebar(-2)
  elseif bt == "terminal" or cur_win == term_win then
    _G.resize_terminal(-2)
  end
end

_G.handle_alt_right = function()
  local cur_win = vim.api.nvim_get_current_win()
  local cur_buf = vim.api.nvim_win_get_buf(cur_win)
  local ft = vim.bo[cur_buf].filetype
  local bt = vim.bo[cur_buf].buftype
  if ft == "NvimTree" then
    _G.resize_sidebar(2)
  elseif bt == "terminal" or cur_win == term_win then
    _G.resize_terminal(2)
  end
end

_G.move_line_down = function()
  local cur_win = vim.api.nvim_get_current_win()
  local cur_buf = vim.api.nvim_win_get_buf(cur_win)
  if vim.bo[cur_buf].buftype == "terminal" or cur_win == term_win then
    _G.resize_terminal(-2)
    return
  end
  if vim.bo[cur_buf].filetype == "NvimTree" then return end
  if vim.bo[cur_buf].filetype == "minimal_home" then return end

  local m = vim.fn.mode()
  local total = vim.api.nvim_buf_line_count(0)
  if m:match("[vV\22sS\19]") then
    local vstart = vim.fn.getpos("v")[2]
    local vcur = vim.fn.getcurpos()[2]
    local r1 = math.min(vstart, vcur)
    local r2 = math.max(vstart, vcur)
    if r2 < total then
      local block = vim.api.nvim_buf_get_lines(0, r1 - 1, r2, false)
      local target = vim.api.nvim_buf_get_lines(0, r2, r2 + 1, false)[1]
      local new_lines = { target }
      for _, l in ipairs(block) do table.insert(new_lines, l) end
      vim.api.nvim_buf_set_lines(0, r1 - 1, r2 + 1, false, new_lines)
      vim.cmd("normal! \27")
      vim.api.nvim_win_set_cursor(0, { r1 + 1, 0 })
      vim.cmd("normal! V")
      vim.api.nvim_win_set_cursor(0, { r2 + 1, 0 })
    end
  else
    local cur = vim.api.nvim_win_get_cursor(0)
    local row, col = cur[1], cur[2]
    if row < total then
      local lines = vim.api.nvim_buf_get_lines(0, row - 1, row + 1, false)
      vim.api.nvim_buf_set_lines(0, row - 1, row + 1, false, { lines[2], lines[1] })
      vim.api.nvim_win_set_cursor(0, { row + 1, col })
    end
  end
end

_G.move_line_up = function()
  local cur_win = vim.api.nvim_get_current_win()
  local cur_buf = vim.api.nvim_win_get_buf(cur_win)
  if vim.bo[cur_buf].buftype == "terminal" or cur_win == term_win then
    _G.resize_terminal(2)
    return
  end
  if vim.bo[cur_buf].filetype == "NvimTree" then return end
  if vim.bo[cur_buf].filetype == "minimal_home" then return end

  local m = vim.fn.mode()
  if m:match("[vV\22sS\19]") then
    local vstart = vim.fn.getpos("v")[2]
    local vcur = vim.fn.getcurpos()[2]
    local r1 = math.min(vstart, vcur)
    local r2 = math.max(vstart, vcur)
    if r1 > 1 then
      local target = vim.api.nvim_buf_get_lines(0, r1 - 2, r1 - 1, false)[1]
      local block = vim.api.nvim_buf_get_lines(0, r1 - 1, r2, false)
      local new_lines = {}
      for _, l in ipairs(block) do table.insert(new_lines, l) end
      table.insert(new_lines, target)
      vim.api.nvim_buf_set_lines(0, r1 - 2, r2, false, new_lines)
      vim.cmd("normal! \27")
      vim.api.nvim_win_set_cursor(0, { r1 - 1, 0 })
      vim.cmd("normal! V")
      vim.api.nvim_win_set_cursor(0, { r2 - 1, 0 })
    end
  else
    local cur = vim.api.nvim_win_get_cursor(0)
    local row, col = cur[1], cur[2]
    if row > 1 then
      local lines = vim.api.nvim_buf_get_lines(0, row - 2, row, false)
      vim.api.nvim_buf_set_lines(0, row - 2, row, false, { lines[2], lines[1] })
      vim.api.nvim_win_set_cursor(0, { row - 1, col })
    end
  end
end

_G.copy_line_down = function()
  local cur_win = vim.api.nvim_get_current_win()
  local cur_buf = vim.api.nvim_win_get_buf(cur_win)
  if vim.bo[cur_buf].filetype == "NvimTree" or vim.bo[cur_buf].buftype == "terminal" or vim.bo[cur_buf].filetype == "minimal_home" then
    return
  end

  local m = vim.fn.mode()
  if m:match("[vV\22sS\19]") then
    local vstart = vim.fn.getpos("v")[2]
    local vcur = vim.fn.getcurpos()[2]
    local r1 = math.min(vstart, vcur)
    local r2 = math.max(vstart, vcur)
    local block = vim.api.nvim_buf_get_lines(0, r1 - 1, r2, false)
    local count = #block
    vim.api.nvim_buf_set_lines(0, r2, r2, false, block)
    vim.cmd("normal! \27")
    vim.api.nvim_win_set_cursor(0, { r2 + 1, 0 })
    vim.cmd("normal! V")
    vim.api.nvim_win_set_cursor(0, { r2 + count, 0 })
  else
    local cur = vim.api.nvim_win_get_cursor(0)
    local row, col = cur[1], cur[2]
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
    vim.api.nvim_buf_set_lines(0, row, row, false, { line })
    vim.api.nvim_win_set_cursor(0, { row + 1, col })
  end
end

_G.copy_line_up = function()
  local cur_win = vim.api.nvim_get_current_win()
  local cur_buf = vim.api.nvim_win_get_buf(cur_win)
  if vim.bo[cur_buf].filetype == "NvimTree" or vim.bo[cur_buf].buftype == "terminal" or vim.bo[cur_buf].filetype == "minimal_home" then
    return
  end

  local m = vim.fn.mode()
  if m:match("[vV\22sS\19]") then
    local vstart = vim.fn.getpos("v")[2]
    local vcur = vim.fn.getcurpos()[2]
    local r1 = math.min(vstart, vcur)
    local r2 = math.max(vstart, vcur)
    local block = vim.api.nvim_buf_get_lines(0, r1 - 1, r2, false)
    local count = #block
    vim.api.nvim_buf_set_lines(0, r1 - 1, r1 - 1, false, block)
    vim.cmd("normal! \27")
    vim.api.nvim_win_set_cursor(0, { r1 + count, 0 })
    vim.cmd("normal! V")
    vim.api.nvim_win_set_cursor(0, { r2 + count, 0 })
  else
    local cur = vim.api.nvim_win_get_cursor(0)
    local row, col = cur[1], cur[2]
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
    vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { line })
    vim.api.nvim_win_set_cursor(0, { row, col })
  end
end

_G.handle_alt_up = function()
  _G.move_line_up()
end

_G.handle_alt_down = function()
  _G.move_line_down()
end

local function clean_terminal_instances()
  local valid = {}
  for _, inst in ipairs(_G.term_instances) do
    if is_valid_buf(inst.buf) then
      table.insert(valid, inst)
    end
  end
  _G.term_instances = valid
  if _G.active_term_idx > #_G.term_instances then
    _G.active_term_idx = math.max(1, #_G.term_instances)
  end
end

_G.close_terminal_by_index = function(idx)
  clean_terminal_instances()
  idx = tonumber(idx)
  if not idx or idx < 1 or idx > #_G.term_instances then return end

  local target_inst = _G.term_instances[idx]
  if not target_inst then return end

  local dead_buf = target_inst.buf
  table.remove(_G.term_instances, idx)

  if #_G.term_instances == 0 then
    if is_valid_win(term_win) then
      vim.api.nvim_win_hide(term_win)
      term_win = nil
    end
    _G.active_term_idx = 1
    local ed = find_editor_win()
    if ed and vim.api.nvim_win_is_valid(ed) then
      vim.api.nvim_set_current_win(ed)
      vim.cmd("startinsert")
    end
  else
    if _G.active_term_idx >= idx then
      _G.active_term_idx = math.max(1, _G.active_term_idx - 1)
    end
    local next_inst = _G.term_instances[_G.active_term_idx]
    if next_inst and is_valid_buf(next_inst.buf) and is_valid_win(term_win) then
      vim.api.nvim_win_set_buf(term_win, next_inst.buf)
      vim.cmd("startinsert")
    end
  end

  if is_valid_buf(dead_buf) then
    pcall(vim.cmd, "silent! bdelete! " .. dead_buf)
  end

  if is_valid_win(term_win) then
    vim.wo[term_win].winbar = "%!v:lua._G.terminal_winbar()"
  end
end

_G.kill_active_terminal = function()
  clean_terminal_instances()
  if #_G.term_instances == 0 then
    if is_valid_win(term_win) then
      vim.api.nvim_win_hide(term_win)
      term_win = nil
    end
    return
  end
  _G.close_terminal_by_index(_G.active_term_idx)
end

_G.click_close_terminal = function(minwid, clicks, button, mods)
  vim.schedule(function()
    _G.close_terminal_by_index(minwid)
  end)
end

_G.click_select_terminal = function(minwid, clicks, button, mods)
  vim.schedule(function()
    minwid = tonumber(minwid)
    if minwid and minwid >= 1 and minwid <= #_G.term_instances then
      _G.active_term_idx = minwid
      local inst = _G.term_instances[minwid]
      if inst and is_valid_buf(inst.buf) and is_valid_win(term_win) then
        vim.api.nvim_win_set_buf(term_win, inst.buf)
        vim.wo[term_win].winbar = "%!v:lua._G.terminal_winbar()"
        vim.cmd("startinsert")
      end
    end
  end)
end

_G.terminal_winbar = function()
  clean_terminal_instances()
  if #_G.term_instances == 0 then return "" end

  local parts = {}

  for i, inst in ipairs(_G.term_instances) do
    local is_active = (i == _G.active_term_idx)
    local tab_hl = is_active and "%#BufferLineBufferSelected#" or "%#BufferLineBackground#"
    local close_hl = is_active and "%#BufferLineCloseButtonSelected#" or "%#BufferLineCloseButton#"

    local tab_str = string.format(
      "%s%%%d@v:lua._G.click_select_terminal@  %d: %s  %%X%s%%%d@v:lua._G.click_close_terminal@󰅖 %%X%%#StatusLine#",
      tab_hl, i, i, inst.name,
      close_hl, i
    )
    table.insert(parts, tab_str)
  end

  table.insert(parts, "%#StatusLine#%=")

  return table.concat(parts, " ")
end

local function update_terminal_title()
  if is_valid_win(term_win) then
    vim.wo[term_win].winbar = "%!v:lua._G.terminal_winbar()"
  end
end

_G.autosave_all_modified = function()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) and vim.bo[b].modified and vim.bo[b].buftype == "" then
      local name = vim.api.nvim_buf_get_name(b)
      if name ~= "" and (vim.fn.filereadable(name) == 1 or vim.fn.filewritable(vim.fn.fnamemodify(name, ":h")) == 2) then
        vim.api.nvim_buf_call(b, function()
          pcall(vim.cmd, "silent! noautocmd write")
        end)
      end
    end
  end
end

_G.new_terminal = function()
  _G.autosave_all_modified()
  clean_terminal_instances()
  local ed = find_editor_win()
  local new_buf = vim.api.nvim_create_buf(false, true)

  vim.b[new_buf].is_picker = true
  if not is_valid_win(term_win) then
    if ed then vim.api.nvim_set_current_win(ed) end
    vim.cmd("botright " .. term_height .. "split")
    term_win = vim.api.nvim_get_current_win()
  else
    vim.api.nvim_set_current_win(term_win)
  end

  vim.api.nvim_win_set_buf(term_win, new_buf)

  local rc_file = vim.fn.stdpath("config") .. "/terminal_rc.sh"
  if vim.fn.filereadable(rc_file) == 0 then
    local fallback_rc = vim.fn.expand("~/.config/nvim/terminal_rc.sh")
    if vim.fn.filereadable(fallback_rc) == 1 then
      rc_file = fallback_rc
    end
  end
  local bash_hist = vim.fn.expand("~/.bash_history")
  local cmd = {
    "/usr/bin/env",
    "-u", "KITTY_PID",
    "-u", "KITTY_WINDOW_ID",
    "-u", "KITTY_PUBLIC_KEY",
    "-u", "KITTY_INSTALLATION_DIR",
    "-u", "TERMINFO",
    "-u", "STARSHIP_SHELL",
    "-u", "ZDOTDIR",
    "-u", "ZSH_AUTOSUGGEST_STRATEGY",
    "SHELL=/bin/bash",
    "HISTFILE=" .. bash_hist,
    "TERM=xterm-256color",
    "COLORTERM=truecolor",
    "/bin/bash", "--rcfile", rc_file,
  }
  vim.fn.termopen(cmd)
  vim.b[new_buf].is_picker = nil
  vim.bo[new_buf].modified = false
  vim.cmd("startinsert")

  vim.wo[term_win].number = false
  vim.wo[term_win].relativenumber = false
  vim.wo[term_win].signcolumn = "no"
  vim.wo[term_win].spell = false

  -- Click anywhere in terminal enters terminal insert mode immediately
  vim.keymap.set("n", "<LeftMouse>", "<LeftMouse><cmd>startinsert<cr>", { buffer = new_buf, silent = true })
  vim.keymap.set("n", "<LeftRelease>", "<cmd>startinsert<cr>", { buffer = new_buf, silent = true })
  vim.keymap.set("t", "<LeftMouse>", "<LeftMouse><cmd>startinsert<cr>", { buffer = new_buf, silent = true })

  -- Pane resize keys in terminal buffer
  vim.keymap.set("t", "<M-Left>", _G.handle_alt_left, { buffer = new_buf, silent = true })
  vim.keymap.set("t", "<M-Right>", _G.handle_alt_right, { buffer = new_buf, silent = true })
  vim.keymap.set("t", "<M-Up>", _G.handle_alt_up, { buffer = new_buf, silent = true })
  vim.keymap.set("t", "<M-Down>", _G.handle_alt_down, { buffer = new_buf, silent = true })

  -- Smart word navigation and word deletion inside integrated Bash terminal
  local function send_term(seq)
    local chan = vim.bo[new_buf].channel
    if chan and chan > 0 then
      pcall(vim.api.nvim_chan_send, chan, seq)
    end
  end
  vim.keymap.set("t", "<C-Left>", function() send_term("\x1b[1;5D") end, { buffer = new_buf, nowait = true, silent = true })
  vim.keymap.set("t", "<C-Right>", function() send_term("\x1b[1;5C") end, { buffer = new_buf, nowait = true, silent = true })
  vim.keymap.set("t", "<C-BS>", function() send_term("\x1b\x7f") end, { buffer = new_buf, nowait = true, silent = true })
  vim.keymap.set("t", "<C-BackSpace>", function() send_term("\x1b\x7f") end, { buffer = new_buf, nowait = true, silent = true })
  vim.keymap.set("t", "<M-BS>", function() send_term("\x1b\x7f") end, { buffer = new_buf, nowait = true, silent = true })
  vim.keymap.set("t", "<M-BackSpace>", function() send_term("\x1b\x7f") end, { buffer = new_buf, nowait = true, silent = true })
  vim.keymap.set("t", "<C-Del>", function() send_term("\x1bd") end, { buffer = new_buf, nowait = true, silent = true })
  vim.keymap.set("t", "<C-Delete>", function() send_term("\x1bd") end, { buffer = new_buf, nowait = true, silent = true })
  vim.keymap.set("t", "<M-Del>", function() send_term("\x1bd") end, { buffer = new_buf, nowait = true, silent = true })
  vim.keymap.set("t", "<M-Delete>", function() send_term("\x1bd") end, { buffer = new_buf, nowait = true, silent = true })
  vim.keymap.set("t", "<C-Home>", function() send_term("\x01") end, { buffer = new_buf, nowait = true, silent = true })
  vim.keymap.set("t", "<C-End>", function() send_term("\x05") end, { buffer = new_buf, nowait = true, silent = true })

  local inst_idx = #_G.term_instances + 1
  table.insert(_G.term_instances, { buf = new_buf, name = "bash" })
  _G.active_term_idx = inst_idx

  vim.api.nvim_create_autocmd("TermClose", {
    buffer = new_buf,
    callback = function()
      vim.schedule(function()
        pcall(vim.cmd, "silent! bdelete! " .. new_buf)
        clean_terminal_instances()
        if #_G.term_instances == 0 then
          if is_valid_win(term_win) then
            vim.api.nvim_win_hide(term_win)
            term_win = nil
          end
        else
          if is_valid_win(term_win) then
            local active = _G.term_instances[_G.active_term_idx]
            if active and is_valid_buf(active.buf) then
              vim.api.nvim_win_set_buf(term_win, active.buf)
            end
            update_terminal_title()
          end
        end
      end)
    end,
  })

  update_terminal_title()
  vim.cmd("startinsert")
end

-- Strictly disable spell checking in all terminal windows and instances
vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter", "BufEnter" }, {
  callback = function(args)
    if args.buf and vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].buftype == "terminal" then
      pcall(function()
        vim.wo.spell = false
      end)
    end
  end,
})

_G.term_next = function()
  clean_terminal_instances()
  if #_G.term_instances <= 1 then return end
  _G.active_term_idx = (_G.active_term_idx % #_G.term_instances) + 1
  local inst = _G.term_instances[_G.active_term_idx]
  if inst and is_valid_buf(inst.buf) and is_valid_win(term_win) then
    vim.api.nvim_win_set_buf(term_win, inst.buf)
    update_terminal_title()
    vim.cmd("startinsert")
  end
end

_G.term_prev = function()
  clean_terminal_instances()
  if #_G.term_instances <= 1 then return end
  _G.active_term_idx = _G.active_term_idx - 1
  if _G.active_term_idx < 1 then _G.active_term_idx = #_G.term_instances end
  local inst = _G.term_instances[_G.active_term_idx]
  if inst and is_valid_buf(inst.buf) and is_valid_win(term_win) then
    vim.api.nvim_win_set_buf(term_win, inst.buf)
    update_terminal_title()
    vim.cmd("startinsert")
  end
end

vim.api.nvim_create_autocmd("WinResized", {
  callback = function()
    if is_valid_win(term_win) then
      local h = vim.api.nvim_win_get_height(term_win)
      if h and h > 2 then
        term_height = h
      end
    end
  end,
})

_G.toggle_terminal = function()
  _G.autosave_all_modified()
  clean_terminal_instances()
  if is_valid_win(term_win) then
    local h = vim.api.nvim_win_get_height(term_win)
    if h and h > 2 then
      term_height = h
    end

    local cur_win = vim.api.nvim_get_current_win()
    if cur_win == term_win then
      local closed_win = term_win
      term_win = nil
      local ed = find_editor_win()
      if ed and vim.api.nvim_win_is_valid(ed) then
        vim.api.nvim_set_current_win(ed)
      end
      if vim.api.nvim_win_is_valid(closed_win) then
        pcall(vim.api.nvim_win_hide, closed_win)
      end
      vim.cmd("startinsert")
      vim.schedule(enforce_buffer_mode)
    else
      vim.api.nvim_set_current_win(term_win)
      vim.cmd("startinsert")
    end
    return
  end

  if #_G.term_instances == 0 then
    _G.new_terminal()
  else
    local inst = _G.term_instances[_G.active_term_idx] or _G.term_instances[1]
    if not inst or not is_valid_buf(inst.buf) then
      _G.new_terminal()
      return
    end

    local ed = find_editor_win()
    if ed then vim.api.nvim_set_current_win(ed) end

    vim.cmd("botright " .. term_height .. "split")
    term_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(term_win, inst.buf)
    vim.wo[term_win].number = false
    vim.wo[term_win].relativenumber = false
    vim.wo[term_win].signcolumn = "no"
    vim.wo[term_win].spell = false
    update_terminal_title()
    vim.cmd("startinsert")
  end
end

_G.open_file_from_terminal = function(file_path)
  if not file_path or file_path == "" then return "ERR" end
  _G.autosave_all_modified()
  vim.schedule(function()
    if vim.fn.mode() == "t" then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "nx", false)
    end

    local ed = find_editor_win()
    if not ed or not is_valid_win(ed) then
      if is_valid_win(term_win) then
        vim.api.nvim_win_hide(term_win)
        term_win = nil
      end
      vim.cmd("enew")
      ed = vim.api.nvim_get_current_win()
    else
      if is_valid_win(term_win) then
        vim.api.nvim_win_hide(term_win)
        term_win = nil
      end
      vim.api.nvim_set_current_win(ed)
    end

    if ed and is_valid_win(ed) then
      vim.api.nvim_set_current_win(ed)
    end

    -- If target is a directory, change directory and reload tree root
    if vim.fn.isdirectory(file_path) == 1 then
      pcall(vim.cmd.cd, file_path)
      if package.loaded["nvim-tree"] then
        local ok_t, t_api = pcall(require, "nvim-tree.api")
        if ok_t and t_api.tree and t_api.tree.change_root then
          pcall(t_api.tree.change_root, file_path)
          pcall(t_api.tree.reload)
        end
      end
      return
    end

    -- If parent directories do not exist yet, create them automatically so compilers/builds/watchers find them
    local parent_dir = vim.fs.dirname(file_path)
    if parent_dir and parent_dir ~= "" and vim.fn.isdirectory(parent_dir) == 0 then
      pcall(vim.fn.mkdir, parent_dir, "p")
    end

    local ok_edit = pcall(vim.cmd.edit, vim.fn.fnameescape(file_path))
    if not ok_edit then
      vim.cmd("enew")
      pcall(vim.cmd.edit, vim.fn.fnameescape(file_path))
    end
    local cur_buf = vim.api.nvim_get_current_buf()
    if (vim.uv or vim.loop).fs_stat(file_path) then
      vim.b[cur_buf].was_on_disk = true
    end
    vim.cmd("startinsert")

    if package.loaded["nvim-tree"] then
      local ok_t, t_api = pcall(require, "nvim-tree.api")
      if ok_t and t_api.tree and pcall(t_api.tree.is_visible) and t_api.tree.is_visible() then
        pcall(t_api.tree.find_file, file_path)
      end
    end
  end)
  return "OK"
end

_G.focus_editor_from_terminal = function()
  vim.schedule(function()
    if vim.fn.mode() == "t" then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "nx", false)
    end
    local ed = find_editor_win()
    if ed and is_valid_win(ed) then
      vim.api.nvim_set_current_win(ed)
      vim.cmd("startinsert")
    end
  end)
  return "OK"
end

-- =============================================================================
-- VIM RELATIVE LINE JUMP & GO TO LINE (Alt+K / Alt+J / Ctrl+G)
-- =============================================================================
_G.relative_jump = function(direction)
  local ed = find_editor_win()
  if not ed or not vim.api.nvim_win_is_valid(ed) then return end
  vim.api.nvim_set_current_win(ed)

  local cur_pos = vim.api.nvim_win_get_cursor(ed)
  local cur_row = cur_pos[1]
  local cur_col = cur_pos[2]
  local total_rows = vim.api.nvim_buf_line_count(0)

  local is_up = (direction == "up")
  local title = is_up and " Jump Up (Relative Lines) " or " Jump Down (Relative Lines) "

  local buf = vim.api.nvim_create_buf(false, true)
  vim.b[buf].is_picker = true
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"

  local ui = vim.api.nvim_list_uis()[1] or { width = 120, height = 40 }
  local width = 36
  local height = 1
  local row = math.max(1, math.floor(ui.height / 3))
  local col = math.max(1, math.floor((ui.width - width) / 2))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
  })

  vim.cmd("stopinsert")
  vim.wo[win].cursorline = false
  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

  local input_str = ""

  local function render()
    local display = "  Lines: " .. input_str .. (input_str == "" and " (enter count...)" or "▏")
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { display })
    vim.bo[buf].modifiable = false
  end

  render()

  local function close_popup()
    pcall(vim.api.nvim_win_close, win, true)
    if vim.api.nvim_win_is_valid(ed) then
      vim.api.nvim_set_current_win(ed)
    end
    vim.cmd("startinsert")
    _G.clear_active_menu(close_popup)
  end

  _G.register_active_menu(close_popup, win)

  local function confirm_jump()
    local count = tonumber(input_str) or 1
    close_popup()
    if count and count > 0 then
      local target_row
      if is_up then
        target_row = math.max(1, cur_row - count)
      else
        target_row = math.min(total_rows, cur_row + count)
      end
      local line = (vim.api.nvim_buf_get_lines(0, target_row - 1, target_row, false) or {})[1] or ""
      local col = math.min(cur_col, #line)
      pcall(vim.api.nvim_win_set_cursor, ed, { target_row, col })
    end
  end

  for c = 48, 57 do -- digits 0-9
    local ch = string.char(c)
    vim.keymap.set({ "n", "i", "s", "v" }, ch, function()
      input_str = input_str .. ch
      render()
    end, { buffer = buf, nowait = true })
  end

  vim.keymap.set({ "n", "i", "s", "v" }, "<BS>", function()
    if #input_str > 0 then
      input_str = input_str:sub(1, -2)
      render()
    end
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<C-h>", function()
    if #input_str > 0 then
      input_str = input_str:sub(1, -2)
      render()
    end
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<C-u>", function()
    input_str = ""
    render()
  end, { buffer = buf, nowait = true })

  local function clear_input()
    input_str = ""
    render()
  end
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-BS>", clear_input, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-BackSpace>", clear_input, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-w>", clear_input, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-BS>", clear_input, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-BackSpace>", clear_input, { buffer = buf, nowait = true })

  local block_keys = { "<C-z>", "<C-y>", "<C-r>", "<C-d>", "<C-x>", "<C-s>", "<S-Del>", "<S-Delete>", "<Insert>" }
  for _, bk in ipairs(block_keys) do
    vim.keymap.set({ "n", "i", "s", "v" }, bk, "<nop>", { buffer = buf, nowait = true })
  end

  for _, wk in ipairs({ "<C-w>w", "<C-w>h", "<C-w>j", "<C-w>k", "<C-w>l", "<C-w><Up>", "<C-w><Down>", "<C-w><Left>", "<C-w><Right>" }) do
    vim.keymap.set({ "n", "i", "s", "v" }, wk, "<nop>", { buffer = buf, nowait = true })
  end

  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = buf,
    once = true,
    callback = close_popup,
  })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Up>", function()
    local n = tonumber(input_str) or 0
    input_str = tostring(math.max(1, n + 1))
    render()
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Down>", function()
    local n = tonumber(input_str) or 1
    input_str = tostring(math.max(1, n - 1))
    render()
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<CR>", confirm_jump, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<Esc>", close_popup, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-c>", close_popup, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "q", close_popup, { buffer = buf, nowait = true })
end

_G.goto_line = function()
  local ed = find_editor_win()
  if not ed or not vim.api.nvim_win_is_valid(ed) then return end
  vim.api.nvim_set_current_win(ed)

  local cur_pos = vim.api.nvim_win_get_cursor(ed)
  local cur_row = cur_pos[1]
  local cur_col = cur_pos[2]
  local total_rows = vim.api.nvim_buf_line_count(0)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.b[buf].is_picker = true
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"

  local ui = vim.api.nvim_list_uis()[1] or { width = 120, height = 40 }
  local width = 42
  local height = 1
  local row = math.max(1, math.floor(ui.height / 3))
  local col = math.max(1, math.floor((ui.width - width) / 2))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Go to Line (number, +down, -up) ",
    title_pos = "center",
  })

  vim.cmd("stopinsert")
  vim.wo[win].cursorline = false
  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

  local input_str = ""

  local function render()
    local display = "  Target: " .. input_str .. (input_str == "" and " (e.g. 50 or -5 or +10)" or "▏")
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { display })
    vim.bo[buf].modifiable = false
  end

  render()

  local function close_popup()
    pcall(vim.api.nvim_win_close, win, true)
    if vim.api.nvim_win_is_valid(ed) then
      vim.api.nvim_set_current_win(ed)
    end
    vim.cmd("startinsert")
    _G.clear_active_menu(close_popup)
  end

  _G.register_active_menu(close_popup, win)

  local function confirm_jump()
    local str = vim.trim(input_str)
    close_popup()
    if str == "" then return end

    local target_row = nil
    if str:sub(1, 1) == "+" then
      local delta = tonumber(str:sub(2))
      if delta then target_row = math.min(total_rows, cur_row + delta) end
    elseif str:sub(1, 1) == "-" then
      local delta = tonumber(str:sub(2))
      if delta then target_row = math.max(1, cur_row - delta) end
    elseif str:sub(1, 1) == ":" then
      local num = tonumber(str:sub(2))
      if num then target_row = math.max(1, math.min(total_rows, num)) end
    else
      local num = tonumber(str)
      if num then target_row = math.max(1, math.min(total_rows, num)) end
    end

    if target_row then
      local line = (vim.api.nvim_buf_get_lines(0, target_row - 1, target_row, false) or {})[1] or ""
      local col = math.min(cur_col, #line)
      pcall(vim.api.nvim_win_set_cursor, ed, { target_row, col })
    end
  end

  local allowed_chars = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "-", ":" }
  for _, ch in ipairs(allowed_chars) do
    vim.keymap.set({ "n", "i", "s", "v" }, ch, function()
      input_str = input_str .. ch
      render()
    end, { buffer = buf, nowait = true })
  end

  vim.keymap.set({ "n", "i", "s", "v" }, "<BS>", function()
    if #input_str > 0 then
      input_str = input_str:sub(1, -2)
      render()
    end
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<C-h>", function()
    if #input_str > 0 then
      input_str = input_str:sub(1, -2)
      render()
    end
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<C-u>", function()
    input_str = ""
    render()
  end, { buffer = buf, nowait = true })

  local function clear_input()
    input_str = ""
    render()
  end
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-BS>", clear_input, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-BackSpace>", clear_input, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-w>", clear_input, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-BS>", clear_input, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-BackSpace>", clear_input, { buffer = buf, nowait = true })

  local block_keys = { "<C-z>", "<C-y>", "<C-r>", "<C-d>", "<C-x>", "<C-s>", "<S-Del>", "<S-Delete>", "<Insert>" }
  for _, bk in ipairs(block_keys) do
    vim.keymap.set({ "n", "i", "s", "v" }, bk, "<nop>", { buffer = buf, nowait = true })
  end

  for _, wk in ipairs({ "<C-w>w", "<C-w>h", "<C-w>j", "<C-w>k", "<C-w>l", "<C-w><Up>", "<C-w><Down>", "<C-w><Left>", "<C-w><Right>" }) do
    vim.keymap.set({ "n", "i", "s", "v" }, wk, "<nop>", { buffer = buf, nowait = true })
  end

  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = buf,
    once = true,
    callback = close_popup,
  })

  vim.keymap.set({ "n", "i", "s", "v" }, "<CR>", confirm_jump, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<Esc>", close_popup, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-c>", close_popup, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "q", close_popup, { buffer = buf, nowait = true })
end

-- =============================================================================
-- CODE SPELL CHECKER & QUICK FIX MENU (Ctrl+. / Ctrl+Period)
-- =============================================================================
_G.open_quick_fix_spell = function()
  local ed = find_editor_win()
  if not ed or not vim.api.nvim_win_is_valid(ed) then return end
  vim.api.nvim_set_current_win(ed)

  local cur = vim.api.nvim_win_get_cursor(ed)
  local row, col = cur[1], cur[2]
  local line = vim.api.nvim_get_current_line()
  local cword = vim.fn.expand("<cword>")

  if not cword or cword == "" then
    local left_part = line:sub(1, col)
    cword = left_part:match("([%w_]+)%s*$") or ""
  end

  if cword == "" then
    vim.notify("No word under cursor for spell check", vim.log.levels.INFO)
    return
  end

  local is_bad = (vim.fn.spellbadword(cword)[1] ~= "")
  local suggestions = vim.fn.spellsuggest(cword, 6)

  local actions = {}
  for i, s in ipairs(suggestions) do
    table.insert(actions, {
      kind = "replace",
      label = string.format("%d. %s", i, s),
      word = s,
    })
  end

  table.insert(actions, {
    kind = "dict_add",
    label = '+ Add "' .. cword .. '" to User Dictionary',
    word = cword,
  })
  table.insert(actions, {
    kind = "dict_ignore",
    label = '- Ignore "' .. cword .. '" for this session',
    word = cword,
  })

  local buf = vim.api.nvim_create_buf(false, true)
  vim.b[buf].is_picker = true
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].undolevels = -1

  local ui = vim.api.nvim_list_uis()[1] or { width = 120, height = 40 }
  local width = math.min(62, math.max(46, #cword + 34))
  local height = #actions + (#suggestions > 0 and 2 or 1)
  local win_row = math.max(1, math.min(row + 1, ui.height - height - 2))
  local win_col = math.max(1, math.min(col + 2, ui.width - width - 2))

  local title_prefix = is_bad and " [Misspelled] " or " [Spell / Quick Fix] "
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = win_row,
    col = win_col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = title_prefix .. cword .. " ",
    title_pos = "center",
  })

  vim.cmd("stopinsert")
  vim.wo[win].cursorline = false
  vim.wo[win].wrap = false
  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

  local active_idx = 1
  vim.api.nvim_set_hl(0, "QuickFixSep", { fg = "#3e4451" })

  local function render()
    local lines = {}
    local sep_row = nil
    for i, a in ipairs(actions) do
      if a.kind == "dict_add" and #suggestions > 0 then
        table.insert(lines, string.rep("─", width))
        sep_row = #lines
      end
      local prefix = (i == active_idx) and " > " or "   "
      table.insert(lines, prefix .. a.label)
    end
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    local ns_id = vim.api.nvim_create_namespace("quick_fix_hl")
    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
    if sep_row then
      pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "QuickFixSep", sep_row - 1, 0, -1)
    end

    local cursor_row = active_idx
    if #suggestions > 0 and active_idx > #suggestions then
      cursor_row = cursor_row + 1
    end
    pcall(vim.api.nvim_win_set_cursor, win, { cursor_row, 1 })
  end

  local function close_popup()
    pcall(vim.api.nvim_win_close, win, true)
    if vim.api.nvim_win_is_valid(ed) then
      vim.api.nvim_set_current_win(ed)
    end
    vim.cmd("startinsert")
    _G.clear_active_menu(close_popup)
  end

  _G.register_active_menu(close_popup, win)

  render()

  local function apply_action(action)
    close_popup()
    if not action then return end

    if action.kind == "replace" then
      local cur_pos = vim.api.nvim_win_get_cursor(ed)
      local r, c = cur_pos[1], cur_pos[2]
      local cur_line = vim.api.nvim_get_current_line()

      local idx = c + 1
      local start_idx = idx
      while start_idx > 1 and cur_line:sub(start_idx - 1, start_idx - 1):match("[%w_]") do
        start_idx = start_idx - 1
      end
      local end_idx = idx
      while end_idx <= #cur_line and cur_line:sub(end_idx, end_idx):match("[%w_]") do
        end_idx = end_idx + 1
      end

      if start_idx < end_idx then
        local before = cur_line:sub(1, start_idx - 1)
        local after = cur_line:sub(end_idx)
        local new_line = before .. action.word .. after
        vim.api.nvim_set_current_line(new_line)
        local new_col = #(before .. action.word)
        vim.api.nvim_win_set_cursor(ed, { r, new_col })
      end
    elseif action.kind == "dict_add" then
      local sfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
      pcall(vim.fn.mkdir, vim.fn.fnamemodify(sfile, ":h"), "p")
      local already_added = false
      local f = io.open(sfile, "r")
      if f then
        for line_word in f:lines() do
          if line_word == action.word then
            already_added = true
            break
          end
        end
        f:close()
      end
      if not already_added then
        vim.cmd("silent! spellgood " .. vim.fn.fnameescape(action.word))
      else
        vim.cmd("silent! mkspell! " .. vim.fn.fnameescape(sfile))
      end
      vim.cmd("redraw!")
      vim.notify('Added "' .. action.word .. '" to user dictionary', vim.log.levels.INFO)
    elseif action.kind == "dict_ignore" then
      vim.cmd("silent! spellrare " .. vim.fn.fnameescape(action.word))
      vim.cmd("redraw!")
    end
  end

  local function confirm_selected()
    apply_action(actions[active_idx])
  end

  local function move_up()
    active_idx = active_idx - 1
    if active_idx < 1 then active_idx = #actions end
    render()
  end

  local function move_down()
    active_idx = active_idx + 1
    if active_idx > #actions then active_idx = 1 end
    render()
  end

  for i = 1, math.min(9, #suggestions) do
    vim.keymap.set({ "n", "i", "s", "v" }, tostring(i), function()
      apply_action(actions[i])
    end, { buffer = buf, nowait = true })
  end

  vim.keymap.set({ "n", "i", "s", "v" }, "<Up>", move_up, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-p>", move_up, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Down>", move_down, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-n>", move_down, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<CR>", confirm_selected, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<Esc>", close_popup, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-c>", close_popup, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "q", close_popup, { buffer = buf, nowait = true })

  local block_keys = { "<C-z>", "<C-y>", "<C-r>", "<C-d>", "<C-x>", "<C-s>", "<S-Del>", "<S-Delete>", "<Insert>" }
  for _, bk in ipairs(block_keys) do
    vim.keymap.set({ "n", "i", "s", "v" }, bk, "<nop>", { buffer = buf, nowait = true })
  end

  for _, wk in ipairs({ "<C-w>w", "<C-w>h", "<C-w>j", "<C-w>k", "<C-w>l", "<C-w><Up>", "<C-w><Down>", "<C-w><Left>", "<C-w><Right>" }) do
    vim.keymap.set({ "n", "i", "s", "v" }, wk, "<nop>", { buffer = buf, nowait = true })
  end

  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = buf,
    once = true,
    callback = close_popup,
  })
end

-- =============================================================================
-- SESSION PERSISTENCE & COMPREHENSIVE AUTOSAVE (VS Code Continuous Workflow)
-- =============================================================================
local session_file = vim.fn.stdpath("state") .. "/last_session.json"
local session_restored = false
local is_quitting = false
local last_active_file = nil

local function autosave_all_modified()
  _G.autosave_all_modified()
end

local function save_session()
  if is_quitting or not session_restored then return end

  local bufs = get_listed_editor_bufs()
  local file_paths = {}
  local seen = {}
  local current_buf = vim.api.nvim_get_current_buf()
  local active_path = nil
  local active_cursor = { 1, 0 }

  for _, b in ipairs(bufs) do
    local name = vim.api.nvim_buf_get_name(b)
    if name ~= "" and vim.fn.filereadable(name) == 1 and not seen[name] then
      seen[name] = true
      table.insert(file_paths, name)
      if b == current_buf then
        active_path = name
        local cur_win = vim.api.nvim_get_current_win()
        if cur_win and vim.api.nvim_win_is_valid(cur_win) then
          active_cursor = vim.api.nvim_win_get_cursor(cur_win)
        end
      end
    end
  end

  if not active_path and last_active_file and seen[last_active_file] then
    active_path = last_active_file
  elseif active_path then
    last_active_file = active_path
  end

  local sidebar_open = (vim.g.minimal_sidebar_open ~= false)
  local expanded_dirs = {}
  local ok_t, t_api = pcall(require, "nvim-tree.api")
  if ok_t and t_api.tree then
    if t_api.tree.is_visible() then
      sidebar_open = true
    elseif vim.g.minimal_sidebar_open == nil then
      sidebar_open = false
    end
    local ok_core, nt_core = pcall(require, "nvim-tree.core")
    if ok_core and nt_core.get_explorer then
      local exp = nt_core.get_explorer()
      if exp and exp.nodes then
        local function collect_open(nodes)
          for _, n in ipairs(nodes) do
            if n.nodes and n.open and n.absolute_path then
              table.insert(expanded_dirs, n.absolute_path)
              collect_open(n.nodes)
            end
          end
        end
        collect_open(exp.nodes)
      end
    end
  end

  local has_workspace = (#file_paths > 0) or (vim.g.explicit_workspace_opened == true)

  local session_data = {
    cwd = vim.fn.getcwd(),
    files = file_paths,
    active_file = active_path,
    cursor = active_cursor,
    sidebar_open = sidebar_open,
    expanded_dirs = expanded_dirs,
    has_workspace = has_workspace,
  }

  pcall(vim.fn.mkdir, vim.fn.fnamemodify(session_file, ":p:h"), "p")
  local f = io.open(session_file, "w")
  if f then
    f:write(vim.fn.json_encode(session_data))
    f:close()
  end
end
_G.save_session = save_session

local function restore_session()
  if vim.fn.argc() > 0 then
    session_restored = true
    return
  end
  if _G.ensure_ui_chrome then _G.ensure_ui_chrome() end

  local function open_fallback_home()
    session_restored = true
    if _G.open_homescreen then _G.open_homescreen() end
    local ok_t, t_api = pcall(require, "nvim-tree.api")
    if ok_t then
      pcall(t_api.tree.open, { focus = false })
      vim.schedule(function()
        local tw = t_api.tree.winid()
        if tw and vim.api.nvim_win_is_valid(tw) then
          pcall(vim.api.nvim_win_set_width, tw, _G.sidebar_width or 24)
        end
        local ed = find_editor_win()
        if ed and vim.api.nvim_win_is_valid(ed) then
          vim.api.nvim_set_current_win(ed)
        end
      end)
    end
  end

  if vim.fn.filereadable(session_file) ~= 1 then
    open_fallback_home()
    return
  end

  local f = io.open(session_file, "r")
  if not f then
    open_fallback_home()
    return
  end
  local content = f:read("*a")
  f:close()

  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok or type(data) ~= "table" then
    open_fallback_home()
    return
  end

  local valid_files = {}
  if type(data.files) == "table" then
    for _, path in ipairs(data.files) do
      if type(path) == "string" and path ~= "" and vim.fn.filereadable(path) == 1 then
        table.insert(valid_files, path)
      end
    end
  end

  local has_cwd = (type(data.cwd) == "string" and data.cwd ~= "" and vim.fn.isdirectory(data.cwd) == 1)
  local should_restore = (#valid_files > 0) or (data.has_workspace == true and has_cwd)

  if not should_restore then
    open_fallback_home()
    return
  end

  if has_cwd then
    pcall(vim.cmd.cd, data.cwd)
    vim.g.explicit_workspace_opened = (data.has_workspace == true)
  end

  local initial_empty_buf = vim.api.nvim_get_current_buf()
  local opened_any = false
  if #valid_files > 0 then
    for _, path in ipairs(valid_files) do
      vim.cmd("silent! badd " .. vim.fn.fnameescape(path))
      opened_any = true
    end
  end

  if data.active_file and vim.fn.filereadable(data.active_file) == 1 then
    vim.cmd("silent! edit " .. vim.fn.fnameescape(data.active_file))
    last_active_file = data.active_file
    if data.cursor and type(data.cursor) == "table" and data.cursor[1] then
      pcall(vim.api.nvim_win_set_cursor, 0, { data.cursor[1], data.cursor[2] or 0 })
    end
  elseif opened_any and valid_files[1] then
    vim.cmd("silent! edit " .. vim.fn.fnameescape(valid_files[1]))
    last_active_file = valid_files[1]
  end

  -- Remove initial unnamed scratch buffer if files were restored
  if opened_any and vim.api.nvim_buf_is_valid(initial_empty_buf) then
    local init_name = vim.api.nvim_buf_get_name(initial_empty_buf)
    if init_name == "" and vim.bo[initial_empty_buf].buftype == "" and not vim.bo[initial_empty_buf].modified then
      vim.bo[initial_empty_buf].buflisted = false
      if initial_empty_buf ~= vim.api.nvim_get_current_buf() then
        pcall(vim.api.nvim_buf_delete, initial_empty_buf, { force = true })
      end
    end
  end

  local ok_t, t_api = pcall(require, "nvim-tree.api")
  if ok_t then
    if has_cwd then
      pcall(t_api.tree.change_root, data.cwd)
    end
    if data.sidebar_open ~= false then
      pcall(t_api.tree.open, { focus = false })
      if type(data.expanded_dirs) == "table" and #data.expanded_dirs > 0 then
        vim.schedule(function()
          local ok_core, nt_core = pcall(require, "nvim-tree.core")
          if ok_core and nt_core.get_explorer then
            local exp = nt_core.get_explorer()
            if exp and exp.nodes then
              local open_set = {}
              for _, p in ipairs(data.expanded_dirs) do open_set[p] = true end
              local function expand_matching(nodes)
                for _, n in ipairs(nodes) do
                  if n.nodes and n.absolute_path and open_set[n.absolute_path] then
                    if not n.open then
                      pcall(t_api.node.expand, n)
                    end
                    expand_matching(n.nodes)
                  end
                end
              end
              expand_matching(exp.nodes)
            end
          end
        end)
      end
    end
    vim.schedule(function()
      local tw = t_api.tree.winid()
      if tw and vim.api.nvim_win_is_valid(tw) then
        pcall(vim.api.nvim_win_set_width, tw, _G.sidebar_width or 24)
      end
    end)
  end

  session_restored = true

  if opened_any then
    local ed = find_editor_win()
    if ed and vim.api.nvim_win_is_valid(ed) then
      vim.api.nvim_set_current_win(ed)
      vim.cmd("startinsert")
    end
    if _G.reapply_all_icon_colors then
      vim.schedule(_G.reapply_all_icon_colors)
    end
  else
    -- Workspace folder opened with no open files
    if _G.open_homescreen then _G.open_homescreen() end
  end
end

-- Track active file and persist session safely (debounced to keep tab switches instant)
local session_save_timer = nil
local function schedule_save_session()
  if session_save_timer then
    session_save_timer:stop()
    session_save_timer:close()
    session_save_timer = nil
  end
  session_save_timer = vim.defer_fn(function()
    session_save_timer = nil
    if not is_quitting and session_restored then
      save_session()
    end
  end, 150)
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusLost" }, {
  callback = function()
    if is_quitting or not session_restored then return end
    local cb = vim.api.nvim_get_current_buf()
    if vim.bo[cb].buftype == "" and vim.bo[cb].filetype ~= "minimal_home" and vim.bo[cb].filetype ~= "NvimTree" then
      local n = vim.api.nvim_buf_get_name(cb)
      if n ~= "" and vim.fn.filereadable(n) == 1 then
        last_active_file = n
      end
    end
    schedule_save_session()
  end,
})

vim.api.nvim_create_autocmd({ "BufDelete", "DirChanged" }, {
  callback = function()
    if is_quitting or not session_restored then return end
    schedule_save_session()
  end,
})

vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    if not is_quitting then
      autosave_all_modified()
      save_session()
    end
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if not is_quitting then
      autosave_all_modified()
      save_session()
      is_quitting = true
      vim.g.minimal_is_quitting = true
    end
  end,
})

-- Debounced autosave while typing (pauses for 1.2s)
local autosave_timer = nil
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  callback = function()
    if autosave_timer then
      autosave_timer:stop()
      autosave_timer:close()
      autosave_timer = nil
    end
    autosave_timer = vim.defer_fn(function()
      autosave_all_modified()
      autosave_timer = nil
    end, 1200)
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  nested = true,
  callback = function()
    vim.g.startup_done = true
    if vim.fn.argc() == 0 then
      vim.schedule(restore_session)
    else
      session_restored = true
    end
  end,
})

-- =============================================================================
-- INTERACTIVE MODAL SEARCHBAR ENGINE (Smooth typing, cursor navigation & word ops)
-- =============================================================================
local function make_searchbar(initial_text, on_change)
  local sb = {
    text = initial_text or "",
    pos = #(initial_text or "") + 1,
  }

  function sb.get_text()
    return sb.text
  end

  function sb.set_text(t)
    sb.text = t or ""
    sb.pos = #sb.text + 1
    if on_change then on_change(sb.text) end
  end

  function sb.get_display_line(prompt, placeholder)
    prompt = prompt or "  Search: "
    placeholder = placeholder or "(type to filter...)"
    if sb.text == "" then
      return prompt .. "▏" .. (placeholder ~= "" and (" " .. placeholder) or "")
    else
      local before = sb.text:sub(1, sb.pos - 1)
      local after = sb.text:sub(sb.pos)
      return prompt .. before .. "▏" .. after
    end
  end

  function sb.insert(ch)
    sb.text = sb.text:sub(1, sb.pos - 1) .. ch .. sb.text:sub(sb.pos)
    sb.pos = sb.pos + #ch
    if on_change then on_change(sb.text) end
  end

  function sb.backspace()
    if sb.pos > 1 then
      sb.text = sb.text:sub(1, sb.pos - 2) .. sb.text:sub(sb.pos)
      sb.pos = sb.pos - 1
      if on_change then on_change(sb.text) end
    end
  end

  function sb.delete_forward()
    if sb.pos <= #sb.text then
      sb.text = sb.text:sub(1, sb.pos - 1) .. sb.text:sub(sb.pos + 1)
      if on_change then on_change(sb.text) end
    end
  end

  function sb.move_left()
    if sb.pos > 1 then
      sb.pos = sb.pos - 1
      if on_change then on_change(sb.text) end
    end
  end

  function sb.move_right()
    if sb.pos <= #sb.text then
      sb.pos = sb.pos + 1
      if on_change then on_change(sb.text) end
    end
  end

  function sb.move_word_left()
    if sb.pos <= 1 then return end
    local p = sb.pos - 1
    while p > 1 and sb.text:sub(p, p):match("%s") do p = p - 1 end
    while p > 1 and not sb.text:sub(p - 1, p - 1):match("%s") do p = p - 1 end
    sb.pos = p
    if on_change then on_change(sb.text) end
  end

  function sb.move_word_right()
    local len = #sb.text
    if sb.pos > len then return end
    local p = sb.pos
    while p <= len and not sb.text:sub(p, p):match("%s") do p = p + 1 end
    while p <= len and sb.text:sub(p, p):match("%s") do p = p + 1 end
    sb.pos = p
    if on_change then on_change(sb.text) end
  end

  function sb.delete_word_backward()
    if sb.pos <= 1 then return end
    local p = sb.pos - 1
    while p > 1 and sb.text:sub(p, p):match("%s") do p = p - 1 end
    while p > 1 and not sb.text:sub(p - 1, p - 1):match("%s") do p = p - 1 end
    sb.text = sb.text:sub(1, p - 1) .. sb.text:sub(sb.pos)
    sb.pos = p
    if on_change then on_change(sb.text) end
  end

  function sb.delete_word_forward()
    local len = #sb.text
    if sb.pos > len then return end
    local p = sb.pos
    while p <= len and not sb.text:sub(p, p):match("%s") do p = p + 1 end
    while p <= len and sb.text:sub(p, p):match("%s") do p = p + 1 end
    sb.text = sb.text:sub(1, sb.pos - 1) .. sb.text:sub(p)
    if on_change then on_change(sb.text) end
  end

  function sb.home()
    if sb.pos ~= 1 then
      sb.pos = 1
      if on_change then on_change(sb.text) end
    end
  end

  function sb.end_pos()
    local target = #sb.text + 1
    if sb.pos ~= target then
      sb.pos = target
      if on_change then on_change(sb.text) end
    end
  end

  function sb.clear()
    sb.text = ""
    sb.pos = 1
    if on_change then on_change(sb.text) end
  end

  return sb
end

local function bind_searchbar_keys(buf, sb, is_active_fn)
  local function active()
    if is_active_fn then return is_active_fn() end
    return true
  end

  -- Printable characters (32 to 126)
  for c = 32, 126 do
    local ch = string.char(c)
    vim.keymap.set({ "n", "i", "s", "v" }, ch, function()
      if active() then
        sb.insert(ch)
      end
    end, { buffer = buf, nowait = true })
  end

  -- Arrow cursor navigation inside search query
  vim.keymap.set({ "n", "i", "s", "v" }, "<Left>", function() if active() then sb.move_left() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<Right>", function() if active() then sb.move_right() end end, { buffer = buf, nowait = true })

  -- Word jumping (Ctrl+Left / Ctrl+Right and Alt+Left / Alt+Right)
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-Left>", function() if active() then sb.move_word_left() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-Right>", function() if active() then sb.move_word_right() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-Left>", function() if active() then sb.move_word_left() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-Right>", function() if active() then sb.move_word_right() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-b>", function() if active() then sb.move_word_left() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-f>", function() if active() then sb.move_word_right() end end, { buffer = buf, nowait = true })

  -- Home / End
  vim.keymap.set({ "n", "i", "s", "v" }, "<Home>", function() if active() then sb.home() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<End>", function() if active() then sb.end_pos() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-a>", function() if active() then sb.home() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-e>", function() if active() then sb.end_pos() end end, { buffer = buf, nowait = true })

  -- Backspace / Delete
  vim.keymap.set({ "n", "i", "s", "v" }, "<BS>", function() if active() then sb.backspace() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-h>", function() if active() then sb.backspace() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<Del>", function() if active() then sb.delete_forward() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<Delete>", function() if active() then sb.delete_forward() end end, { buffer = buf, nowait = true })

  -- Word deletions (Ctrl+Backspace / Alt+Backspace / Ctrl+W)
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-BS>", function() if active() then sb.delete_word_backward() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-BackSpace>", function() if active() then sb.delete_word_backward() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-BS>", function() if active() then sb.delete_word_backward() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-BackSpace>", function() if active() then sb.delete_word_backward() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-w>", function() if active() then sb.delete_word_backward() end end, { buffer = buf, nowait = true })

  -- Word deletions forward (Ctrl+Delete / Alt+Delete)
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-Del>", function() if active() then sb.delete_word_forward() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-Delete>", function() if active() then sb.delete_word_forward() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-Del>", function() if active() then sb.delete_word_forward() end end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-Delete>", function() if active() then sb.delete_word_forward() end end, { buffer = buf, nowait = true })

  -- Clear query
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-u>", function() if active() then sb.clear() end end, { buffer = buf, nowait = true })

  -- Block editor mutations so undo / cut / duplicate / insert NEVER corrupt the menu
  local block_keys = { "<C-z>", "<C-y>", "<C-r>", "<C-d>", "<C-x>", "<C-s>", "<S-Del>", "<S-Delete>", "<Insert>" }
  for _, bk in ipairs(block_keys) do
    vim.keymap.set({ "n", "i", "s", "v" }, bk, "<nop>", { buffer = buf, nowait = true })
  end

  for _, wk in ipairs({ "<C-w>w", "<C-w>h", "<C-w>j", "<C-w>k", "<C-w>l", "<C-w><Up>", "<C-w><Down>", "<C-w><Left>", "<C-w><Right>" }) do
    vim.keymap.set({ "n", "i", "s", "v" }, wk, "<nop>", { buffer = buf, nowait = true })
  end
end

_G.make_searchbar = make_searchbar
_G.bind_searchbar_keys = bind_searchbar_keys

-- 18. MINIMAL CODE EDITOR THEMES ENGINE & LIVE PREVIEW SELECTOR (Ctrl+K Ctrl+T)
_G.ThemeEngine = {}
local ThemeEngine = _G.ThemeEngine
ThemeEngine.themes = {
  { id = "darkmagic", name = "Dark Magic", desc = "Neon Synthwave & Cyberpunk (#07070f)" },
  { id = "cyberaurora", name = "Cyber Aurora", desc = "High-contrast Electric Aurora on Deep Midnight" },
  { id = "medieval", name = "Medieval Scriptorium", desc = "Illuminated Manuscript, Dragon Gold & Castle Stone (#0e0d0b)" },
  { id = "nocturne", name = "Crimson Nocturne", desc = "Gothic Black Velvet, Mahogany & Dragon Ruby (#0b0709)" },
}

local theme_state_file = vim.fn.stdpath("state") .. "/active_theme.txt"

function ThemeEngine.get_active_theme()
  if vim.fn.filereadable(theme_state_file) == 1 then
    local lines = vim.fn.readfile(theme_state_file)
    if lines and lines[1] and lines[1]:match("%S") then
      local saved = vim.trim(lines[1])
      for _, t in ipairs(ThemeEngine.themes) do
        if t.id == saved then return saved end
      end
    end
  end
  return "darkmagic"
end

function ThemeEngine.save_active_theme(theme_id)
  pcall(vim.fn.mkdir, vim.fn.fnamemodify(theme_state_file, ":p:h"), "p")
  vim.fn.writefile({ theme_id }, theme_state_file)
end

function ThemeEngine.apply_theme(theme_id)
  pcall(vim.cmd, "colorscheme " .. theme_id)
  -- Maintain sidebar and float highlights across theme changes
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#61afef", bg = "#1e222a" })
  vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#abb2bf", bg = "#1e222a" })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticErrorFileHLGroup", { fg = "#f38ba8", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticWarnFileHLGroup", { fg = "#fab387", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeGitDirty", { fg = "#fab387", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeGitStaged", { fg = "#a6e3a1", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeGitNew", { fg = "#a6e3a1", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeGitDeleted", { fg = "#f38ba8" })
  vim.api.nvim_set_hl(0, "NvimTreeGitRenamed", { fg = "#cba6f7" })

  -- Subtle, ultra-faint greyish separation border line (barely noticeable distinction)
  local subtle_grey = "#1c1f26"
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = subtle_grey, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "VertSplit", { fg = subtle_grey, bg = "NONE", bold = false })
  vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = subtle_grey, bg = "NONE", bold = false })

  -- Minimal Homescreen Highlights
  vim.api.nvim_set_hl(0, "MinimalHomeBanner", { fg = "#61afef", bold = true })
  vim.api.nvim_set_hl(0, "MinimalHomeTagline", { fg = "#7f848e", italic = true })
  vim.api.nvim_set_hl(0, "MinimalHomeSubtitle", { fg = "#7f848e", italic = true })
  vim.api.nvim_set_hl(0, "MinimalHomeKey", { fg = "#e5c07b", bold = true })
  vim.api.nvim_set_hl(0, "MinimalHomeDesc", { fg = "#abb2bf" })
  vim.api.nvim_set_hl(0, "MinimalHomeHint", { fg = "#5c6370" })
  vim.api.nvim_set_hl(0, "MinimalHomeHeader", { fg = "#98c379", bold = true })
  vim.api.nvim_set_hl(0, "MinimalHomeRecent", { fg = "#61afef" })
  vim.api.nvim_set_hl(0, "MinimalHomeArrow", { fg = "#61afef", bold = true })

  -- Multi-Cursor & Menu Picker Highlights
  vim.api.nvim_set_hl(0, "MultipleCursorsCursor", { bg = "#61afef", fg = "#1e222a", bold = true })
  vim.api.nvim_set_hl(0, "MultipleCursorsLockedCursor", { bg = "#98c379", fg = "#1e222a", bold = true })
  vim.api.nvim_set_hl(0, "MultipleCursorsVisual", { bg = "#3e4451" })
  vim.api.nvim_set_hl(0, "MenuCursorHidden", { blend = 100, fg = "#1e222a", bg = "#1e222a" })
  vim.api.nvim_set_hl(0, "FolderCursorHidden", { blend = 100, fg = "#2d3545", bg = "#2d3545" })
  vim.api.nvim_set_hl(0, "FolderPickerSelected", { fg = "#ffffff", bg = "#2d3545", bold = true })

  if _G.reapply_all_icon_colors then
    _G.reapply_all_icon_colors()
  end
  if _G.apply_markdown_highlights then
    _G.apply_markdown_highlights()
  end
end

_G.open_theme_picker = function()
  local prev_theme = vim.g.colors_name or ThemeEngine.get_active_theme()
  local active_id = prev_theme
  local active_sel = 1
  local filtered = {}

  local buf = vim.api.nvim_create_buf(false, true)
  vim.b[buf].is_picker = true
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].undolevels = -1

  for i, t in ipairs(ThemeEngine.themes) do
    if t.id == active_id then
      active_sel = i
      break
    end
  end

  local ui = vim.api.nvim_list_uis()[1] or { width = 120, height = 40 }
  local width = 48
  local height = math.min(16, #ThemeEngine.themes + 4)
  local row = math.max(1, math.floor((ui.height - height) / 3))
  local col = math.max(1, math.floor((ui.width - width) / 2))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = string.format(" Themes (%d Installed) ", #ThemeEngine.themes),
    title_pos = "center",
  })

  vim.cmd("stopinsert")
  vim.wo[win].cursorline = false
  vim.wo[win].wrap = false
  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

  local confirmed = false

  local function cancel_selection()
    if not confirmed then
      ThemeEngine.apply_theme(prev_theme)
    end
    pcall(vim.api.nvim_win_close, win, true)
    local ed = find_editor_win()
    if ed and vim.api.nvim_win_is_valid(ed) then
      vim.api.nvim_set_current_win(ed)
    end
    vim.cmd("startinsert")
    _G.clear_active_menu(cancel_selection)
  end

  _G.register_active_menu(cancel_selection, win)

  vim.api.nvim_set_hl(0, "ThemeItemArrow", { fg = "#61afef", bold = true })

  local sb = nil

  local function render(update_preview)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local query = sb and sb.get_text() or ""
    filtered = {}
    for _, t in ipairs(ThemeEngine.themes) do
      if query == "" or t.name:lower():find(query:lower(), 1, true) or t.id:lower():find(query:lower(), 1, true) then
        table.insert(filtered, t)
      end
    end

    local search_line = sb and sb.get_display_line("  Search: ", "(type to filter...)") or "  Search: ▏ (type to filter...)"
    local lines = {
      search_line,
      "  ────────────────────────────────────────────",
    }

    if #filtered == 0 then
      table.insert(lines, "   No matching themes found")
    else
      if active_sel > #filtered then active_sel = #filtered end
      if active_sel < 1 then active_sel = 1 end
      for i, t in ipairs(filtered) do
        local prefix = (i == active_sel) and " > " or "   "
        table.insert(lines, prefix .. t.name)
      end
    end

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    local ns_id = vim.api.nvim_create_namespace("theme_picker_hl")
    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

    if #filtered > 0 and vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_set_cursor, win, { 2 + active_sel, 1 })
      pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "ThemeItemArrow", 2 + active_sel - 1, 0, 4)
      if update_preview ~= false then
        local sel = filtered[active_sel]
        if sel then
          ThemeEngine.apply_theme(sel.id)
        end
      end
    end
  end

  sb = make_searchbar("", function()
    active_sel = 1
    render(true)
  end)

  bind_searchbar_keys(buf, sb)

  render(false)

  local function confirm_selection()
    confirmed = true
    if #filtered > 0 then
      local sel = filtered[active_sel] or filtered[1]
      ThemeEngine.apply_theme(sel.id)
      ThemeEngine.save_active_theme(sel.id)
      vim.notify("Active theme: " .. sel.name, vim.log.levels.INFO)
    else
      ThemeEngine.apply_theme(prev_theme)
    end
    pcall(vim.api.nvim_win_close, win, true)
    local ed = find_editor_win()
    if ed and vim.api.nvim_win_is_valid(ed) then
      vim.api.nvim_set_current_win(ed)
    end
    vim.cmd("startinsert")
    _G.clear_active_menu(cancel_selection)
  end

  local function move_up()
    if #filtered == 0 then return end
    active_sel = active_sel - 1
    if active_sel < 1 then active_sel = #filtered end
    render(true)
  end

  local function move_down()
    if #filtered == 0 then return end
    active_sel = active_sel + 1
    if active_sel > #filtered then active_sel = 1 end
    render(true)
  end

  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = buf,
    once = true,
    callback = cancel_selection,
  })

  vim.keymap.set({ "n", "i", "s", "v" }, "<CR>", confirm_selection, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<Esc>", cancel_selection, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-c>", cancel_selection, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "q", cancel_selection, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Up>", move_up, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-p>", move_up, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<Down>", move_down, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-n>", move_down, { buffer = buf, nowait = true })
end

-- =============================================================================
-- UNIFIED APPEARANCE & FONT CONFIGURATION ENGINE (Ctrl+Shift+K+T)
-- Multi-target control:
--   1: Editor   -> Family (live filter), Size (9..24pt), Weight (b/w500/w600), Spacing
--   2: Sidebar  -> Combined Scale Presets, Width, Icon Padding, Indent Depth, Chevrons, Git Badges
--   3: Terminal -> Drawer Height, Shell Profile, Line Spacing
-- =============================================================================
_G.FontEngine = {}
local FontEngine = _G.FontEngine
FontEngine.config_file = vim.fn.stdpath("state") .. "/font_config.json"
FontEngine.legacy_file = vim.fn.stdpath("state") .. "/active_font.txt"
FontEngine.cached_fonts = nil

FontEngine.font_sizes = { "9", "9.5", "10", "10.5", "11", "11.5", "12", "12.5", "13", "14", "15", "16", "18", "20", "24" }
FontEngine.font_weights = {
  { id = "regular", name = "Regular", bold = false },
  { id = "bold", name = "Bold (:b)", bold = true },
  { id = "w500", name = "Medium (:w500)", bold = false },
  { id = "w600", name = "SemiBold (:w600)", bold = false },
}
FontEngine.line_spacings = {
  { val = -2, name = "Compact (-2 px)" },
  { val = 0, name = "Standard (0 px)" },
  { val = 2, name = "Relaxed (+2 px)" },
  { val = 4, name = "Spacious (+4 px)" },
}

FontEngine.scale_presets = {
  { id = "compact", name = "Compact (20 cols, 1-sp icon, 1-sp indent)", width = 20, padding = " ", indent = 1 },
  { id = "standard", name = "Standard (24 cols, 1-sp icon, 2-sp indent)", width = 24, padding = " ", indent = 2 },
  { id = "comfortable", name = "Comfortable (28 cols, 2-sp icon, 2-sp indent)", width = 28, padding = "  ", indent = 2 },
  { id = "spacious", name = "Spacious (32 cols, 2-sp icon, 3-sp indent)", width = 32, padding = "  ", indent = 3 },
  { id = "expanded", name = "Expanded (36 cols, 3-sp icon, 4-sp indent)", width = 36, padding = "   ", indent = 4 },
  { id = "roomy", name = "Roomy (40 cols, 3-sp icon, 4-sp indent)", width = 40, padding = "   ", indent = 4 },
}

FontEngine.sidebar_widths = {
  { val = 20, name = "20 columns (Ultra-compact)" },
  { val = 24, name = "24 columns (Standard compact)" },
  { val = 28, name = "28 columns (Medium comfortable)" },
  { val = 32, name = "32 columns (Spacious wide)" },
  { val = 36, name = "36 columns (Expanded wide)" },
  { val = 40, name = "40 columns (Extra roomy)" },
}

FontEngine.icon_paddings = {
  { val = "", name = "None (0 spaces - flush with folder arrows)" },
  { val = " ", name = "Compact (1 space - clean standard)" },
  { val = "  ", name = "Spacious (2 spaces - distinct separation)" },
  { val = "   ", name = "Expanded (3 spaces - wide layout)" },
}

FontEngine.indent_widths = {
  { val = 1, name = "1 space (Tight tree)" },
  { val = 2, name = "2 spaces (Standard clean tree)" },
  { val = 3, name = "3 spaces (Spacious stepped tree)" },
  { val = 4, name = "4 spaces (Deep indented hierarchy)" },
}

FontEngine.chevron_styles = {
  { id = "sleek", name = "Minimalist Sleek (› / ⌄)", closed = "›", open = "⌄" },
  { id = "nerd", name = "Nerd Font Angles ( / )", closed = "", open = "" },
  { id = "arrows", name = "Solid Triangles (▶ / ▼)", closed = "▶", open = "▼" },
  { id = "plusminus", name = "Plus / Minus (+ / -)", closed = "+", open = "-" },
  { id = "hidden", name = "Hidden (No arrows, folder icons only)", closed = " ", open = " " },
}

FontEngine.git_badge_styles = {
  { id = "after", name = "After Filename (Clean ASCII: M, A, U, !)", placement = "after", show = true, style = "letters" },
  { id = "dot", name = "Subtle Middle Dot (·)", placement = "after", show = true, style = "dot" },
  { id = "hidden", name = "Hidden (Distraction-Free, no git clutter)", placement = "after", show = false, style = "none" },
}

FontEngine.terminal_heights = {
  { val = 10, name = "10 rows (Compact drawer)" },
  { val = 14, name = "14 rows (Small drawer)" },
  { val = 18, name = "18 rows (Standard balanced)" },
  { val = 22, name = "22 rows (Medium comfort)" },
  { val = 26, name = "26 rows (Large workstation)" },
  { val = 30, name = "30 rows (Expanded drawer)" },
}

FontEngine.terminal_shells = {
  { id = "auto", name = "Auto-Detect Default Shell" },
  { id = "bash", name = "Bash (/bin/bash)" },
  { id = "zsh", name = "Zsh (/usr/bin/zsh)" },
  { id = "sh", name = "Standard POSIX Shell (/bin/sh)" },
}

FontEngine.terminal_line_spacings = {
  { val = -2, name = "Compact (-2 px)" },
  { val = 0, name = "Standard (0 px)" },
  { val = 2, name = "Relaxed (+2 px)" },
}

function FontEngine.get_installed_fonts()
  if not FontEngine.cached_fonts then
    local list = vim.fn.systemlist("fc-list : family | tr ',' '\n' | sed 's/^[ \t]*//' | grep -v '^[.]' | grep -v '^$' | sort -u")
    local filtered = {}
    for _, f in ipairs(list) do
      f = vim.trim(f)
      if f ~= "" and not f:match("^[%.@]") then
        table.insert(filtered, f)
      end
    end
    if #filtered == 0 then
      filtered = { "CaskaydiaCove Nerd Font", "FiraCode Nerd Font", "JetBrainsMono Nerd Font", "Monospace" }
    end
    FontEngine.cached_fonts = filtered
  end
  return FontEngine.cached_fonts
end

function FontEngine.get_config()
  local legacy_name = "CaskaydiaCove Nerd Font"
  if vim.fn.filereadable(FontEngine.legacy_file) == 1 then
    local l = vim.fn.readfile(FontEngine.legacy_file)
    if l and l[1] and l[1]:match("%S") then
      legacy_name = vim.trim(l[1])
    end
  end

  local cfg = {
    target = 1,
    editor = {
      family = legacy_name,
      size = "11.5",
      bold = false,
      weight = "regular",
      line_space = 0,
    },
    sidebar = {
      scale = 2,
      width = 24,
      icon_padding = " ",
      indent_width = 2,
      chevron_style = 1,
      git_badge = 1,
    },
    terminal = {
      height = 18,
      shell = "auto",
      line_space = 0,
    },
  }

  if vim.fn.filereadable(FontEngine.config_file) == 1 then
    local content = vim.fn.readfile(FontEngine.config_file)
    if content and #content > 0 then
      local ok, data = pcall(vim.fn.json_decode, table.concat(content, "\n"))
      if ok and type(data) == "table" then
        if data.editor and type(data.editor) == "table" then
          cfg.editor.family = tostring(data.editor.family or cfg.editor.family)
          cfg.editor.size = tostring(data.editor.size or cfg.editor.size)
          cfg.editor.weight = tostring(data.editor.weight or cfg.editor.weight)
          cfg.editor.bold = (data.editor.bold == true or cfg.editor.weight == "bold")
          cfg.editor.line_space = tonumber(data.editor.line_space) or 0
        elseif data.family then
          cfg.editor.family = tostring(data.family)
          cfg.editor.size = tostring(data.size or "11.5")
          cfg.editor.weight = tostring(data.weight or "regular")
          cfg.editor.bold = (data.bold == true or cfg.editor.weight == "bold")
          cfg.editor.line_space = tonumber(data.line_space) or 0
        end

        if data.sidebar and type(data.sidebar) == "table" then
          cfg.sidebar.scale = tonumber(data.sidebar.scale) or cfg.sidebar.scale
          cfg.sidebar.width = tonumber(data.sidebar.width) or cfg.sidebar.width
          if data.sidebar.icon_padding ~= nil then cfg.sidebar.icon_padding = data.sidebar.icon_padding end
          cfg.sidebar.indent_width = tonumber(data.sidebar.indent_width) or cfg.sidebar.indent_width
          cfg.sidebar.chevron_style = tonumber(data.sidebar.chevron_style) or cfg.sidebar.chevron_style
          cfg.sidebar.git_badge = tonumber(data.sidebar.git_badge) or cfg.sidebar.git_badge
        end

        if data.terminal and type(data.terminal) == "table" then
          cfg.terminal.height = tonumber(data.terminal.height) or cfg.terminal.height
          if data.terminal.shell then cfg.terminal.shell = tostring(data.terminal.shell) end
          cfg.terminal.line_space = tonumber(data.terminal.line_space) or cfg.terminal.line_space
        end

        cfg.target = tonumber(data.target) or 1
      end
    end
  end

  cfg.family = cfg.editor.family
  cfg.size = cfg.editor.size
  cfg.weight = cfg.editor.weight
  cfg.bold = cfg.editor.bold
  cfg.line_space = cfg.editor.line_space

  return cfg
end

function FontEngine.save_config(cfg)
  if not cfg then return end
  pcall(vim.fn.mkdir, vim.fn.fnamemodify(FontEngine.config_file, ":p:h"), "p")
  local out = {
    target = cfg.target or 1,
    family = (cfg.editor and cfg.editor.family) or cfg.family or "CaskaydiaCove Nerd Font",
    size = (cfg.editor and cfg.editor.size) or cfg.size or "11.5",
    weight = (cfg.editor and cfg.editor.weight) or cfg.weight or "regular",
    bold = (cfg.editor and cfg.editor.bold) or cfg.bold or false,
    line_space = (cfg.editor and cfg.editor.line_space) or cfg.line_space or 0,
    editor = cfg.editor or {
      family = cfg.family or "CaskaydiaCove Nerd Font",
      size = cfg.size or "11.5",
      weight = cfg.weight or "regular",
      bold = cfg.bold or false,
      line_space = cfg.line_space or 0,
    },
    sidebar = cfg.sidebar or {
      scale = 2,
      width = 24,
      icon_padding = " ",
      indent_width = 2,
      chevron_style = 1,
      git_badge = 1,
    },
    terminal = cfg.terminal or {
      height = 18,
      shell = "auto",
      line_space = 0,
    },
  }
  local encoded = vim.fn.json_encode(out)
  vim.fn.writefile({ encoded }, FontEngine.config_file)
  pcall(vim.fn.writefile, { out.family }, FontEngine.legacy_file)
end

function FontEngine.apply_config(cfg)
  if not cfg then return end
  local ed = cfg.editor or cfg
  if ed and ed.family and ed.family ~= "" then
    local fam = ed.family
    if not fam:lower():find("nerd") and not fam:lower():find("nf") then
      fam = fam .. ",CaskaydiaCove Nerd Font Propo,JetBrainsMono Nerd Font Propo"
    end
    local font_str = fam .. ":h" .. (ed.size or "11.5")
    if ed.bold or ed.weight == "bold" then
      font_str = font_str .. ":b"
    elseif ed.weight and ed.weight ~= "regular" and ed.weight ~= "" then
      font_str = font_str .. ":" .. ed.weight
    end
    pcall(function()
      vim.o.guifont = font_str
    end)
    if vim.g.neovide then
      pcall(function()
        vim.g.neovide_line_space = tonumber(ed.line_space) or 0
      end)
    end
  end

  local sb = cfg.sidebar
  if sb then
    if sb.width then
      _G.sidebar_width = tonumber(sb.width) or 24
    end
    local tree_loaded = package.loaded["nvim-tree"]
    if tree_loaded then
      local ok_api, api = pcall(require, "nvim-tree.api")
      local chev = FontEngine.chevron_styles[sb.chevron_style] or FontEngine.chevron_styles[1]
      local git_opt = FontEngine.git_badge_styles[sb.git_badge] or FontEngine.git_badge_styles[1]
      local git_glyphs = {
        unstaged = (git_opt.style == "dot") and "·" or "M",
        staged = (git_opt.style == "dot") and "·" or "A",
        unmerged = "!",
        renamed = "R",
        untracked = (git_opt.style == "dot") and "·" or "U",
        deleted = "D",
        ignored = "·",
      }
      local decorators = _G.minimal_icon_decorator and {
        "Git", "Open", "Hidden", "Modified", "Bookmark", "Diagnostics", "Copied", _G.minimal_icon_decorator, "Cut"
      } or nil

      pcall(function()
        tree_loaded.setup({
          view = {
            width = _G.sidebar_width,
            side = "left",
            signcolumn = "no",
            cursorline = true,
            preserve_window_proportions = true,
          },
          renderer = {
            indent_width = tonumber(sb.indent_width) or 2,
            decorators = decorators,
            icons = {
              padding = sb.icon_padding or " ",
              git_placement = git_opt.placement or "after",
              modified_placement = "after",
              show = {
                file = true,
                folder = true,
                folder_arrow = (chev.id ~= "hidden"),
                git = git_opt.show,
                modified = true,
                diagnostics = true,
              },
              glyphs = {
                folder = {
                  arrow_closed = chev.closed or "›",
                  arrow_open = chev.open or "⌄",
                },
                git = git_glyphs,
              },
            },
          },
        })
        if ok_api and api.tree.is_visible() then
          api.tree.resize({ width = _G.sidebar_width })
          api.tree.reload()
        end
      end)
    end
  end

  local tm = cfg.terminal
  if tm and tm.height then
    term_height = tonumber(tm.height) or 18
    _G.term_height = term_height
    if term_win and vim.api.nvim_win_is_valid(term_win) then
      pcall(vim.api.nvim_win_set_height, term_win, term_height)
    end
  end
end

function FontEngine.get_active_font()
  return FontEngine.get_config().family
end

function FontEngine.apply_font(font_name)
  local cfg = FontEngine.get_config()
  cfg.editor.family = font_name
  cfg.family = font_name
  FontEngine.apply_config(cfg)
end

function FontEngine.save_active_font(font_name)
  local cfg = FontEngine.get_config()
  cfg.editor.family = font_name
  cfg.family = font_name
  FontEngine.save_config(cfg)
end

_G.open_font_picker = function()
  local all_fonts = FontEngine.get_installed_fonts()
  local initial_cfg = FontEngine.get_config()
  local working_cfg = vim.deepcopy(initial_cfg)

  local targets = {
    { id = 1, name = "Editor" },
    { id = 2, name = "Sidebar" },
    { id = 3, name = "Terminal" },
  }

  local subtabs = {
    [1] = {
      { id = 1, name = "1: Family" },
      { id = 2, name = "2: Size" },
      { id = 3, name = "3: Weight" },
      { id = 4, name = "4: Spacing" },
    },
    [2] = {
      { id = 1, name = "1: Scale" },
      { id = 2, name = "2: Width" },
      { id = 3, name = "3: Icons" },
      { id = 4, name = "4: Indent" },
      { id = 5, name = "5: Chevrons" },
      { id = 6, name = "6: Badges" },
    },
    [3] = {
      { id = 1, name = "1: Drawer Height" },
      { id = 2, name = "2: Shell Profile" },
      { id = 3, name = "3: Line Spacing" },
    },
  }

  local active_target = working_cfg.target or 1
  if active_target < 1 or active_target > 3 then active_target = 1 end
  local active_subtab = 1
  local filtered_fonts = {}

  local sel_idx = {
    [1] = { [1] = 1, [2] = 1, [3] = 1, [4] = 1 },
    [2] = { [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1 },
    [3] = { [1] = 1, [2] = 1, [3] = 1 },
  }

  -- Target 1 (Editor) initial selections
  for i, f in ipairs(all_fonts) do
    if f == working_cfg.editor.family then
      sel_idx[1][1] = i
      break
    end
  end
  for i, s in ipairs(FontEngine.font_sizes) do
    if s == working_cfg.editor.size then
      sel_idx[1][2] = i
      break
    end
  end
  for i, w in ipairs(FontEngine.font_weights) do
    if w.id == working_cfg.editor.weight or (working_cfg.editor.bold and w.id == "bold") then
      sel_idx[1][3] = i
      break
    end
  end
  for i, sp in ipairs(FontEngine.line_spacings) do
    if sp.val == working_cfg.editor.line_space then
      sel_idx[1][4] = i
      break
    end
  end

  -- Target 2 (Sidebar) initial selections
  sel_idx[2][1] = working_cfg.sidebar.scale or 2
  for i, w in ipairs(FontEngine.sidebar_widths) do
    if w.val == working_cfg.sidebar.width then
      sel_idx[2][2] = i
      break
    end
  end
  for i, p in ipairs(FontEngine.icon_paddings) do
    if p.val == working_cfg.sidebar.icon_padding then
      sel_idx[2][3] = i
      break
    end
  end
  for i, ind in ipairs(FontEngine.indent_widths) do
    if ind.val == working_cfg.sidebar.indent_width then
      sel_idx[2][4] = i
      break
    end
  end
  sel_idx[2][5] = working_cfg.sidebar.chevron_style or 1
  sel_idx[2][6] = working_cfg.sidebar.git_badge or 1

  -- Target 3 (Terminal) initial selections
  for i, h in ipairs(FontEngine.terminal_heights) do
    if h.val == working_cfg.terminal.height then
      sel_idx[3][1] = i
      break
    end
  end
  for i, sh in ipairs(FontEngine.terminal_shells) do
    if sh.id == working_cfg.terminal.shell then
      sel_idx[3][2] = i
      break
    end
  end
  for i, sp in ipairs(FontEngine.terminal_line_spacings) do
    if sp.val == working_cfg.terminal.line_space then
      sel_idx[3][3] = i
      break
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.b[buf].is_picker = true
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].undolevels = -1

  local ui = vim.api.nvim_list_uis()[1] or { width = vim.o.columns or 120, height = vim.o.lines or 40 }
  local width = math.min(84, math.max(68, ui.width - 4))
  local height = math.min(22, math.max(14, ui.height - 4))
  local row = math.max(1, math.floor((ui.height - height) / 3))
  local col = math.max(1, math.floor((ui.width - width) / 2))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = string.format(" Appearance & Font Settings (%d Fonts) ", #all_fonts),
    title_pos = "center",
    footer = " Tab: Target │ ←/→: Sub-tab │ ↑/↓: Select │ Enter: Save │ Esc: Close ",
    footer_pos = "center",
  })

  vim.cmd("stopinsert")
  vim.wo[win].cursorline = false
  vim.wo[win].wrap = false
  vim.wo[win].sidescrolloff = 0
  vim.wo[win].scrolloff = 2
  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

  local confirmed = false

  local function cancel_selection()
    if not confirmed then
      FontEngine.apply_config(initial_cfg)
    end
    pcall(vim.api.nvim_win_close, win, true)
    local ed = find_editor_win()
    if ed and vim.api.nvim_win_is_valid(ed) then
      vim.api.nvim_set_current_win(ed)
    end
    vim.cmd("startinsert")
    _G.clear_active_menu(cancel_selection)
  end

  _G.register_active_menu(cancel_selection, win)

  vim.api.nvim_set_hl(0, "FontTargetActive", { fg = "#ffffff", bg = "#2b5278", bold = true })
  vim.api.nvim_set_hl(0, "FontTargetInactive", { fg = "#7f848e", bg = "#21252b" })
  vim.api.nvim_set_hl(0, "FontSubtabActive", { fg = "#61afef", bold = true, underline = true })
  vim.api.nvim_set_hl(0, "FontSubtabInactive", { fg = "#abb2bf" })
  vim.api.nvim_set_hl(0, "FontItemArrow", { fg = "#61afef", bold = true })
  vim.api.nvim_set_hl(0, "FontItemActive", { fg = "#ffffff", bold = true })
  vim.api.nvim_set_hl(0, "FontItemInactive", { fg = "#9da5b4" })
  vim.api.nvim_set_hl(0, "FontDivider", { fg = "#3e4451" })
  vim.api.nvim_set_hl(0, "FontSearchPrompt", { fg = "#61afef", bold = true })
  vim.api.nvim_set_hl(0, "FontSearchPlaceholder", { fg = "#5c6370", italic = true })

  local sb
  local item_line_map = {}
  local target_row_idx = 2
  local subtab_row_idx = 4
  local target_spans = {}
  local subtab_spans = {}

  local function render(update_preview)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local query = sb and sb.get_text() or ""
    local lines = {}
    item_line_map = {}

    -- Top spacing
    table.insert(lines, "")

    -- Target Selector Pills
    local target_line = "  "
    target_spans = {}
    for _, t in ipairs(targets) do
      local s_col = #target_line
      local label = "  " .. t.id .. ": " .. t.name .. "  "
      target_line = target_line .. label
      local e_col = #target_line
      target_line = target_line .. "    "
      table.insert(target_spans, { id = t.id, s = s_col, e = e_col })
    end
    table.insert(lines, target_line)
    target_row_idx = #lines

    -- Spacing between targets and subtabs
    table.insert(lines, "")

    -- Sub-tabs for the current active target
    local cur_subtabs = subtabs[active_target] or {}
    local subtab_line = "  "
    subtab_spans = {}
    for idx, st in ipairs(cur_subtabs) do
      local s_col = #subtab_line
      local label = " " .. st.name .. " "
      subtab_line = subtab_line .. label
      local e_col = #subtab_line
      if idx < #cur_subtabs then
        subtab_line = subtab_line .. "│"
      end
      table.insert(subtab_spans, { id = st.id, s = s_col, e = e_col })
    end
    table.insert(lines, subtab_line)
    subtab_row_idx = #lines

    -- Spacing below subtabs
    table.insert(lines, "")

    -- Clean Divider line
    local div_len = math.min(width - 6, 72)
    local div_line = "  " .. string.rep("─", math.max(10, div_len))
    table.insert(lines, div_line)
    local divider_row_idx = #lines

    -- Spacing below divider
    table.insert(lines, "")

    -- Search header (Family tab only)
    local search_row_idx = nil
    if active_target == 1 and active_subtab == 1 then
      local search_line = sb and sb.get_display_line("  Search Font: ", "(type to filter fonts...)") or "  Search Font: ▏ (type to filter fonts...)"
      table.insert(lines, search_line)
      search_row_idx = #lines
      table.insert(lines, "")
    end

    -- Tab-specific item rows with breathable line gap above and below each line
    if active_target == 1 then
      if active_subtab == 1 then
        filtered_fonts = {}
        for _, f in ipairs(all_fonts) do
          if query == "" or f:lower():find(query:lower(), 1, true) then
            table.insert(filtered_fonts, f)
          end
        end
        if #filtered_fonts == 0 then
          table.insert(lines, "    No fonts matching '" .. query .. "'")
          table.insert(lines, "")
        else
          if sel_idx[1][1] > #filtered_fonts then sel_idx[1][1] = #filtered_fonts end
          if sel_idx[1][1] < 1 then sel_idx[1][1] = 1 end
          for i, f in ipairs(filtered_fonts) do
            local max_f_len = width - 10
            local display_f = (#f > max_f_len) and (f:sub(1, max_f_len - 1) .. "…") or f
            local prefix = (i == sel_idx[1][1]) and "  > " or "    "
            table.insert(lines, prefix .. display_f)
            item_line_map[i] = #lines
            table.insert(lines, "")
          end
          working_cfg.editor.family = filtered_fonts[sel_idx[1][1]]
          working_cfg.family = working_cfg.editor.family
        end
      elseif active_subtab == 2 then
        for i, s in ipairs(FontEngine.font_sizes) do
          local prefix = (i == sel_idx[1][2]) and "  > " or "    "
          table.insert(lines, prefix .. s .. " pt")
          item_line_map[i] = #lines
          table.insert(lines, "")
        end
      elseif active_subtab == 3 then
        for i, w in ipairs(FontEngine.font_weights) do
          local prefix = (i == sel_idx[1][3]) and "  > " or "    "
          table.insert(lines, prefix .. w.name)
          item_line_map[i] = #lines
          table.insert(lines, "")
        end
      elseif active_subtab == 4 then
        for i, sp in ipairs(FontEngine.line_spacings) do
          local prefix = (i == sel_idx[1][4]) and "  > " or "    "
          table.insert(lines, prefix .. sp.name)
          item_line_map[i] = #lines
          table.insert(lines, "")
        end
      end
    elseif active_target == 2 then
      if active_subtab == 1 then
        for i, sc in ipairs(FontEngine.scale_presets) do
          local prefix = (i == sel_idx[2][1]) and "  > " or "    "
          table.insert(lines, prefix .. sc.name)
          item_line_map[i] = #lines
          table.insert(lines, "")
        end
      elseif active_subtab == 2 then
        for i, w in ipairs(FontEngine.sidebar_widths) do
          local prefix = (i == sel_idx[2][2]) and "  > " or "    "
          table.insert(lines, prefix .. w.name)
          item_line_map[i] = #lines
          table.insert(lines, "")
        end
      elseif active_subtab == 3 then
        for i, p in ipairs(FontEngine.icon_paddings) do
          local prefix = (i == sel_idx[2][3]) and "  > " or "    "
          table.insert(lines, prefix .. p.name)
          item_line_map[i] = #lines
          table.insert(lines, "")
        end
      elseif active_subtab == 4 then
        for i, ind in ipairs(FontEngine.indent_widths) do
          local prefix = (i == sel_idx[2][4]) and "  > " or "    "
          table.insert(lines, prefix .. ind.name)
          item_line_map[i] = #lines
          table.insert(lines, "")
        end
      elseif active_subtab == 5 then
        for i, ch in ipairs(FontEngine.chevron_styles) do
          local prefix = (i == sel_idx[2][5]) and "  > " or "    "
          table.insert(lines, prefix .. ch.name)
          item_line_map[i] = #lines
          table.insert(lines, "")
        end
      elseif active_subtab == 6 then
        for i, gb in ipairs(FontEngine.git_badge_styles) do
          local prefix = (i == sel_idx[2][6]) and "  > " or "    "
          table.insert(lines, prefix .. gb.name)
          item_line_map[i] = #lines
          table.insert(lines, "")
        end
      end
    elseif active_target == 3 then
      if active_subtab == 1 then
        for i, h in ipairs(FontEngine.terminal_heights) do
          local prefix = (i == sel_idx[3][1]) and "  > " or "    "
          table.insert(lines, prefix .. h.name)
          item_line_map[i] = #lines
          table.insert(lines, "")
        end
      elseif active_subtab == 2 then
        for i, sh in ipairs(FontEngine.terminal_shells) do
          local prefix = (i == sel_idx[3][2]) and "  > " or "    "
          table.insert(lines, prefix .. sh.name)
          item_line_map[i] = #lines
          table.insert(lines, "")
        end
      elseif active_subtab == 3 then
        for i, sp in ipairs(FontEngine.terminal_line_spacings) do
          local prefix = (i == sel_idx[3][3]) and "  > " or "    "
          table.insert(lines, prefix .. sp.name)
          item_line_map[i] = #lines
          table.insert(lines, "")
        end
      end
    end

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    local ns_id = vim.api.nvim_create_namespace("font_picker_hl")
    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

    for _, tp in ipairs(target_spans) do
      local hl_grp = (tp.id == active_target) and "FontTargetActive" or "FontTargetInactive"
      pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, hl_grp, target_row_idx - 1, tp.s, tp.e)
    end

    for _, st in ipairs(subtab_spans) do
      local hl_grp = (st.id == active_subtab) and "FontSubtabActive" or "FontSubtabInactive"
      pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, hl_grp, subtab_row_idx - 1, st.s, st.e)
    end

    pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "FontDivider", divider_row_idx - 1, 0, -1)

    if search_row_idx then
      pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "FontSearchPrompt", search_row_idx - 1, 0, 16)
      if sb and sb.get_text() == "" then
        pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "FontSearchPlaceholder", search_row_idx - 1, 16, -1)
      end
    end

    local cur_sel = sel_idx[active_target][active_subtab] or 1
    local target_row = item_line_map[cur_sel]
    if target_row and vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_set_cursor, win, { target_row, 2 })
      pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "FontItemArrow", target_row - 1, 0, 4)
      pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "FontItemActive", target_row - 1, 4, -1)
    end

    -- Strictly reset horizontal view to leftcol = 0
    if vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_call, win, function()
        vim.fn.winrestview({ leftcol = 0 })
      end)
    end

    if update_preview ~= false then
      working_cfg.target = active_target
      FontEngine.apply_config(working_cfg)
    end
  end

  sb = make_searchbar("", function()
    if active_target == 1 and active_subtab == 1 then
      sel_idx[1][1] = 1
      render(true)
    end
  end)

  bind_searchbar_keys(buf, sb, function() return active_target == 1 and active_subtab == 1 end)

  render(false)

  local function confirm_selection()
    confirmed = true
    working_cfg.target = active_target
    FontEngine.save_config(working_cfg)
    FontEngine.apply_config(working_cfg)
    pcall(vim.api.nvim_win_close, win, true)
    local ed = find_editor_win()
    if ed and vim.api.nvim_win_is_valid(ed) then
      vim.api.nvim_set_current_win(ed)
    end
    vim.cmd("startinsert")
    _G.clear_active_menu(cancel_selection)
    vim.notify(string.format("Appearance saved: %s, %s pt, Sidebar: %s cols", working_cfg.editor.family, working_cfg.editor.size, working_cfg.sidebar.width), vim.log.levels.INFO)
  end

  local function next_target()
    active_target = (active_target % #targets) + 1
    active_subtab = 1
    render(false)
  end

  local function prev_target()
    active_target = active_target - 1
    if active_target < 1 then active_target = #targets end
    active_subtab = 1
    render(false)
  end

  local function next_subtab()
    local count = #subtabs[active_target]
    active_subtab = (active_subtab % count) + 1
    render(false)
  end

  local function prev_subtab()
    local count = #subtabs[active_target]
    active_subtab = active_subtab - 1
    if active_subtab < 1 then active_subtab = count end
    render(false)
  end

  local function move_up()
    local cur = sel_idx[active_target][active_subtab] or 1
    if active_target == 1 then
      if active_subtab == 1 then
        if #filtered_fonts == 0 then return end
        cur = cur - 1
        if cur < 1 then cur = #filtered_fonts end
        sel_idx[1][1] = cur
        working_cfg.editor.family = filtered_fonts[cur]
        working_cfg.family = working_cfg.editor.family
      elseif active_subtab == 2 then
        cur = cur - 1
        if cur < 1 then cur = #FontEngine.font_sizes end
        sel_idx[1][2] = cur
        working_cfg.editor.size = FontEngine.font_sizes[cur]
        working_cfg.size = working_cfg.editor.size
      elseif active_subtab == 3 then
        cur = cur - 1
        if cur < 1 then cur = #FontEngine.font_weights end
        sel_idx[1][3] = cur
        local w = FontEngine.font_weights[cur]
        working_cfg.editor.weight = w.id
        working_cfg.editor.bold = w.bold
        working_cfg.weight = w.id
        working_cfg.bold = w.bold
      elseif active_subtab == 4 then
        cur = cur - 1
        if cur < 1 then cur = #FontEngine.line_spacings end
        sel_idx[1][4] = cur
        working_cfg.editor.line_space = FontEngine.line_spacings[cur].val
        working_cfg.line_space = working_cfg.editor.line_space
      end
    elseif active_target == 2 then
      if active_subtab == 1 then
        cur = cur - 1
        if cur < 1 then cur = #FontEngine.scale_presets end
        sel_idx[2][1] = cur
        local sc = FontEngine.scale_presets[cur]
        working_cfg.sidebar.scale = cur
        working_cfg.sidebar.width = sc.width
        working_cfg.sidebar.icon_padding = sc.padding
        working_cfg.sidebar.indent_width = sc.indent
        for i, w in ipairs(FontEngine.sidebar_widths) do if w.val == sc.width then sel_idx[2][2] = i break end end
        for i, p in ipairs(FontEngine.icon_paddings) do if p.val == sc.padding then sel_idx[2][3] = i break end end
        for i, ind in ipairs(FontEngine.indent_widths) do if ind.val == sc.indent then sel_idx[2][4] = i break end end
      elseif active_subtab == 2 then
        cur = cur - 1
        if cur < 1 then cur = #FontEngine.sidebar_widths end
        sel_idx[2][2] = cur
        working_cfg.sidebar.width = FontEngine.sidebar_widths[cur].val
      elseif active_subtab == 3 then
        cur = cur - 1
        if cur < 1 then cur = #FontEngine.icon_paddings end
        sel_idx[2][3] = cur
        working_cfg.sidebar.icon_padding = FontEngine.icon_paddings[cur].val
      elseif active_subtab == 4 then
        cur = cur - 1
        if cur < 1 then cur = #FontEngine.indent_widths end
        sel_idx[2][4] = cur
        working_cfg.sidebar.indent_width = FontEngine.indent_widths[cur].val
      elseif active_subtab == 5 then
        cur = cur - 1
        if cur < 1 then cur = #FontEngine.chevron_styles end
        sel_idx[2][5] = cur
        working_cfg.sidebar.chevron_style = cur
      elseif active_subtab == 6 then
        cur = cur - 1
        if cur < 1 then cur = #FontEngine.git_badge_styles end
        sel_idx[2][6] = cur
        working_cfg.sidebar.git_badge = cur
      end
    elseif active_target == 3 then
      if active_subtab == 1 then
        cur = cur - 1
        if cur < 1 then cur = #FontEngine.terminal_heights end
        sel_idx[3][1] = cur
        working_cfg.terminal.height = FontEngine.terminal_heights[cur].val
      elseif active_subtab == 2 then
        cur = cur - 1
        if cur < 1 then cur = #FontEngine.terminal_shells end
        sel_idx[3][2] = cur
        working_cfg.terminal.shell = FontEngine.terminal_shells[cur].id
      elseif active_subtab == 3 then
        cur = cur - 1
        if cur < 1 then cur = #FontEngine.terminal_line_spacings end
        sel_idx[3][3] = cur
        working_cfg.terminal.line_space = FontEngine.terminal_line_spacings[cur].val
      end
    end
    render(true)
  end

  local function move_down()
    local cur = sel_idx[active_target][active_subtab] or 1
    if active_target == 1 then
      if active_subtab == 1 then
        if #filtered_fonts == 0 then return end
        cur = cur + 1
        if cur > #filtered_fonts then cur = 1 end
        sel_idx[1][1] = cur
        working_cfg.editor.family = filtered_fonts[cur]
        working_cfg.family = working_cfg.editor.family
      elseif active_subtab == 2 then
        cur = cur + 1
        if cur > #FontEngine.font_sizes then cur = 1 end
        sel_idx[1][2] = cur
        working_cfg.editor.size = FontEngine.font_sizes[cur]
        working_cfg.size = working_cfg.editor.size
      elseif active_subtab == 3 then
        cur = cur + 1
        if cur > #FontEngine.font_weights then cur = 1 end
        sel_idx[1][3] = cur
        local w = FontEngine.font_weights[cur]
        working_cfg.editor.weight = w.id
        working_cfg.editor.bold = w.bold
        working_cfg.weight = w.id
        working_cfg.bold = w.bold
      elseif active_subtab == 4 then
        cur = cur + 1
        if cur > #FontEngine.line_spacings then cur = 1 end
        sel_idx[1][4] = cur
        working_cfg.editor.line_space = FontEngine.line_spacings[cur].val
        working_cfg.line_space = working_cfg.editor.line_space
      end
    elseif active_target == 2 then
      if active_subtab == 1 then
        cur = cur + 1
        if cur > #FontEngine.scale_presets then cur = 1 end
        sel_idx[2][1] = cur
        local sc = FontEngine.scale_presets[cur]
        working_cfg.sidebar.scale = cur
        working_cfg.sidebar.width = sc.width
        working_cfg.sidebar.icon_padding = sc.padding
        working_cfg.sidebar.indent_width = sc.indent
        for i, w in ipairs(FontEngine.sidebar_widths) do if w.val == sc.width then sel_idx[2][2] = i break end end
        for i, p in ipairs(FontEngine.icon_paddings) do if p.val == sc.padding then sel_idx[2][3] = i break end end
        for i, ind in ipairs(FontEngine.indent_widths) do if ind.val == sc.indent then sel_idx[2][4] = i break end end
      elseif active_subtab == 2 then
        cur = cur + 1
        if cur > #FontEngine.sidebar_widths then cur = 1 end
        sel_idx[2][2] = cur
        working_cfg.sidebar.width = FontEngine.sidebar_widths[cur].val
      elseif active_subtab == 3 then
        cur = cur + 1
        if cur > #FontEngine.icon_paddings then cur = 1 end
        sel_idx[2][3] = cur
        working_cfg.sidebar.icon_padding = FontEngine.icon_paddings[cur].val
      elseif active_subtab == 4 then
        cur = cur + 1
        if cur > #FontEngine.indent_widths then cur = 1 end
        sel_idx[2][4] = cur
        working_cfg.sidebar.indent_width = FontEngine.indent_widths[cur].val
      elseif active_subtab == 5 then
        cur = cur + 1
        if cur > #FontEngine.chevron_styles then cur = 1 end
        sel_idx[2][5] = cur
        working_cfg.sidebar.chevron_style = cur
      elseif active_subtab == 6 then
        cur = cur + 1
        if cur > #FontEngine.git_badge_styles then cur = 1 end
        sel_idx[2][6] = cur
        working_cfg.sidebar.git_badge = cur
      end
    elseif active_target == 3 then
      if active_subtab == 1 then
        cur = cur + 1
        if cur > #FontEngine.terminal_heights then cur = 1 end
        sel_idx[3][1] = cur
        working_cfg.terminal.height = FontEngine.terminal_heights[cur].val
      elseif active_subtab == 2 then
        cur = cur + 1
        if cur > #FontEngine.terminal_shells then cur = 1 end
        sel_idx[3][2] = cur
        working_cfg.terminal.shell = FontEngine.terminal_shells[cur].id
      elseif active_subtab == 3 then
        cur = cur + 1
        if cur > #FontEngine.terminal_line_spacings then cur = 1 end
        sel_idx[3][3] = cur
        working_cfg.terminal.line_space = FontEngine.terminal_line_spacings[cur].val
      end
    end
    render(true)
  end

  local function page_up()
    if active_target == 1 and active_subtab == 1 and #filtered_fonts > 0 then
      sel_idx[1][1] = math.max(1, sel_idx[1][1] - 8)
      working_cfg.editor.family = filtered_fonts[sel_idx[1][1]]
      working_cfg.family = working_cfg.editor.family
      render(true)
    else
      move_up()
    end
  end

  local function page_down()
    if active_target == 1 and active_subtab == 1 and #filtered_fonts > 0 then
      sel_idx[1][1] = math.min(#filtered_fonts, sel_idx[1][1] + 8)
      working_cfg.editor.family = filtered_fonts[sel_idx[1][1]]
      working_cfg.family = working_cfg.editor.family
      render(true)
    else
      move_down()
    end
  end

  -- Tab navigation
  vim.keymap.set({ "n", "i", "s", "v" }, "<Tab>", next_target, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<S-Tab>", prev_target, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-1>", function() active_target = 1; active_subtab = 1; render(false) end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-2>", function() active_target = 2; active_subtab = 1; render(false) end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-3>", function() active_target = 3; active_subtab = 1; render(false) end, { buffer = buf, nowait = true })

  -- Subtab navigation via Left / Right
  vim.keymap.set({ "n", "i", "s", "v" }, "<Left>", function()
    if active_target == 1 and active_subtab == 1 and #sb.get_text() > 0 then
      sb.move_left()
    else
      prev_subtab()
    end
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Right>", function()
    if active_target == 1 and active_subtab == 1 and #sb.get_text() > 0 then
      sb.move_right()
    else
      next_subtab()
    end
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<M-Left>", prev_subtab, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-Right>", next_subtab, { buffer = buf, nowait = true })

  -- Subtab direct jump via number keys 1..6
  for num = 1, 6 do
    vim.keymap.set({ "n", "i", "s", "v" }, tostring(num), function()
      if active_target == 1 and active_subtab == 1 then
        sb.insert(tostring(num))
      else
        local count = #subtabs[active_target]
        if num <= count then
          active_subtab = num
          render(false)
        end
      end
    end, { buffer = buf, nowait = true })
  end

  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = buf,
    once = true,
    callback = cancel_selection,
  })

  vim.keymap.set({ "n", "i", "s", "v" }, "<CR>", confirm_selection, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<Esc>", cancel_selection, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-c>", cancel_selection, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "q", function()
    if active_target == 1 and active_subtab == 1 then
      sb.insert("q")
    else
      cancel_selection()
    end
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Up>", move_up, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-p>", move_up, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<Down>", move_down, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-n>", move_down, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<PageUp>", page_up, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<PageDown>", page_down, { buffer = buf, nowait = true })

  local function on_mouse_click()
    local pos = vim.fn.getmousepos()
    if pos and pos.winid == win and pos.line then
      if pos.line == target_row_idx then
        for _, tp in ipairs(target_spans) do
          if pos.column >= tp.s and pos.column <= tp.e then
            active_target = tp.id
            active_subtab = 1
            render(false)
            return
          end
        end
      elseif pos.line == subtab_row_idx then
        for _, st in ipairs(subtab_spans) do
          if pos.column >= st.s and pos.column <= st.e then
            active_subtab = st.id
            render(false)
            return
          end
        end
      else
        for i, lnum in pairs(item_line_map) do
          if pos.line == lnum or pos.line == lnum - 1 or pos.line == lnum + 1 then
            sel_idx[active_target][active_subtab] = i
            render(true)
            return
          end
        end
      end
    end
  end

  vim.keymap.set({ "n", "i", "s", "v" }, "<LeftMouse>", on_mouse_click, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<2-LeftMouse>", function()
    on_mouse_click()
    confirm_selection()
  end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<ScrollWheelLeft>", "<nop>", { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<ScrollWheelRight>", "<nop>", { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "zl", "<nop>", { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "zh", "<nop>", { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "zL", "<nop>", { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "zH", "<nop>", { buffer = buf, nowait = true })
end

-- =============================================================================
-- KEYBOARD SHORTCUTS PALETTE (Ctrl+Shift+P) WITH REAL-TIME SEARCHBAR
-- =============================================================================
_G.open_keybindings_panel = function()
  local all_shortcuts = {
    { cat = "EDITING", key = "Ctrl + Z", desc = "Undo last action" },
    { cat = "EDITING", key = "Ctrl + Y", desc = "Redo last action" },
    { cat = "EDITING", key = "Ctrl + C", desc = "Copy line or selected text" },
    { cat = "EDITING", key = "Ctrl + X", desc = "Cut line or selected text" },
    { cat = "EDITING", key = "Ctrl + V", desc = "Paste from clipboard" },
    { cat = "EDITING", key = "Ctrl + A", desc = "Select all text in document" },
    { cat = "EDITING", key = "Ctrl + /", desc = "Toggle single line comment" },
    { cat = "EDITING", key = "Shift + Alt + A", desc = "Toggle multiline block comment" },
    { cat = "EDITING", key = "Tab / Ctrl + ]", desc = "Indent line or selection (add tab space)" },
    { cat = "EDITING", key = "Shift + Tab / Ctrl + [", desc = "Unindent line or selection (remove tab space)" },
    { cat = "EDITING", key = "Ctrl + Enter", desc = "Insert line below and type" },
    { cat = "EDITING", key = "Ctrl + Shift + Enter", desc = "Insert line above and type" },
    { cat = "EDITING", key = "Alt + C / Ctrl+Shift+C", desc = "Open Color Picker (RGB/HEX/HSL sliders)" },
    { cat = "EDITING", key = "Ctrl + .", desc = "Code Spell Check & Quick Fix (Word suggestions / Dictionary)" },
    { cat = "EDITING", key = "Shift + Delete", desc = "Delete entire line (or selection)" },
    { cat = "EDITING", key = "Ctrl + Backspace", desc = "Delete word backward" },
    { cat = "EDITING", key = "Ctrl + Delete", desc = "Delete word forward" },
    { cat = "MULTI-CURSOR & LINES", key = "Alt + Down", desc = "Move line down" },
    { cat = "MULTI-CURSOR & LINES", key = "Alt + Up", desc = "Move line up" },
    { cat = "MULTI-CURSOR & LINES", key = "Shift + Alt + Down", desc = "Copy line below (Duplicate down)" },
    { cat = "MULTI-CURSOR & LINES", key = "Shift + Alt + Up", desc = "Copy line above (Duplicate up)" },
    { cat = "MULTI-CURSOR & LINES", key = "Ctrl + D", desc = "Select next occurrence (Multi-Select)" },
    { cat = "MULTI-CURSOR & LINES", key = "Ctrl + Shift + L", desc = "Select all occurrences (Multi-Edit all)" },
    { cat = "MULTI-CURSOR & LINES", key = "Ctrl + Alt + Down / Up", desc = "Add cursor below / above" },
    { cat = "MULTI-CURSOR & LINES", key = "Ctrl + Click / Alt + Click", desc = "Add or remove cursor at click" },
    { cat = "MULTI-CURSOR & LINES", key = "Shift + Alt + I", desc = "Insert cursor at end of each selected line" },
    { cat = "MULTI-CURSOR & LINES", key = "Ctrl + K Ctrl + D", desc = "Skip match and jump to next" },
    { cat = "MULTI-CURSOR & LINES", key = "Esc", desc = "Exit multi-cursor mode and keep typing" },
    { cat = "NAVIGATION & TABS", key = "Ctrl + F", desc = "Find / Search in file" },
    { cat = "NAVIGATION & TABS", key = "PgUp / PgDn", desc = "Page scroll (VS Code cursor placement)" },
    { cat = "NAVIGATION & TABS", key = "Home / End", desc = "Move to line start / end" },
    { cat = "NAVIGATION & TABS", key = "Shift + Home / End", desc = "Select to line start / end" },
    { cat = "NAVIGATION & TABS", key = "Ctrl + Home / End", desc = "Move to document start / end" },
    { cat = "NAVIGATION & TABS", key = "Alt + 1 .. 9", desc = "Jump to file tab 1 through 9" },
    { cat = "NAVIGATION & TABS", key = "Ctrl + W", desc = "Close active file tab" },
    { cat = "NAVIGATION & TABS", key = "Ctrl + Alt + H / :Home", desc = "Open Minimal Homescreen dashboard" },
    { cat = "NAVIGATION & TABS", key = "Alt + K / Alt + J", desc = "Jump relative lines up / down (Vim-style)" },
    { cat = "NAVIGATION & TABS", key = "Ctrl + G / Alt + G", desc = "Go to line / relative jump (+10 down, -5 up)" },
    { cat = "SIDEBAR & WORKSPACE", key = "Alt + Left / Right", desc = "Resize sidebar width" },
    { cat = "INTEGRATED TERMINAL", key = "Alt + Left / Right / Up / Down", desc = "Resize terminal drawer height" },
    { cat = "SIDEBAR & WORKSPACE", key = "Ctrl + B", desc = "Toggle sidebar file explorer" },
    { cat = "SIDEBAR & WORKSPACE", key = "Ctrl + Shift + E", desc = "Toggle focus: Editor <-> Sidebar" },
    { cat = "SIDEBAR & WORKSPACE", key = "Ctrl + K Ctrl + O", desc = "Open workspace folder picker" },
    { cat = "SIDEBAR & WORKSPACE", key = "/ or f", desc = "(Sidebar) Filter / Search files live" },
    { cat = "SIDEBAR & WORKSPACE", key = "d / Del", desc = "(Sidebar) Delete file/folder with confirmation" },
    { cat = "SIDEBAR & WORKSPACE", key = "r", desc = "(Sidebar) Inline rename file/folder" },
    { cat = "SIDEBAR & WORKSPACE", key = "Enter / Double Click", desc = "(Sidebar) Open file / toggle folder" },
    { cat = "THEMES, FONTS & PALETTE", key = "Ctrl + K Ctrl + T", desc = "Color Themes picker (live search & preview)" },
    { cat = "THEMES, FONTS & PALETTE", key = "Ctrl + Shift + K + T", desc = "Desktop Fonts & Options (Size, Bold, Spacing)" },
    { cat = "THEMES, FONTS & PALETTE", key = "Ctrl + Shift + P", desc = "Show this Keybindings search panel" },
    { cat = "INTEGRATED TERMINAL", key = "Ctrl + ` / Ctrl + J", desc = "Toggle bottom terminal drawer" },
    { cat = "INTEGRATED TERMINAL", key = "Alt + N + T", desc = "New terminal tab instance" },
    { cat = "INTEGRATED TERMINAL", key = "Shift + Alt + K", desc = "Kill active terminal tab" },
    { cat = "INTEGRATED TERMINAL", key = "Ctrl + PgUp / PgDn", desc = "Switch active terminal tab" },
    { cat = "MARKDOWN (.MD)", key = "Alt + M", desc = "Open Markdown heading outline & section jumper" },
    { cat = "MARKDOWN (.MD)", key = "Alt + P", desc = "Open styled Markdown preview in browser" },
    { cat = "MARKDOWN (.MD)", key = "Alt + X", desc = "Toggle checkbox [ ] <-> [x] on current line" },
    { cat = "MARKDOWN (.MD)", key = "Alt + B / Alt + I", desc = "Toggle **Bold** / *Italic* on selection or word" },
    { cat = "MARKDOWN (.MD)", key = "Alt + E / Alt + L", desc = "Wrap as `Inline Code` or [Link](url)" },
    { cat = "MARKDOWN (.MD)", key = "Alt + O / gx", desc = "Open Markdown link under cursor (file or URL)" },
    { cat = "MARKDOWN (.MD)", key = ":MdTableAlign", desc = "Align Markdown table columns" },
  }

  local filtered = {}

  local buf = vim.api.nvim_create_buf(false, true)
  vim.b[buf].is_picker = true
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].undolevels = -1

  local ui = vim.api.nvim_list_uis()[1] or { width = 120, height = 40 }
  local width = math.min(76, ui.width - 6)
  local height = math.min(24, ui.height - 4)
  local row = math.max(1, math.floor((ui.height - height) / 3))
  local col = math.max(1, math.floor((ui.width - width) / 2))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Keyboard Shortcuts ",
    title_pos = "center",
  })

  vim.cmd("stopinsert")
  vim.wo[win].cursorline = false
  vim.wo[win].wrap = false
  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

  local function close_panel()
    pcall(vim.api.nvim_win_close, win, true)
    local ed = find_editor_win()
    if ed and vim.api.nvim_win_is_valid(ed) then
      vim.api.nvim_set_current_win(ed)
    end
    vim.cmd("startinsert")
    _G.clear_active_menu(close_panel)
  end

  _G.register_active_menu(close_panel, win)

  vim.api.nvim_set_hl(0, "KeybindCatHeader", { fg = "#61afef", bold = true })
  vim.api.nvim_set_hl(0, "KeybindKey", { fg = "#e5c07b", bold = true })
  vim.api.nvim_set_hl(0, "KeybindDesc", { fg = "#abb2bf" })

  local sb
  local function render()
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local query = sb and sb.get_text() or ""
    filtered = {}
    for _, item in ipairs(all_shortcuts) do
      if query == "" or item.key:lower():find(query:lower(), 1, true) or item.desc:lower():find(query:lower(), 1, true) or item.cat:lower():find(query:lower(), 1, true) then
        table.insert(filtered, item)
      end
    end

    local search_line = sb and sb.get_display_line("  Search: ", "(type to filter shortcuts...)") or "  Search: ▏ (type to filter shortcuts...)"
    local lines = {
      search_line,
      "  ─────────────────────────────────────────────────────────────",
    }

    local cat_lines = {}
    local item_key_spans = {}

    if #filtered == 0 then
      table.insert(lines, "   No shortcuts found matching '" .. query .. "'")
    else
      local last_cat = nil
      for _, item in ipairs(filtered) do
        if item.cat ~= last_cat then
          if last_cat ~= nil then
            table.insert(lines, "") -- breathing room above new heading
          end
          local head_text = "  ── " .. item.cat .. " " .. string.rep("─", math.max(4, 52 - #item.cat))
          table.insert(lines, head_text)
          table.insert(cat_lines, #lines)
          last_cat = item.cat
        end
        local pad = string.rep(" ", math.max(2, 28 - #item.key))
        local row_text = "    " .. item.key .. pad .. item.desc
        table.insert(lines, row_text)
        table.insert(item_key_spans, { line = #lines, s = 4, e = 4 + #item.key })
      end
    end

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    local ns_id = vim.api.nvim_create_namespace("keybinds_panel_hl")
    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
    for _, l_idx in ipairs(cat_lines) do
      pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "KeybindCatHeader", l_idx - 1, 0, -1)
    end
    for _, sp in ipairs(item_key_spans) do
      pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "KeybindKey", sp.line - 1, sp.s, sp.e)
    end
  end

  sb = make_searchbar("", function()
    render()
  end)

  bind_searchbar_keys(buf, sb)

  render()

  local function move_up()
    if not vim.api.nvim_win_is_valid(win) then return end
    local cur = vim.api.nvim_win_get_cursor(win)
    local target = math.max(1, cur[1] - 1)
    vim.api.nvim_win_set_cursor(win, { target, 1 })
  end

  local function move_down()
    if not vim.api.nvim_win_is_valid(win) then return end
    local cur = vim.api.nvim_win_get_cursor(win)
    local total = vim.api.nvim_buf_line_count(buf)
    local target = math.min(total, cur[1] + 1)
    vim.api.nvim_win_set_cursor(win, { target, 1 })
  end

  local function page_up()
    if not vim.api.nvim_win_is_valid(win) then return end
    local cur = vim.api.nvim_win_get_cursor(win)
    local target = math.max(1, cur[1] - 8)
    vim.api.nvim_win_set_cursor(win, { target, 1 })
  end

  local function page_down()
    if not vim.api.nvim_win_is_valid(win) then return end
    local cur = vim.api.nvim_win_get_cursor(win)
    local total = vim.api.nvim_buf_line_count(buf)
    local target = math.min(total, cur[1] + 8)
    vim.api.nvim_win_set_cursor(win, { target, 1 })
  end

  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = buf,
    once = true,
    callback = close_panel,
  })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Esc>", close_panel, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-c>", close_panel, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<CR>", close_panel, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Up>", move_up, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-p>", move_up, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<Down>", move_down, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-n>", move_down, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<PageUp>", page_up, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<PageDown>", page_down, { buffer = buf, nowait = true })
end

-- =============================================================================
-- WORKSPACE FOLDER OPENER & INTERACTIVE FOLDER PICKER (Ctrl+K Ctrl+O / Ctrl+K o)
-- =============================================================================
_G.open_workspace_folder = function(target_dir)
  if not target_dir or target_dir == "" then return end
  target_dir = vim.fn.fnamemodify(target_dir, ":p"):gsub("/+$", "")
  if vim.fn.isdirectory(target_dir) ~= 1 then
    vim.notify("Not a valid directory: " .. target_dir, vim.log.levels.WARN)
    return
  end

  -- Autosave all modified buffers before switching folder
  _G.autosave_all_modified()
  vim.g.explicit_workspace_opened = true

  -- Change Neovim working directory
  pcall(vim.cmd.cd, target_dir)

  -- Gather old editor buffers to clean up
  local old_bufs = get_listed_editor_bufs()

  -- Find project entry file or first regular file in new workspace
  local candidates = {
    "index.html",
    "main.py",
    "app.py",
    "index.js",
    "index.ts",
    "App.tsx",
    "App.jsx",
    "src/index.html",
    "src/main.py",
    "src/app.py",
    "src/App.tsx",
    "src/App.jsx",
    "src/index.js",
    "src/index.ts",
    "package.json",
    "README.md",
    "Cargo.toml",
    "go.mod",
    "Makefile",
  }

  local file_to_open = nil
  for _, cand in ipairs(candidates) do
    local full = target_dir .. "/" .. cand
    if vim.fn.filereadable(full) == 1 then
      file_to_open = full
      break
    end
  end

  if not file_to_open then
    local ok_scan, handle = pcall(vim.uv.fs_scandir, target_dir)
    if ok_scan and handle then
      local first_files = {}
      while true do
        local name, t = vim.uv.fs_scandir_next(handle)
        if not name then break end
        if t == "file" and not name:match("^%.") then
          table.insert(first_files, name)
        end
      end
      table.sort(first_files)
      if #first_files > 0 then
        file_to_open = target_dir .. "/" .. first_files[1]
      end
    end
  end

  local ed = find_editor_win()
  if not ed or not vim.api.nvim_win_is_valid(ed) then
    vim.cmd("aboveleft split")
    ed = vim.api.nvim_get_current_win()
  else
    vim.api.nvim_set_current_win(ed)
  end

  if file_to_open then
    vim.cmd("silent! edit " .. vim.fn.fnameescape(file_to_open))
  else
    vim.cmd("enew")
  end

  local new_buf = vim.api.nvim_get_current_buf()

  -- Close old editor buffers
  for _, b in ipairs(old_bufs) do
    if vim.api.nvim_buf_is_valid(b) and b ~= new_buf then
      pcall(vim.cmd, "silent! bdelete! " .. b)
    end
  end

  -- Update nvim-tree explorer root
  local ok_t, t_api = pcall(require, "nvim-tree.api")
  if ok_t then
    pcall(t_api.tree.change_root, target_dir)
    pcall(t_api.tree.open, { focus = false })
    pcall(t_api.tree.reload)
  end

  -- Focus editor window and resume insert mode (VS Code modeless workflow)
  ed = find_editor_win()
  if ed and vim.api.nvim_win_is_valid(ed) then
    vim.api.nvim_set_current_win(ed)
  end
  vim.cmd("startinsert")

  -- Persist session immediately
  pcall(save_session)
  vim.notify("Workspace folder: " .. vim.fn.fnamemodify(target_dir, ":~"), vim.log.levels.INFO)
end

_G.open_folder_picker = function()
  local current_dir = vim.fn.getcwd()
  if vim.fn.isdirectory(current_dir) ~= 1 then
    current_dir = vim.fn.expand("~")
  end
  local show_hidden = false
  local search_active = false
  local selected_idx = 1

  local buf = vim.api.nvim_create_buf(false, true)
  vim.b[buf].is_picker = true
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].undolevels = -1

  local ui = vim.api.nvim_list_uis()[1] or { width = 120, height = 40 }
  local width = math.min(76, math.max(52, ui.width - 6))
  local height = math.min(20, math.max(10, ui.height - 8))
  local row = math.max(1, math.floor((ui.height - height) / 3))
  local col = math.max(1, math.floor((ui.width - width) / 2))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Open Folder ",
    title_pos = "center",
    footer = " o: Open │ .: Hidden ",
    footer_pos = "center",
  })

  vim.cmd("stopinsert")
  vim.wo[win].cursorline = false
  vim.wo[win].wrap = false
  vim.wo[win].scrolloff = 2
  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

  local function close_picker()
    pcall(vim.api.nvim_win_close, win, true)
    local ed = find_editor_win()
    if ed and vim.api.nvim_win_is_valid(ed) then
      vim.api.nvim_set_current_win(ed)
      local eb = vim.api.nvim_win_get_buf(ed)
      if vim.bo[eb].filetype ~= "minimal_home" and not vim.b[eb].is_homescreen then
        vim.cmd("startinsert")
      end
    end
    _G.clear_active_menu(close_picker)
  end

  _G.register_active_menu(close_picker, win)
  _G.set_picker_cursor("FolderCursorHidden")

  vim.api.nvim_set_hl(0, "FolderPickerSelected", { fg = "#ffffff", bg = "#2d3545", bold = true })
  vim.api.nvim_set_hl(0, "FolderPickerAction", { fg = "#61afef", bold = true })
  vim.api.nvim_set_hl(0, "FolderPickerDir", { fg = "#e5c07b" })
  vim.api.nvim_set_hl(0, "FolderPickerMuted", { fg = "#5c6370", italic = true })
  vim.api.nvim_set_hl(0, "FolderPickerSearch", { fg = "#61afef", bold = true })
  vim.api.nvim_set_hl(0, "FolderPickerSep", { fg = "#3b4252" })

  local items = {}
  local ns_id = vim.api.nvim_create_namespace("folder_picker_hl")
  local tree_cache = {}
  local skip_dirs = {
    [".git"] = true,
    ["node_modules"] = true,
    ["__pycache__"] = true,
    [".venv"] = true,
    [".cache"] = true,
    [".cargo"] = true,
    [".rustup"] = true,
    [".npm"] = true,
    [".mozilla"] = true,
    ["Trash"] = true,
  }

  local function scan_immediate()
    local dirs = {}
    local ok_scan, handle = pcall(vim.uv.fs_scandir, current_dir)
    if ok_scan and handle then
      while true do
        local name, t = vim.uv.fs_scandir_next(handle)
        if not name then break end
        if show_hidden or not name:match("^%.") then
          local is_d = (t == "directory")
          if t == "link" then
            local full = (current_dir == "/" and "/" .. name or current_dir .. "/" .. name)
            is_d = (vim.fn.isdirectory(full) == 1)
          end
          if is_d then
            table.insert(dirs, name)
          end
        end
      end
    end
    table.sort(dirs, function(a, b) return a:lower() < b:lower() end)
    return dirs
  end

  local function get_recursive_dirs()
    local cache_key = current_dir .. "|" .. tostring(show_hidden)
    if tree_cache[cache_key] then
      return tree_cache[cache_key]
    end

    local results = {}
    local queue = { { path = current_dir, rel = "", depth = 0 } }
    local visited = 0
    local max_visits = 1500
    local max_depth = 3

    local q_head = 1
    while q_head <= #queue and visited < max_visits do
      local cur = queue[q_head]
      q_head = q_head + 1
      if cur.depth < max_depth then
        local ok_scan, handle = pcall(vim.uv.fs_scandir, cur.path)
        if ok_scan and handle then
          while visited < max_visits do
            local name, t = vim.uv.fs_scandir_next(handle)
            if not name then break end
            if not skip_dirs[name] and (show_hidden or not name:match("^%.")) then
              local full = (cur.path == "/" and "/" .. name or cur.path .. "/" .. name)
              local is_d = (t == "directory")
              if t == "link" then
                is_d = (vim.fn.isdirectory(full) == 1)
              end
              if is_d then
                visited = visited + 1
                local rel_path = (cur.rel == "" and name or (cur.rel .. "/" .. name))
                table.insert(results, {
                  name = name,
                  rel = rel_path,
                  path = full,
                  depth = cur.depth + 1,
                })
                if cur.depth + 1 < max_depth then
                  table.insert(queue, { path = full, rel = rel_path, depth = cur.depth + 1 })
                end
              end
            end
          end
        end
      end
    end

    tree_cache[cache_key] = results
    return results
  end

  local sb = nil

  local function update_selection()
    if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then return end
    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

    pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "FolderPickerSearch", 0, 0, 10)
    if not search_active then
      pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "FolderPickerMuted", 0, 10, -1)
    end
    pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "FolderPickerSep", 1, 0, -1)

    for _, item in ipairs(items) do
      local r = item.line - 1
      if item.type == "open_current" then
        pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "FolderPickerAction", r, 0, -1)
      elseif item.type == "dir" then
        pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "FolderPickerDir", r, 0, 7)
      elseif item.type == "parent" then
        pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "FolderPickerMuted", r, 0, -1)
      end
    end

    if #items > 0 then
      if selected_idx > #items then selected_idx = #items end
      if selected_idx < 1 then selected_idx = 1 end
      local sel = items[selected_idx]
      if sel then
        pcall(vim.api.nvim_buf_set_extmark, buf, ns_id, sel.line - 1, 0, {
          line_hl_group = "FolderPickerSelected",
          priority = 200,
        })
        pcall(vim.api.nvim_win_set_cursor, win, { sel.line, 0 })
      end
    else
      pcall(vim.api.nvim_win_set_cursor, win, { 1, 0 })
    end
  end

  local function render(target_idx)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    items = {}
    local query = (search_active and sb) and vim.trim(sb.get_text()) or ""
    local search_line
    if search_active and sb then
      search_line = sb.get_display_line("  Search: ", "(type to filter folders...)")
    else
      search_line = "  Search: (press / to search folders...)"
    end
    local sep_line = "  " .. string.rep("─", math.max(10, width - 4))
    local lines = {
      search_line,
      sep_line,
      "",
    }

    local display_cwd = vim.fn.fnamemodify(current_dir, ":~")

    if query == "" then
      table.insert(lines, "   󰉋  [Open This Folder: " .. display_cwd .. "]")
      table.insert(items, { type = "open_current", path = current_dir, line = #lines })

      if current_dir ~= "/" then
        local parent_dir = vim.fn.fnamemodify(current_dir, ":h")
        table.insert(lines, "   󰁝  .. (Parent Directory)")
        table.insert(items, { type = "parent", path = parent_dir, line = #lines })
      end

      table.insert(lines, "")

      local subdirs = scan_immediate()
      for _, dname in ipairs(subdirs) do
        local full = (current_dir == "/" and "/" .. dname or current_dir .. "/" .. dname)
        table.insert(lines, "   󰉋  " .. dname .. "/")
        table.insert(items, { type = "dir", path = full, name = dname, line = #lines })
      end

      if #subdirs == 0 then
        table.insert(lines, "   (No subdirectories)")
      end
      table.insert(lines, "")
    else
      local q_low = query:lower()
      local matches = {}
      local all_dirs = get_recursive_dirs()
      for _, d in ipairs(all_dirs) do
        local n_low = d.name:lower()
        local r_low = d.rel:lower()
        local score = nil
        if n_low == q_low then
          score = 1
        elseif n_low:sub(1, #q_low) == q_low then
          score = 2
        elseif n_low:find(q_low, 1, true) then
          score = 3
        elseif r_low:find(q_low, 1, true) then
          score = 4
        end
        if score then
          table.insert(matches, {
            name = d.name,
            rel = d.rel,
            path = d.path,
            depth = d.depth,
            score = score,
          })
        end
      end

      table.sort(matches, function(a, b)
        if a.score ~= b.score then return a.score < b.score end
        if a.depth ~= b.depth then return a.depth < b.depth end
        return a.rel:lower() < b.rel:lower()
      end)

      local max_show = 40
      for i, m in ipairs(matches) do
        if i > max_show then break end
        table.insert(lines, "   󰉋  " .. m.rel .. "/")
        table.insert(items, { type = "dir", path = m.path, name = m.name, rel = m.rel, line = #lines })
      end

      if #matches == 0 then
        table.insert(lines, '   No matching folders found for "' .. query .. '"')
      end
      table.insert(lines, "")
    end

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    local title_str = string.format(" Open Folder: %s %s", display_cwd, show_hidden and "[+hidden]" or "")
    pcall(vim.api.nvim_win_set_config, win, {
      title = title_str,
      title_pos = "center",
      footer = " o: Open │ .: Hidden ",
      footer_pos = "center",
    })

    selected_idx = target_idx or 1
    update_selection()
  end

  local function enter_search()
    search_active = true
    if sb then
      sb.text = ""
      sb.pos = 1
    end
    render(1)
  end

  local function exit_search()
    search_active = false
    if sb then
      sb.text = ""
      sb.pos = 1
    end
    render(1)
  end

  local function on_confirm()
    local item = items[selected_idx]
    if not item then return end

    if item.type == "open_current" then
      local target = item.path
      close_picker()
      _G.open_workspace_folder(target)
    elseif item.type == "parent" then
      current_dir = item.path
      search_active = false
      if sb then sb.text = ""; sb.pos = 1 end
      render(1)
    elseif item.type == "dir" then
      if search_active then
        -- When searching folders, Enter opens directly inside the matched folder
        local target = item.path
        close_picker()
        _G.open_workspace_folder(target)
      else
        current_dir = item.path
        render(1)
      end
    end
  end

  local function on_open_immediate()
    local item = items[selected_idx]
    local target = current_dir
    if item and item.path then
      target = item.path
    end
    close_picker()
    _G.open_workspace_folder(target)
  end

  local function on_browse_inside()
    local item = items[selected_idx]
    if not item then return end
    if item.type == "dir" or item.type == "parent" then
      current_dir = item.path
      search_active = false
      if sb then sb.text = ""; sb.pos = 1 end
      render(1)
    elseif item.type == "open_current" then
      local target = item.path
      close_picker()
      _G.open_workspace_folder(target)
    end
  end

  local function on_go_parent()
    if current_dir ~= "/" then
      current_dir = vim.fn.fnamemodify(current_dir, ":h")
      search_active = false
      if sb then sb.text = ""; sb.pos = 1 end
      render(1)
    end
  end

  local function on_toggle_hidden()
    show_hidden = not show_hidden
    render(selected_idx)
  end

  local function move_up()
    if #items == 0 then return end
    selected_idx = selected_idx - 1
    if selected_idx < 1 then selected_idx = #items end
    update_selection()
  end

  local function move_down()
    if #items == 0 then return end
    selected_idx = selected_idx + 1
    if selected_idx > #items then selected_idx = 1 end
    update_selection()
  end

  local function on_mouse_click()
    local pos = vim.fn.getmousepos()
    if pos and pos.winid == win and pos.line then
      if pos.line == 1 then
        if not search_active then enter_search() end
        return
      end
      for i, item in ipairs(items) do
        if item.line == pos.line then
          selected_idx = i
          update_selection()
          return
        end
      end
    end
  end

  sb = make_searchbar("", function()
    if search_active then
      render(1)
    end
  end)

  bind_searchbar_keys(buf, sb, function() return search_active end)

  -- Browse-mode single-key shortcuts (active when search_active == false)
  local function browse_or_type(key, action)
    vim.keymap.set({ "n", "i", "s", "v" }, key, function()
      if search_active then
        sb.insert(key)
      else
        action()
      end
    end, { buffer = buf, nowait = true })
  end

  browse_or_type("o", on_open_immediate)
  browse_or_type("O", on_open_immediate)
  browse_or_type(".", on_toggle_hidden)
  browse_or_type("k", move_up)
  browse_or_type("j", move_down)
  browse_or_type("h", on_go_parent)
  browse_or_type("l", on_browse_inside)
  browse_or_type("q", close_picker)
  browse_or_type("~", function()
    current_dir = vim.fn.expand("~")
    render(1)
  end)
  browse_or_type("/", enter_search)

  vim.keymap.set({ "n", "i", "s", "v" }, "<C-f>", enter_search, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-.>", on_toggle_hidden, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Left>", function()
    if search_active then sb.move_left() else on_go_parent() end
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Right>", function()
    if search_active then sb.move_right() else on_browse_inside() end
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<BS>", function()
    if search_active then sb.backspace() else on_go_parent() end
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Tab>", on_browse_inside, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<S-Tab>", on_go_parent, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<CR>", on_confirm, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-CR>", on_open_immediate, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<LeftMouse>", on_mouse_click, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<2-LeftMouse>", function()
    on_mouse_click()
    on_confirm()
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Esc>", function()
    if search_active then
      exit_search()
    else
      close_picker()
    end
  end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-c>", close_picker, { buffer = buf, nowait = true })

  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = buf,
    once = true,
    callback = close_picker,
  })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Up>", move_up, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-p>", move_up, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Down>", move_down, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-n>", move_down, { buffer = buf, nowait = true })

  render(1)
end

-- Apply instant base dark backdrop to prevent first-frame flicker, then full theme after paint
local active_theme_id = ThemeEngine.get_active_theme()
local theme_backdrops = {
  darkmagic = "#07070f",
  cyberaurora = "#080b14",
  medieval = "#0e0d0b",
  nocturne = "#0b0709",
}
local init_bg = theme_backdrops[active_theme_id] or "#07070f"
vim.api.nvim_set_hl(0, "Normal", { fg = "#abb2bf", bg = init_bg })
vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#abb2bf", bg = "#1e222a" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = init_bg, bg = init_bg })
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#1c1f26", bg = "NONE" })
vim.defer_fn(function()
  ThemeEngine.apply_theme(active_theme_id)
  if _G.reapply_all_icon_colors then
    _G.reapply_all_icon_colors()
  end
end, 1)

-- =============================================================================
-- MINIMAL HOMESCREEN & WELCOME DASHBOARD (named "minimal")
-- =============================================================================
_G.create_new_folder = function()
  vim.ui.input({
    prompt = "Create New Folder (name or path): ",
    default = "",
    completion = "dir",
  }, function(input)
    if input and input:match("%S") then
      local trimmed = vim.trim(input)
      local full_path = trimmed
      if not full_path:match("^/") and not full_path:match("^~") then
        full_path = vim.fn.getcwd() .. "/" .. full_path
      end
      local expanded = vim.fn.expand(full_path)
      local ok, err = pcall(vim.fn.mkdir, expanded, "p")
      if ok and vim.fn.isdirectory(expanded) == 1 then
        vim.notify("Folder created: " .. vim.fn.fnamemodify(expanded, ":~"), vim.log.levels.INFO)
        _G.open_workspace_folder(expanded)
      else
        vim.notify("Failed to create folder: " .. tostring(err or input), vim.log.levels.ERROR)
      end
    end
  end)
end

_G.Homescreen = {}
local Homescreen = _G.Homescreen
Homescreen.buf = nil
Homescreen.active_idx = 1
Homescreen.recent_files = {}
Homescreen.row_action_map = {}
Homescreen.row_recent_map = {}

local banner_lines = {
  "███╗   ███╗██╗███╗   ██╗██╗███╗   ███╗ █████╗ ██╗     ",
  "████╗ ████║██║████╗  ██║██║████╗ ████║██╔══██╗██║     ",
  "██╔████╔██║██║██╔██╗ ██║██║██╔████╔██║███████║██║     ",
  "██║╚██╔╝██║██║██║╚██╗██║██║██║╚██╔╝██║██╔══██║██║     ",
  "██║ ╚═╝ ██║██║██║ ╚████║██║██║ ╚═╝ ██║██║  ██║███████╗",
  "╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝",
}

local home_actions = {
  { key = "n", label = "New File", hint = "Ctrl+N", action = function() _G.homescreen_new_file() end },
  { key = "o", label = "Open Folder", hint = "Ctrl+K Ctrl+O", action = function() _G.open_folder_picker() end },
  { key = "f", label = "New Folder", hint = "", action = function() _G.create_new_folder() end },
  { key = "b", label = "File Explorer", hint = "Ctrl+B", action = function() _G.toggle_tree() end },
  { key = "t", label = "Color Themes", hint = "Ctrl+K Ctrl+T", action = function() _G.open_theme_picker() end },
  { key = "p", label = "Font & Settings", hint = "Ctrl+Shift+K+T", action = function() _G.open_font_picker() end },
  { key = "k", label = "Keyboard Shortcuts", hint = "Ctrl+Shift+P", action = function() _G.open_keybindings_panel() end },
  { key = "j", label = "Terminal Drawer", hint = "Ctrl+`", action = function() _G.toggle_terminal() end },
  { key = "q", label = "Quit Editor", hint = "Ctrl+Q", action = function() vim.cmd("qa") end },
}

_G.homescreen_new_file = function(initial_char)
  local ed = find_editor_win()
  if ed and vim.api.nvim_win_is_valid(ed) then
    vim.api.nvim_set_current_win(ed)
  end
  local old_hbuf = Homescreen.buf
  vim.cmd("enew")
  if old_hbuf and vim.api.nvim_buf_is_valid(old_hbuf) then
    pcall(vim.api.nvim_buf_delete, old_hbuf, { force = true })
    Homescreen.buf = nil
  end
  if initial_char and initial_char ~= "" then
    vim.api.nvim_set_current_line(initial_char)
    vim.api.nvim_win_set_cursor(0, { 1, #initial_char })
  end
  vim.cmd("startinsert")
end

function Homescreen.get_recent_files()
  local recent = {}
  local seen = {}
  for _, f in ipairs(vim.v.oldfiles or {}) do
    if #recent >= 5 then break end
    if f and f ~= "" and vim.fn.filereadable(f) == 1 and not seen[f] then
      if not f:match("COMMIT_EDITMSG") and not f:match("^/tmp") and not f:match("%.git/") then
        seen[f] = true
        table.insert(recent, f)
      end
    end
  end
  return recent
end

function Homescreen.activate_selection()
  if Homescreen.active_idx <= #home_actions then
    local a = home_actions[Homescreen.active_idx]
    if a and a.action then a.action() end
  else
    local rf_idx = Homescreen.active_idx - #home_actions
    local rf = Homescreen.recent_files and Homescreen.recent_files[rf_idx]
    if rf and vim.fn.filereadable(rf) == 1 then
      local old_hbuf = Homescreen.buf
      vim.cmd("silent! edit " .. vim.fn.fnameescape(rf))
      if old_hbuf and vim.api.nvim_buf_is_valid(old_hbuf) then
        pcall(vim.api.nvim_buf_delete, old_hbuf, { force = true })
        Homescreen.buf = nil
      end
      vim.cmd("startinsert")
    end
  end
end

function Homescreen.on_click()
  local mouse = vim.fn.getmousepos()
  if mouse and mouse.line then
    local act = Homescreen.row_action_map and Homescreen.row_action_map[mouse.line]
    if act and act.action then
      act.action()
      return
    end
    local rf = Homescreen.row_recent_map and Homescreen.row_recent_map[mouse.line]
    if rf and vim.fn.filereadable(rf) == 1 then
      local old_hbuf = Homescreen.buf
      vim.cmd("silent! edit " .. vim.fn.fnameescape(rf))
      if old_hbuf and vim.api.nvim_buf_is_valid(old_hbuf) then
        pcall(vim.api.nvim_buf_delete, old_hbuf, { force = true })
        Homescreen.buf = nil
      end
      vim.cmd("startinsert")
      return
    end
  end
end

function Homescreen.render()
  local ed = find_editor_win()
  if not ed or not vim.api.nvim_win_is_valid(ed) then return end
  if not Homescreen.buf or not vim.api.nvim_buf_is_valid(Homescreen.buf) then return end

  local win_w = vim.api.nvim_win_get_width(ed)
  local win_h = vim.api.nvim_win_get_height(ed)

  local recent = Homescreen.get_recent_files()
  Homescreen.recent_files = recent

  local content_lines = {}
  local hl_spans = {}
  local action_row_map = {}
  local recent_row_map = {}

  -- Banner
  local banner_width = 54
  local banner_pad = math.max(1, math.floor((win_w - banner_width) / 2))
  local b_pad_str = string.rep(" ", banner_pad)

  for _, bl in ipairs(banner_lines) do
    table.insert(content_lines, b_pad_str .. bl)
    table.insert(hl_spans, { #content_lines, banner_pad, -1, "MinimalHomeBanner" })
  end

  -- Tagline at the right bottom of the app name
  local tagline = "crafted by indiedev"
  local tagline_pad = math.max(1, banner_pad + banner_width - #tagline)
  local tagline_str = string.rep(" ", tagline_pad) .. tagline
  table.insert(content_lines, tagline_str)
  table.insert(hl_spans, { #content_lines, tagline_pad, -1, "MinimalHomeTagline" })
  table.insert(content_lines, "")

  -- Actions block
  local box_width = 48
  local box_pad = math.max(2, math.floor((win_w - box_width) / 2))
  local box_pad_str = string.rep(" ", box_pad)

  for i, a in ipairs(home_actions) do
    local is_sel = (Homescreen.active_idx == i)
    local pointer = is_sel and " > " or "   "
    local key_part = "[" .. a.key .. "] "
    local label_part = a.label
    local hint_part = a.hint ~= "" and a.hint or ""
    local pad_spaces = math.max(2, box_width - #pointer - #key_part - #label_part - #hint_part)
    local row_str = box_pad_str .. pointer .. key_part .. label_part .. string.rep(" ", pad_spaces) .. hint_part

    table.insert(content_lines, row_str)
    local l_idx = #content_lines
    action_row_map[l_idx] = a

    local cur_col = box_pad
    if is_sel then
      table.insert(hl_spans, { l_idx, cur_col, cur_col + 3, "MinimalHomeArrow" })
    end
    cur_col = cur_col + 3
    table.insert(hl_spans, { l_idx, cur_col, cur_col + #key_part, "MinimalHomeKey" })
    cur_col = cur_col + #key_part
    table.insert(hl_spans, { l_idx, cur_col, cur_col + #label_part, "MinimalHomeDesc" })
    if hint_part ~= "" then
      local hint_start = #row_str - #hint_part
      table.insert(hl_spans, { l_idx, hint_start, #row_str, "MinimalHomeHint" })
    end
  end

  -- Recent Files block
  if #recent > 0 then
    table.insert(content_lines, "")
    local header_text = box_pad_str .. "  Recent Files:"
    table.insert(content_lines, header_text)
    table.insert(hl_spans, { #content_lines, box_pad + 2, #header_text, "MinimalHomeHeader" })

    for idx, fpath in ipairs(recent) do
      local item_idx = #home_actions + idx
      local is_sel = (Homescreen.active_idx == item_idx)
      local pointer = is_sel and " > " or "   "
      local num_str = "[" .. idx .. "] "
      local fname = vim.fn.fnamemodify(fpath, ":t")
      local fdir = vim.fn.fnamemodify(fpath, ":~:.:h")
      if fdir == "." then fdir = "" else fdir = " (" .. fdir .. ")" end
      local display_name = fname .. fdir
      if #display_name > 36 then
        display_name = display_name:sub(1, 33) .. "..."
      end
      local row_str = box_pad_str .. pointer .. num_str .. display_name

      table.insert(content_lines, row_str)
      local l_idx = #content_lines
      recent_row_map[l_idx] = fpath

      local cur_col = box_pad
      if is_sel then
        table.insert(hl_spans, { l_idx, cur_col, cur_col + 3, "MinimalHomeArrow" })
      end
      cur_col = cur_col + 3
      table.insert(hl_spans, { l_idx, cur_col, cur_col + #num_str, "MinimalHomeKey" })
      cur_col = cur_col + #num_str
      table.insert(hl_spans, { l_idx, cur_col, #row_str, "MinimalHomeRecent" })
    end
  end

  -- Vertical centering
  local total_lines = #content_lines
  local top_padding = math.max(1, math.floor((win_h - total_lines) / 2))
  local final_lines = {}
  for _ = 1, top_padding do
    table.insert(final_lines, "")
  end
  for _, l in ipairs(content_lines) do
    table.insert(final_lines, l)
  end

  Homescreen.row_action_map = {}
  Homescreen.row_recent_map = {}
  for r, act in pairs(action_row_map) do
    Homescreen.row_action_map[r + top_padding] = act
  end
  for r, rf in pairs(recent_row_map) do
    Homescreen.row_recent_map[r + top_padding] = rf
  end

  vim.bo[Homescreen.buf].modifiable = true
  vim.api.nvim_buf_set_lines(Homescreen.buf, 0, -1, false, final_lines)
  vim.bo[Homescreen.buf].modifiable = false

  local ns_id = vim.api.nvim_create_namespace("minimal_homescreen_hl")
  vim.api.nvim_buf_clear_namespace(Homescreen.buf, ns_id, 0, -1)

  for _, sp in ipairs(hl_spans) do
    local line_idx = sp[1] + top_padding - 1
    pcall(vim.api.nvim_buf_add_highlight, Homescreen.buf, ns_id, sp[4], line_idx, sp[2], sp[3])
  end
end

function Homescreen.setup_keymaps(buf)
  local function move_up()
    local total_items = #home_actions + #(Homescreen.recent_files or {})
    Homescreen.active_idx = Homescreen.active_idx - 1
    if Homescreen.active_idx < 1 then Homescreen.active_idx = total_items end
    Homescreen.render()
  end

  local function move_down()
    local total_items = #home_actions + #(Homescreen.recent_files or {})
    Homescreen.active_idx = Homescreen.active_idx + 1
    if Homescreen.active_idx > total_items then Homescreen.active_idx = 1 end
    Homescreen.render()
  end

  vim.keymap.set({ "n", "i", "s", "v" }, "<Up>", move_up, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-p>", move_up, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Down>", move_down, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-n>", move_down, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<CR>", function()
    Homescreen.activate_selection()
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<LeftMouse>", function()
    Homescreen.on_click()
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<2-LeftMouse>", function()
    Homescreen.on_click()
  end, { buffer = buf, nowait = true })

  -- Action hotkeys
  vim.keymap.set({ "n", "i", "s", "v" }, "n", function() _G.homescreen_new_file() end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "o", function() _G.open_folder_picker() end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "f", function() _G.create_new_folder() end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "b", function() _G.toggle_tree() end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "t", function() _G.open_theme_picker() end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "p", function() _G.open_font_picker() end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "k", function() _G.open_keybindings_panel() end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "j", function() _G.toggle_terminal() end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "q", function() vim.cmd("qa") end, { buffer = buf, nowait = true })

  for i = 1, 5 do
    vim.keymap.set({ "n", "i", "s", "v" }, tostring(i), function()
      local rf = Homescreen.recent_files and Homescreen.recent_files[i]
      if rf and vim.fn.filereadable(rf) == 1 then
        local old_hbuf = Homescreen.buf
        vim.cmd("silent! edit " .. vim.fn.fnameescape(rf))
        if old_hbuf and vim.api.nvim_buf_is_valid(old_hbuf) then
          pcall(vim.api.nvim_buf_delete, old_hbuf, { force = true })
          Homescreen.buf = nil
        end
        vim.cmd("startinsert")
      end
    end, { buffer = buf, nowait = true })
  end

  -- Fallback: any other printable key starts editing in a new file
  for c = 32, 126 do
    local ch = string.char(c)
    if not ch:match("[nobtfpkjq12345]") then
      vim.keymap.set({ "n", "i", "s", "v" }, ch, function()
        _G.homescreen_new_file(ch)
      end, { buffer = buf, nowait = true })
    end
  end
end

_G.open_homescreen = function()
  local ed = find_editor_win()
  if not ed or not vim.api.nvim_win_is_valid(ed) then
    vim.cmd("aboveleft split")
    ed = vim.api.nvim_get_current_win()
  else
    vim.api.nvim_set_current_win(ed)
  end

  if not Homescreen.buf or not vim.api.nvim_buf_is_valid(Homescreen.buf) then
    Homescreen.buf = vim.api.nvim_create_buf(false, true)
    vim.b[Homescreen.buf].is_homescreen = true
    vim.bo[Homescreen.buf].filetype = "minimal_home"
    vim.bo[Homescreen.buf].buftype = "nofile"
    vim.bo[Homescreen.buf].bufhidden = "wipe"
    vim.bo[Homescreen.buf].swapfile = false
    vim.bo[Homescreen.buf].undolevels = -1
    vim.bo[Homescreen.buf].buflisted = false
    pcall(vim.api.nvim_buf_set_name, Homescreen.buf, "minimal")
    Homescreen.setup_keymaps(Homescreen.buf)
  else
    vim.b[Homescreen.buf].is_homescreen = true
    vim.bo[Homescreen.buf].filetype = "minimal_home"
    vim.bo[Homescreen.buf].buftype = "nofile"
    vim.bo[Homescreen.buf].buflisted = false
  end

  vim.api.nvim_win_set_buf(ed, Homescreen.buf)

  -- Clean up any empty unnamed scratch/orphan buffers left over
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) and b ~= Homescreen.buf then
      local bname = vim.api.nvim_buf_get_name(b)
      local bft = vim.bo[b].filetype
      local bbt = vim.bo[b].buftype
      if bname == "" and (bbt == "" or bbt == "nofile") and (bft == "" or bft == "minimal_home") then
        local line_count = vim.api.nvim_buf_line_count(b)
        if line_count <= 1 then
          local lines = vim.api.nvim_buf_get_lines(b, 0, 1, false)
          if not lines[1] or lines[1] == "" then
            vim.bo[b].buflisted = false
            pcall(vim.api.nvim_buf_delete, b, { force = true })
          end
        end
      end
    end
  end

  vim.wo[ed].number = false
  vim.wo[ed].relativenumber = false
  vim.wo[ed].cursorline = false
  vim.wo[ed].signcolumn = "no"
  vim.wo[ed].wrap = false
  vim.wo[ed].spell = false

  vim.cmd("stopinsert")
  Homescreen.render()
end

vim.api.nvim_create_user_command("Minimal", function() _G.open_homescreen() end, {})
vim.api.nvim_create_user_command("Home", function() _G.open_homescreen() end, {})
vim.keymap.set({ "n", "i", "v", "s" }, "<C-M-h>", function() _G.open_homescreen() end, { desc = "Go to Minimal Homescreen" })

vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    if Homescreen.buf and vim.api.nvim_buf_is_valid(Homescreen.buf) then
      local cur_buf = vim.api.nvim_get_current_buf()
      if cur_buf == Homescreen.buf then
        Homescreen.render()
      end
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(args)
    local buf = args.buf
    if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
    local ft = vim.bo[buf].filetype
    local bt = vim.bo[buf].buftype
    if ft ~= "minimal_home" and ft ~= "NvimTree" and bt ~= "terminal" and not vim.b[buf].is_picker then
      local win = vim.api.nvim_get_current_win()
      if win and vim.api.nvim_win_is_valid(win) then
        vim.wo[win].number = true
        vim.wo[win].relativenumber = true
        vim.wo[win].cursorline = true
        vim.wo[win].signcolumn = "yes:2"
        vim.wo[win].wrap = true
      end
    end
  end,
})

-- =============================================================================
-- MULTI-CURSOR & MULTI-EDIT ENGINE (VS Code-style Multi-Select & Multiedit)
-- =============================================================================
local mc_configured = false
local function ensure_multicursor()
  if mc_configured then return end
  mc_configured = true
  packadd_safe("multiple-cursors.nvim")
  local ok_mc, mc = pcall(require, "multiple-cursors")
  if ok_mc then
    mc.setup({
      pre_hook = function()
        vim.g.minimal_mc_active = true
        vim.opt.selection = "inclusive"
      end,
      post_hook = function()
        vim.g.minimal_mc_active = false
        vim.opt.selection = "exclusive"
      end,
      custom_key_maps = {
        { { "i", "n", "x", "s" }, "<Esc>", nil },
        {
          { "i", "n", "x" },
          "<LeftMouse>",
          function()
            _G.handle_escape()
            local mp = vim.fn.getmousepos()
            if mp and mp.winid > 0 and vim.api.nvim_win_is_valid(mp.winid) and mp.line > 0 then
              pcall(vim.api.nvim_set_current_win, mp.winid)
              local col = math.max(0, (mp.column or 1) - 1)
              pcall(vim.api.nvim_win_set_cursor, mp.winid, { mp.line, col })
            end
          end,
          "nowrap",
        },
        { { "x", "s" }, "<BS>", function() require("multiple-cursors.visual_mode.delete_yank_change_put").c() end, "nowrap" },
        { { "x", "s" }, "<Del>", function() require("multiple-cursors.visual_mode.delete_yank_change_put").c() end, "nowrap" },
        { "i", { "<C-BS>", "<C-BackSpace>" }, function() delete_word_backward() end },
        { "i", { "<C-Del>", "<C-Delete>" }, function() delete_word_forward() end },
      },
    })
  end
end
vim.defer_fn(ensure_multicursor, 45)

vim.api.nvim_create_autocmd("BufLeave", {
  callback = function(args)
    if vim.g.minimal_mc_active then
      local ok_m, mc_mod = pcall(require, "multiple-cursors")
      if ok_m and mc_mod.deinit then
        pcall(mc_mod.deinit, true)
      end
      local ns = vim.api.nvim_get_namespaces()["multiple-cursors"]
      if ns and vim.api.nvim_buf_is_valid(args.buf) then
        pcall(vim.api.nvim_buf_clear_namespace, args.buf, ns, 0, -1)
      end
      vim.g.minimal_mc_active = false
      vim.opt.selection = "exclusive"
    end
  end,
})

_G.multicursor_add_next = function()
  ensure_multicursor()
  local ok, mcp = pcall(require, "multiple-cursors")
  if not ok then return end
  local m = vim.fn.mode()
  if m == "s" or m == "S" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>", true, false, true), "nx", false)
  elseif m == "i" then
    vim.cmd("stopinsert")
    local ok_vc, vc = pcall(require, "multiple-cursors.virtual_cursors")
    if not ok_vc or vc.get_num_virtual_cursors() == 0 then
      local cword = vim.fn.expand("<cword>")
      if cword ~= "" then
        vim.g.minimal_mc_active = true
        vim.opt.selection = "inclusive"
        vim.cmd("normal! viw")
        return
      end
    end
  end
  pcall(mcp.add_cursor_and_jump_to_next_match)
end

_G.multicursor_select_all = function()
  ensure_multicursor()
  local ok, _ = pcall(require, "multiple-cursors")
  if not ok then return end
  local m = vim.fn.mode()
  if m == "s" or m == "S" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>", true, false, true), "nx", false)
  elseif m == "i" then
    vim.cmd("stopinsert")
  end
  vim.g.minimal_mc_active = true
  vim.opt.selection = "inclusive"
  pcall(vim.cmd, "MultipleCursorsAddMatches")
end

-- 19. Keybindings & Complete Keyboard Safety
local map = vim.keymap.set

-- Ctrl+C and Ctrl+X Line/Selection Behavior
local function copy_action()
  local mode = vim.fn.mode()
  if mode == "s" or mode == "v" or mode == "V" or mode == "\22" then
    if mode == "s" then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>", true, false, true), "nx", false)
    end
    vim.cmd('normal! "+y')
    vim.cmd("startinsert")
  else
    local line = vim.api.nvim_get_current_line()
    vim.fn.setreg("+", line .. "\n", "l")
    vim.fn.setreg('"', line .. "\n", "l")
  end
end

local function cut_action()
  local mode = vim.fn.mode()
  if mode == "s" or mode == "v" or mode == "V" or mode == "\22" then
    if mode == "s" then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>", true, false, true), "nx", false)
    end
    vim.cmd('normal! "+d')
    vim.cmd("startinsert")
  else
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1]
    local line = vim.api.nvim_get_current_line()
    vim.fn.setreg("+", line .. "\n", "l")
    vim.fn.setreg('"', line .. "\n", "l")

    local total_lines = vim.api.nvim_buf_line_count(0)
    if total_lines == 1 then
      vim.api.nvim_set_current_line("")
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
    else
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, {})
      local new_row = math.min(row, total_lines - 1)
      local next_line = vim.api.nvim_buf_get_lines(0, new_row - 1, new_row, false)[1] or ""
      local new_col = math.min(cursor[2], #next_line)
      vim.api.nvim_win_set_cursor(0, { new_row, new_col })
    end
    vim.cmd("startinsert")
  end
end

map({ "i", "n", "s", "x" }, "<C-c>", copy_action, { desc = "Copy Selection or Current Line" })
map({ "i", "n", "s", "x" }, "<C-x>", cut_action, { desc = "Cut Selection or Current Line" })

-- Paste (Ctrl+V)
map({ "i", "n" }, "<C-v>", '<C-r><C-o>+', { desc = "Paste Clipboard" })
map("s", "<C-v>", '<C-g>"+p<cmd>startinsert<cr>', { desc = "Paste Over Selection" })
map("x", "<C-v>", '"+p<cmd>startinsert<cr>', { desc = "Paste Over Selection" })

-- Undo (Ctrl+U & Ctrl+Z)
map({ "i", "n", "v", "s" }, "<C-u>", "<cmd>undo<cr><cmd>startinsert<cr>", { desc = "Undo Last Action" })
map({ "i", "n", "v", "s" }, "<C-z>", "<cmd>undo<cr><cmd>startinsert<cr>", { desc = "Undo Last Action" })

-- Redo (Ctrl+Y & Ctrl+Shift+Z)
map({ "i", "n", "v", "s" }, "<C-y>", "<cmd>redo<cr><cmd>startinsert<cr>", { desc = "Redo" })
map({ "i", "n", "v", "s" }, "<C-S-z>", "<cmd>redo<cr><cmd>startinsert<cr>", { desc = "Redo" })

-- Automatically create parent directories on save if they don't exist
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    if args.file and args.file ~= "" and not args.file:match("^%a+://") then
      local dir = vim.fn.fnamemodify(args.file, ":p:h")
      if vim.fn.isdirectory(dir) == 0 then
        pcall(vim.fn.mkdir, dir, "p")
      end
    end
  end,
})

-- Save (Ctrl+S) with auto-imports and formatting
map({ "i", "n", "v", "s" }, "<C-s>", function()
  ensure_conform()
  organize_lsp_imports(0)
  local ok, conf = pcall(require, "conform")
  if ok then
    conf.format({ async = false, lsp_format = "fallback" })
  end
  vim.cmd("silent! write")
  vim.cmd("startinsert")
end, { desc = "Auto-Import, Format & Save File" })

-- Format Code (Alt+Shift+F & Ctrl+Shift+I)
map({ "i", "n", "v", "s" }, "<M-F>", _G.format_buffer, { desc = "Format Document" })
map({ "i", "n", "v", "s" }, "<M-S-f>", _G.format_buffer, { desc = "Format Document" })
map({ "i", "n", "v", "s" }, "<M-S-F>", _G.format_buffer, { desc = "Format Document" })
map({ "i", "n", "v", "s" }, "<C-S-i>", _G.format_buffer, { desc = "Format Document" })
map({ "i", "n", "v", "s" }, "<C-S-I>", _G.format_buffer, { desc = "Format Document" })

-- Toggle Comments (Ctrl+/) for Single Line & Multiline in all languages
local function get_comment_parts(buf)
  local cs = vim.bo[buf].commentstring
  if not cs or cs == "" or not cs:find("%%s") then
    cs = "// %s"
  end
  local prefix, suffix = cs:match("^(.-)%%s(.*)$")
  prefix = prefix or "// "
  suffix = suffix or ""
  if prefix ~= "" and not prefix:match("%s$") then
    prefix = prefix .. " "
  end
  if suffix ~= "" and not suffix:match("^%s") then
    suffix = " " .. suffix
  end
  return prefix, suffix
end

local function toggle_comment()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype == "NvimTree"
    or vim.bo[buf].buftype == "terminal"
    or vim.bo[buf].filetype == "minimal_home"
    or vim.b[buf].is_picker
    or not vim.bo[buf].modifiable
  then
    return
  end

  local mode = vim.fn.mode()
  if mode:match("[vV\22sS\19]") then
    if mode:match("[sS\19]") then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>", true, false, true), "nx", false)
    end
    local vstart = vim.fn.getpos("v")[2]
    local vcur = vim.fn.getcurpos()[2]
    local r1, r2 = math.min(vstart, vcur), math.max(vstart, vcur)
    local sel_lines = vim.api.nvim_buf_get_lines(buf, r1 - 1, r2, false)
    local all_blank = true
    for _, l in ipairs(sel_lines) do
      if not l:match("^%s*$") then
        all_blank = false
        break
      end
    end
    if all_blank then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
      local prefix, suffix = get_comment_parts(buf)
      for idx, l in ipairs(sel_lines) do
        sel_lines[idx] = l .. prefix .. suffix
      end
      vim.api.nvim_buf_set_lines(buf, r1 - 1, r2, false, sel_lines)
      vim.api.nvim_win_set_cursor(0, { r1, #(sel_lines[1]) - #suffix })
      if suffix == "" then
        vim.cmd("startinsert!")
      else
        vim.cmd("startinsert")
      end
    else
      vim.cmd("normal gc")
      vim.cmd("startinsert")
    end
    return
  end

  local cur = vim.api.nvim_win_get_cursor(0)
  local row = cur[1]
  local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""
  if line:match("^%s*$") then
    local prefix, suffix = get_comment_parts(buf)
    local new_line = line .. prefix .. suffix
    vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { new_line })
    vim.api.nvim_win_set_cursor(0, { row, #(line .. prefix) })
    if suffix == "" then
      vim.cmd("startinsert!")
    else
      vim.cmd("startinsert")
    end
  else
    vim.cmd("normal gcc")
    vim.cmd("startinsert")
  end
end

map({ "i", "n", "v", "s" }, "<C-/>", toggle_comment, { desc = "Toggle Comment" })
map({ "i", "n", "v", "s" }, "<C-_>", toggle_comment, { desc = "Toggle Comment" })

-- Toggle Multiline / Block Comments (Shift+Alt+A) like VS Code
local block_delims = {
  javascript = { open = "/*", close = "*/" },
  javascriptreact = { open = "{/*", close = "*/}" },
  typescript = { open = "/*", close = "*/" },
  typescriptreact = { open = "{/*", close = "*/}" },
  css = { open = "/*", close = "*/" },
  scss = { open = "/*", close = "*/" },
  less = { open = "/*", close = "*/" },
  c = { open = "/*", close = "*/" },
  cpp = { open = "/*", close = "*/" },
  cs = { open = "/*", close = "*/" },
  java = { open = "/*", close = "*/" },
  go = { open = "/*", close = "*/" },
  rust = { open = "/*", close = "*/" },
  php = { open = "/*", close = "*/" },
  kotlin = { open = "/*", close = "*/" },
  swift = { open = "/*", close = "*/" },
  dart = { open = "/*", close = "*/" },
  sql = { open = "/*", close = "*/" },
  python = { open = '"""', close = '"""' },
  html = { open = "<!--", close = "-->" },
  xml = { open = "<!--", close = "-->" },
  markdown = { open = "<!--", close = "-->" },
  svg = { open = "<!--", close = "-->" },
  vue = { open = "<!--", close = "-->" },
  svelte = { open = "<!--", close = "-->" },
  lua = { open = "--[[", close = "]]" },
  sh = { open = ": '", close = "'" },
  bash = { open = ": '", close = "'" },
  zsh = { open = ": '", close = "'" },
  ruby = { open = "=begin", close = "=end" },
  haskell = { open = "{-", close = "-}" },
  ocaml = { open = "(*", close = "*)" },
}

_G.toggle_block_comment = function()
  if vim.bo.buftype == "terminal" or vim.bo.filetype == "NvimTree" then return end
  local ft = vim.bo.filetype
  local delims = block_delims[ft]
  if not delims then
    local cs = vim.bo.commentstring
    if cs and cs:find("%%s") then
      local op, cl = cs:match("^%s*(.-)%s*%%s%s*(.-)%s*$")
      if op and cl and op ~= "" and cl ~= "" and op ~= cl then
        delims = { open = op, close = cl }
      end
    end
  end
  if not delims then
    delims = { open = "/*", close = "*/" }
  end
  local op = delims.open
  local cl = delims.close

  local mode = vim.fn.mode()
  if mode == "s" or mode == "v" or mode == "V" or mode == "\22" then
    local vpos = vim.fn.getpos("v")
    local curpos = vim.fn.getpos(".")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "nx", false)

    local s_row, s_col = vpos[2] - 1, vpos[3] - 1
    local e_row, e_col = curpos[2] - 1, curpos[3] - 1
    if s_row > e_row or (s_row == e_row and s_col > e_col) then
      s_row, e_row = e_row, s_row
      s_col, e_col = e_col, s_col
    end

    if mode == "V" then
      s_col = 0
      local last_line = vim.api.nvim_buf_get_lines(0, e_row, e_row + 1, false)[1] or ""
      e_col = #last_line
    else
      e_col = e_col + 1
    end

    local ok, text_lines = pcall(vim.api.nvim_buf_get_text, 0, s_row, s_col, e_row, e_col, {})
    if not ok or #text_lines == 0 then
      vim.cmd("startinsert")
      return
    end

    local text = table.concat(text_lines, "\n")
    local pattern_op = "^%s*" .. vim.pesc(op) .. "%s?"
    local pattern_cl = "%s?" .. vim.pesc(cl) .. "%s*$"
    if text:find(pattern_op) and text:find(pattern_cl) then
      local unwrapped = text:gsub(pattern_op, "", 1):gsub(pattern_cl, "", 1)
      local new_lines = vim.split(unwrapped, "\n", { plain = true })
      vim.api.nvim_buf_set_text(0, s_row, s_col, e_row, e_col, new_lines)
    else
      local wrapped = op .. " " .. text .. " " .. cl
      local new_lines = vim.split(wrapped, "\n", { plain = true })
      vim.api.nvim_buf_set_text(0, s_row, s_col, e_row, e_col, new_lines)
    end
    vim.cmd("startinsert")
  else
    local cur = vim.api.nvim_win_get_cursor(0)
    local row = cur[1] - 1
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
    local indent = line:match("^(%s*)") or ""
    local content = line:sub(#indent + 1)

    local pattern_op = "^" .. vim.pesc(op) .. "%s?"
    local pattern_cl = "%s?" .. vim.pesc(cl) .. "$"
    if content:find(pattern_op) and content:find(pattern_cl) then
      local unwrapped = content:gsub(pattern_op, "", 1):gsub(pattern_cl, "", 1)
      vim.api.nvim_buf_set_lines(0, row, row + 1, false, { indent .. unwrapped })
      vim.api.nvim_win_set_cursor(0, { row + 1, math.min(#indent + #unwrapped, cur[2]) })
    else
      if content == "" then
        local new_line = indent .. op .. "  " .. cl
        vim.api.nvim_buf_set_lines(0, row, row + 1, false, { new_line })
        vim.api.nvim_win_set_cursor(0, { row + 1, #indent + #op + 1 })
      else
        local new_line = indent .. op .. " " .. content .. " " .. cl
        vim.api.nvim_buf_set_lines(0, row, row + 1, false, { new_line })
        vim.api.nvim_win_set_cursor(0, { row + 1, math.min(#new_line, cur[2] + #op + 1) })
      end
    end
    vim.cmd("startinsert")
  end
end

map({ "i", "n", "v", "s" }, "<M-A>", _G.toggle_block_comment, { desc = "Toggle Multiline Block Comment" })
map({ "i", "n", "v", "s" }, "<M-S-a>", _G.toggle_block_comment, { desc = "Toggle Multiline Block Comment" })
map({ "i", "n", "v", "s" }, "<M-S-A>", _G.toggle_block_comment, { desc = "Toggle Multiline Block Comment" })

-- Indent / Unindent Line or Selection (Ctrl+] adds a tab space, Ctrl+[ removes one tab space)
_G.indent_line_or_selection = function(delta)
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype == "NvimTree"
    or vim.bo[buf].buftype == "terminal"
    or vim.bo[buf].filetype == "minimal_home"
    or vim.b[buf].is_picker
    or not vim.bo[buf].modifiable
  then
    return
  end

  local sw = vim.bo[buf].shiftwidth > 0 and vim.bo[buf].shiftwidth or vim.bo[buf].tabstop
  if not sw or sw <= 0 then sw = 4 end
  local use_tabs = not vim.bo[buf].expandtab
  local tab_unit = use_tabs and "\t" or string.rep(" ", sw)

  local function adjust_line(line, skip_empty)
    if delta > 0 then
      if skip_empty and line == "" then
        return line, 0
      end
      return tab_unit .. line, #tab_unit
    else
      if line:sub(1, 1) == "\t" then
        return line:sub(2), -1
      end
      local spaces = line:match("^ +") or ""
      local rm = math.min(#spaces, sw)
      return line:sub(rm + 1), -rm
    end
  end

  -- Separate undo step
  vim.o.undolevels = vim.o.undolevels

  local m = vim.fn.mode()
  if m:match("[vV\22sS\19]") then
    local vstart = vim.fn.getpos("v")[2]
    local vcur = vim.fn.getcurpos()[2]
    local r1 = math.min(vstart, vcur)
    local r2 = math.max(vstart, vcur)
    local lines = vim.api.nvim_buf_get_lines(buf, r1 - 1, r2, false)
    local multi = (r1 < r2)
    for idx, line in ipairs(lines) do
      lines[idx] = adjust_line(line, multi)
    end
    vim.api.nvim_buf_set_lines(buf, r1 - 1, r2, false, lines)
    vim.cmd("normal! \27")
    vim.api.nvim_win_set_cursor(0, { r1, 0 })
    vim.cmd("normal! V")
    vim.api.nvim_win_set_cursor(0, { r2, 0 })
  else
    local cur = vim.api.nvim_win_get_cursor(0)
    local row, col = cur[1], cur[2]
    local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""
    local new_line, col_delta = adjust_line(line, false)
    vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { new_line })
    vim.api.nvim_win_set_cursor(0, { row, math.max(0, col + col_delta) })
    if m == "n" then
      vim.cmd("startinsert")
    end
  end
end

map({ "i", "n", "v", "s" }, "<C-]>", function() _G.indent_line_or_selection(1) end, { desc = "Indent Line or Selection" })
map({ "i", "n", "v", "s" }, "<C-[>", function() _G.indent_line_or_selection(-1) end, { desc = "Unindent Line or Selection" })
map({ "i", "n", "v", "s" }, "<S-Tab>", function() _G.indent_line_or_selection(-1) end, { desc = "Unindent Line or Selection" })

-- New File (Ctrl+N)
map({ "i", "n", "v", "s" }, "<C-n>", function() _G.homescreen_new_file() end, { desc = "New File" })

-- Select All (Ctrl+A): Selects entire buffer into Select mode
map({ "i", "n", "v", "s" }, "<C-a>", "<C-\\><C-n>gg0vG$<C-g>", { desc = "Select All" })

-- Selection Deletion (Backspace & Delete in Select and Visual modes)
map("s", "<BS>", '<C-g>"_d<cmd>startinsert<cr>', { desc = "Delete Selection" })
map("s", "<Del>", '<C-g>"_d<cmd>startinsert<cr>', { desc = "Delete Selection" })
map("x", "<BS>", '"_d<cmd>startinsert<cr>', { desc = "Delete Selection" })
map("x", "<Del>", '"_d<cmd>startinsert<cr>', { desc = "Delete Selection" })

-- Selection Auto-Surround (Quotes & Brackets wrap selected text in visual/select mode)
local function surround_selection(open_ch, close_ch)
  if vim.bo.filetype == "NvimTree" or vim.bo.buftype == "terminal" then return end

  local vpos = vim.fn.getpos("v")
  local curpos = vim.fn.getpos(".")

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "nx", false)

  local s_row, s_col = vpos[2] - 1, vpos[3] - 1
  local e_row, e_col = curpos[2] - 1, curpos[3] - 1

  if s_row > e_row or (s_row == e_row and s_col > e_col) then
    s_row, e_row = e_row, s_row
    s_col, e_col = e_col, s_col
  end

  if s_row == e_row and s_col == e_col then
    vim.cmd("startinsert")
    return
  end

  local ok, lines = pcall(vim.api.nvim_buf_get_text, 0, s_row, s_col, e_row, e_col, {})
  if not ok or #lines == 0 then
    vim.cmd("startinsert")
    return
  end

  -- Separate undo block so Ctrl+Z / Ctrl+U undos only the surround
  vim.o.undolevels = vim.o.undolevels

  lines[1] = open_ch .. lines[1]
  lines[#lines] = lines[#lines] .. close_ch
  vim.api.nvim_buf_set_text(0, s_row, s_col, e_row, e_col, lines)

  local new_e_row = e_row + 1
  local cur_line = vim.api.nvim_buf_get_lines(0, e_row, e_row + 1, false)[1] or ""
  local max_col = #cur_line
  local new_e_col = (s_row == e_row and (e_col + #open_ch + #close_ch) or (#lines[#lines]))

  if new_e_col >= max_col then
    vim.api.nvim_win_set_cursor(0, { new_e_row, math.max(0, max_col - 1) })
    vim.cmd("startinsert!")
  else
    vim.api.nvim_win_set_cursor(0, { new_e_row, new_e_col })
    vim.cmd("startinsert")
  end
end

local surround_pairs = {
  ['"'] = { '"', '"' },
  ["'"] = { "'", "'" },
  ["`"] = { "`", "`" },
  ["("] = { "(", ")" },
  [")"] = { "(", ")" },
  ["["] = { "[", "]" },
  ["]"] = { "[", "]" },
  ["{"] = { "{", "}" },
  ["}"] = { "{", "}" },
  ["<"] = { "<", ">" },
  [">"] = { "<", ">" },
}

for key, pair in pairs(surround_pairs) do
  map({ "s", "x" }, key, function()
    surround_selection(pair[1], pair[2])
  end, { desc = "Surround Selection with " .. pair[1] .. pair[2] })
end

-- Word Navigation (Ctrl+Left / Ctrl+Right)
map({ "i", "n" }, "<C-Right>", _G.move_word_right, { desc = "Jump Word Right" })
map({ "i", "n" }, "<C-Left>", _G.move_word_left, { desc = "Jump Word Left" })

-- Arrow Selection (Shift+Up / Down / Left / Right — expr mappings stay cleanly in Select mode without boundary errors)
local function shift_select_expr(dir)
  local m = vim.fn.mode()
  local cur = vim.api.nvim_win_get_cursor(0)
  local row, col = cur[1], cur[2]
  local last_row = vim.api.nvim_buf_line_count(0)
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""

  local at_edge = (dir == "up" and row <= 1)
    or (dir == "down" and row >= last_row)
    or (dir == "left" and col <= 0)
    or (dir == "right" and col >= #line)

  if at_edge then
    return ""
  end

  local motion = ({ up = "g<Up>", down = "g<Down>", left = "h", right = "l" })[dir]
  if m == "i" then
    return "<C-o>v" .. motion .. "<C-g>"
  elseif m == "s" or m == "S" then
    return "<C-g>" .. motion .. "<C-g>"
  elseif m == "n" then
    return "v" .. motion .. "<C-g>"
  end
  return motion
end

for _, spec in ipairs({
  { "<S-Up>", "up", "Select Up" },
  { "<S-Down>", "down", "Select Down" },
  { "<S-Left>", "left", "Select Left" },
  { "<S-Right>", "right", "Select Right" },
}) do
  local lhs, dir, desc = spec[1], spec[2], spec[3]
  map({ "i", "s", "n", "x" }, lhs, function()
    return shift_select_expr(dir)
  end, { expr = true, replace_keycodes = true, desc = desc })
end

-- Plain navigation from Select mode cleanly exits selection and moves in Insert mode
for _, nav in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>", "<Home>", "<End>" }) do
  map("s", nav, function()
    local cur = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g><Esc>", true, false, true), "nx", false)
    if cur[2] >= #line then
      vim.cmd("startinsert!")
    else
      vim.cmd("startinsert")
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(nav, true, false, true), "n", false)
  end, { desc = "Exit Selection and Move" })
end
map("s", "<C-Left>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  vim.cmd("startinsert")
  _G.move_word_left()
end, { desc = "Exit Selection and Jump Word Left" })
map("s", "<C-Right>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  vim.cmd("startinsert")
  _G.move_word_right()
end, { desc = "Exit Selection and Jump Word Right" })

-- Word Selection (Ctrl+Shift+Right / Ctrl+Shift+Left)
map("i", "<C-S-Right>", "<C-o>v<cmd>lua _G.move_word_right()<cr><C-g>", { desc = "Select Word Right" })
map("s", "<C-S-Right>", "<C-g><cmd>lua _G.move_word_right()<cr><C-g>", { desc = "Select Word Right" })
map("i", "<C-S-Left>", "<C-o>v<cmd>lua _G.move_word_left()<cr><C-g>", { desc = "Select Word Left" })
map("s", "<C-S-Left>", "<C-g><cmd>lua _G.move_word_left()<cr><C-g>", { desc = "Select Word Left" })

-- Word Deletion (Ctrl+Backspace & Ctrl+Delete across all modes)
map({ "i", "n", "s" }, "<C-BS>", delete_word_backward, { desc = "Delete Word Backward" })
map({ "i", "n", "s" }, "<C-BackSpace>", delete_word_backward, { desc = "Delete Word Backward" })
map({ "i", "n", "s" }, "<M-BS>", delete_word_backward, { desc = "Delete Word Backward" })
map({ "i", "n", "s" }, "<M-BackSpace>", delete_word_backward, { desc = "Delete Word Backward" })

map({ "i", "n", "s" }, "<C-Del>", delete_word_forward, { desc = "Delete Word Forward" })
map({ "i", "n", "s" }, "<C-Delete>", delete_word_forward, { desc = "Delete Word Forward" })
map({ "i", "n", "s" }, "<M-Del>", delete_word_forward, { desc = "Delete Word Forward" })
map({ "i", "n", "s" }, "<M-Delete>", delete_word_forward, { desc = "Delete Word Forward" })

-- Line Deletion (Shift+Delete & Ctrl+Shift+Delete - keep Ctrl+Shift+K dedicated to Font Picker chord)
map({ "i", "n", "v", "s" }, "<S-Del>", _G.delete_line, { desc = "Delete Line or Selection" })
map({ "i", "n", "v", "s" }, "<S-Delete>", _G.delete_line, { desc = "Delete Line or Selection" })
map({ "i", "n", "v", "s" }, "<C-S-Del>", _G.delete_line, { desc = "Delete Line or Selection" })
map({ "i", "n", "v", "s" }, "<C-S-Delete>", _G.delete_line, { desc = "Delete Line or Selection" })
map({ "i", "n", "v", "s" }, "<S-kDel>", _G.delete_line, { desc = "Delete Line or Selection" })
map({ "i", "n", "v", "s" }, "<C-S-kDel>", _G.delete_line, { desc = "Delete Line or Selection" })

-- Shift + BackSpace
map({ "i", "n" }, "<S-BS>", "<BS>", { desc = "Backspace" })
map({ "i", "n" }, "<S-BackSpace>", "<BS>", { desc = "Backspace" })
map({ "v", "s" }, "<S-BS>", '<C-g>"_d<cmd>startinsert<cr>', { desc = "Delete Selection" })
map({ "v", "s" }, "<S-BackSpace>", '<C-g>"_d<cmd>startinsert<cr>', { desc = "Delete Selection" })

-- Universal Paste: Shift+Insert
map({ "i", "n", "v", "s" }, "<S-Insert>", '<cmd>startinsert<cr><C-r><C-o>+', { desc = "Paste from Clipboard" })
map({ "i", "n", "v", "s" }, "<S-kInsert>", '<cmd>startinsert<cr><C-r><C-o>+', { desc = "Paste from Clipboard" })
map("t", "<S-Insert>", '<C-\\><C-n>"+pi', { desc = "Paste into Terminal" })

-- Code Spell Checker & Quick Fix: Ctrl+. / Ctrl+Period
map({ "i", "n", "v", "s" }, "<C-.>", _G.open_quick_fix_spell, { desc = "Code Spell Checker & Quick Fix" })
map({ "i", "n", "v", "s" }, "<C-Period>", _G.open_quick_fix_spell, { desc = "Code Spell Checker & Quick Fix" })

-- Home / End Navigation
map("i", "<Home>", "<C-o>0", { desc = "Line Start" })
map("i", "<End>", "<C-o>$", { desc = "Line End" })
map("i", "<C-Home>", "<C-o>gg<C-o>0", { desc = "Document Start" })
map("i", "<C-End>", function()
  local lines = vim.api.nvim_buf_line_count(0)
  local last = vim.api.nvim_buf_get_lines(0, lines - 1, lines, false)[1] or ""
  vim.api.nvim_win_set_cursor(0, { lines, #last })
end, { desc = "Document End" })

-- Home / End Selection (boundary-safe expr mappings)
local function shift_home_end_expr(kind)
  local m = vim.fn.mode()
  local cur = vim.api.nvim_win_get_cursor(0)
  local row, col = cur[1], cur[2]
  local last_row = vim.api.nvim_buf_line_count(0)
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""

  local at_edge = (kind == "home" and col <= 0)
    or (kind == "end" and col >= #line)
    or (kind == "doc_home" and row <= 1 and col <= 0)
    or (kind == "doc_end" and row >= last_row and col >= #line)

  if at_edge then return "" end

  local motion = ({ home = "0", ["end"] = "$", doc_home = "gg0", doc_end = "G$" })[kind]
  if m == "i" then return "<C-o>v" .. motion .. "<C-g>" end
  if m == "s" or m == "S" then return "<C-g>" .. motion .. "<C-g>" end
  if m == "n" then return "v" .. motion .. "<C-g>" end
  return motion
end

map({ "i", "s", "n" }, "<S-Home>", function() return shift_home_end_expr("home") end, { expr = true, replace_keycodes = true, desc = "Select to Line Start" })
map({ "i", "s", "n" }, "<S-End>", function() return shift_home_end_expr("end") end, { expr = true, replace_keycodes = true, desc = "Select to Line End" })
map({ "i", "s", "n" }, "<C-S-Home>", function() return shift_home_end_expr("doc_home") end, { expr = true, replace_keycodes = true, desc = "Select to Document Start" })
map({ "i", "s", "n" }, "<C-S-End>", function() return shift_home_end_expr("doc_end") end, { expr = true, replace_keycodes = true, desc = "Select to Document End" })

-- Line Insertion (Ctrl+Enter & Ctrl+Shift+Enter)
map("i", "<C-CR>", "<C-o>o", { desc = "Insert Line Below" })
map("i", "<C-S-CR>", "<C-o>O", { desc = "Insert Line Above" })

-- Find (Ctrl+F)
map({ "i", "n" }, "<C-f>", "<Esc>/", { desc = "Find" })

-- Theme Picker (Ctrl+K Ctrl+T / Ctrl+K t) Like VS Code
map({ "i", "n", "v", "s", "t" }, "<C-k><C-t>", _G.open_theme_picker, { desc = "Color Theme Picker" })
map({ "i", "n", "v", "s", "t" }, "<C-k>t", _G.open_theme_picker, { desc = "Color Theme Picker" })
map({ "i", "n", "v", "s", "t" }, "<C-k><C-T>", _G.open_theme_picker, { desc = "Color Theme Picker" })
map({ "i", "n", "v", "s", "t" }, "<C-k>T", _G.open_theme_picker, { desc = "Color Theme Picker" })

-- Desktop Fonts Picker (Ctrl+Shift+K+T / Ctrl+Shift+K t / Ctrl+K Ctrl+Shift+T)
for _, pfx in ipairs({ "<C-S-k>", "<C-S-K>" }) do
  for _, sfx in ipairs({ "<C-S-t>", "<C-S-T>", "<C-t>", "<C-T>", "t", "T" }) do
    map({ "i", "n", "v", "s", "t" }, pfx .. sfx, _G.open_font_picker, { desc = "Desktop Font Picker" })
  end
  map({ "i", "n", "v", "s", "t" }, pfx, "<nop>", { desc = "Font Picker Chord Prefix" })
end
map({ "i", "n", "v", "s", "t" }, "<C-k><C-S-t>", _G.open_font_picker, { desc = "Desktop Font Picker" })
map({ "i", "n", "v", "s", "t" }, "<C-k><C-S-T>", _G.open_font_picker, { desc = "Desktop Font Picker" })

-- Open Folder (Ctrl+K Ctrl+O / Ctrl+K o) Like VS Code
map({ "i", "n", "v", "s", "t" }, "<C-k><C-o>", _G.open_folder_picker, { desc = "Open Folder" })
map({ "i", "n", "v", "s", "t" }, "<C-k>o", _G.open_folder_picker, { desc = "Open Folder" })
map({ "i", "n", "v", "s", "t" }, "<C-k><C-O>", _G.open_folder_picker, { desc = "Open Folder" })
map({ "i", "n", "v", "s", "t" }, "<C-k>O", _G.open_folder_picker, { desc = "Open Folder" })
map({ "i", "n", "v", "s", "t" }, "<C-k>", "<nop>", { desc = "Chord Prefix (No Digraph)" })

-- Keyboard Shortcuts Panel (Ctrl+Shift+P)
map({ "i", "n", "v", "s", "t" }, "<C-S-p>", _G.open_keybindings_panel, { desc = "Keyboard Shortcuts Panel" })
map({ "i", "n", "v", "s", "t" }, "<C-S-P>", _G.open_keybindings_panel, { desc = "Keyboard Shortcuts Panel" })

-- Sidebar Toggle (Ctrl+B) & Focus Toggle (Ctrl+Shift+E)
_G.toggle_sidebar_focus = function()
  if _G.ensure_ui_chrome then _G.ensure_ui_chrome() end
  local ok, t = pcall(require, "nvim-tree.api")
  if not ok then return end

  local cur_win = vim.api.nvim_get_current_win()
  local cur_buf = vim.api.nvim_win_get_buf(cur_win)
  local cur_ft = vim.bo[cur_buf].filetype
  local buf_name = vim.api.nvim_buf_get_name(cur_buf)

  local is_tree = (cur_ft == "NvimTree" or buf_name:match("NvimTree") ~= nil)

  if is_tree then
    local ed_win = find_editor_win()
    if ed_win and vim.api.nvim_win_is_valid(ed_win) then
      vim.api.nvim_set_current_win(ed_win)
      vim.cmd("startinsert")
    end
  else
    if not t.tree.is_visible() then
      t.tree.open({ focus = true })
    else
      t.tree.focus()
    end
  end
end

_G.toggle_tree = function()
  if _G.ensure_ui_chrome then _G.ensure_ui_chrome() end
  local ok, t = pcall(require, "nvim-tree.api")
  if not ok then return end
  local was_in_tree = vim.bo.filetype == "NvimTree"
  vim.g.minimal_ignore_tree_stopinsert = true
  pcall(t.tree.toggle, { focus = false })
  vim.g.minimal_ignore_tree_stopinsert = false
  if was_in_tree then
    local ed = find_editor_win()
    if ed and vim.api.nvim_win_is_valid(ed) then
      vim.api.nvim_set_current_win(ed)
    end
  end
  if vim.bo.buftype == "" and vim.bo.filetype ~= "NvimTree" then
    vim.cmd("startinsert")
  end
  enforce_buffer_mode()
  vim.schedule(enforce_buffer_mode)
end

map({ "i", "n", "v", "s", "t" }, "<C-b>", _G.toggle_tree, { desc = "Toggle Sidebar" })

map({ "i", "n", "v", "s" }, "<C-S-e>", _G.toggle_sidebar_focus, { desc = "Toggle Sidebar Focus" })
map("t", "<C-S-e>", "<C-\\><C-n><cmd>lua _G.toggle_sidebar_focus()<cr>", { desc = "Toggle Sidebar Focus" })
map({ "i", "n", "v", "s" }, "<C-S-E>", _G.toggle_sidebar_focus, { desc = "Toggle Sidebar Focus" })
map("t", "<C-S-E>", "<C-\\><C-n><cmd>lua _G.toggle_sidebar_focus()<cr>", { desc = "Toggle Sidebar Focus" })
map({ "i", "n", "v", "s" }, "<C-E>", _G.toggle_sidebar_focus, { desc = "Toggle Sidebar Focus" })
map("t", "<C-E>", "<C-\\><C-n><cmd>lua _G.toggle_sidebar_focus()<cr>", { desc = "Toggle Sidebar Focus" })

-- Built-in Terminal Drawer Toggle (Ctrl+` / Ctrl+~ / Ctrl+J) in ALL modes
map({ "i", "n", "v", "s" }, "<C-`>", _G.toggle_terminal, { desc = "Toggle Built-in Terminal" })
map("t", "<C-`>", "<C-\\><C-n><cmd>lua _G.toggle_terminal()<cr>", { desc = "Toggle Built-in Terminal" })
map({ "i", "n", "v", "s" }, "<C-~>", _G.toggle_terminal, { desc = "Toggle Built-in Terminal" })
map("t", "<C-~>", "<C-\\><C-n><cmd>lua _G.toggle_terminal()<cr>", { desc = "Toggle Built-in Terminal" })
map({ "i", "n", "v", "s" }, "<C-j>", _G.toggle_terminal, { desc = "Toggle Built-in Terminal" })
map("t", "<C-j>", "<C-\\><C-n><cmd>lua _G.toggle_terminal()<cr>", { desc = "Toggle Built-in Terminal" })

-- Multiple Terminal Instances: Alt+N T creates a new terminal instance
map({ "i", "n", "v", "s", "t" }, "<M-n>t", _G.new_terminal, { desc = "New Terminal Instance" })
map({ "i", "n", "v", "s", "t" }, "<M-n><M-t>", _G.new_terminal, { desc = "New Terminal Instance" })

-- Kill Active Terminal Instance: Shift+Alt+K kills active/focused terminal instance
map({ "i", "n", "v", "s", "t" }, "<M-K>", _G.kill_active_terminal, { desc = "Kill Active Terminal Instance" })
map({ "i", "n", "v", "s", "t" }, "<M-S-k>", _G.kill_active_terminal, { desc = "Kill Active Terminal Instance" })
map({ "i", "n", "v", "s", "t" }, "<M-S-K>", _G.kill_active_terminal, { desc = "Kill Active Terminal Instance" })

-- Visual Color Picker: Alt+C / Ctrl+Shift+C opens interactive colorpicker (color-picker.nvim)
map({ "i", "n", "v", "s" }, "<M-c>", _G.open_color_picker, { desc = "Visual Color Picker" })
map({ "i", "n", "v", "s" }, "<C-S-c>", _G.open_color_picker, { desc = "Visual Color Picker" })
map({ "i", "n", "v", "s" }, "<C-S-C>", _G.open_color_picker, { desc = "Visual Color Picker" })

-- Smart PageDown and PageUp Navigation (VS Code behavior)
map({ "i", "n", "v", "s" }, "<PageDown>", _G.smart_page_down, { desc = "Smart Page Down" })
map({ "i", "n", "v", "s" }, "<PgDn>", _G.smart_page_down, { desc = "Smart Page Down" })
map({ "i", "n", "v", "s" }, "<PageUp>", _G.smart_page_up, { desc = "Smart Page Up" })
map({ "i", "n", "v", "s" }, "<PgUp>", _G.smart_page_up, { desc = "Smart Page Up" })

-- Move Line Above / Below: Alt+Up / Alt+Down (and Resize Terminal in terminal pane)
map({ "n", "i", "s", "t", "v" }, "<M-Up>", _G.handle_alt_up, { desc = "Move Line Up (or Resize Terminal Up)" })
map({ "n", "i", "s", "t", "v" }, "<A-Up>", _G.handle_alt_up, { desc = "Move Line Up (or Resize Terminal Up)" })
map({ "n", "i", "s", "t", "v" }, "<M-Down>", _G.handle_alt_down, { desc = "Move Line Down (or Resize Terminal Down)" })
map({ "n", "i", "s", "t", "v" }, "<A-Down>", _G.handle_alt_down, { desc = "Move Line Down (or Resize Terminal Down)" })

-- Copy Line Below / Above (Shift+Alt+Down / Shift+Alt+Up)
map({ "n", "i", "s", "v" }, "<M-S-Down>", _G.copy_line_down, { desc = "Copy Line Below (Duplicate Down)" })
map({ "n", "i", "s", "v" }, "<A-S-Down>", _G.copy_line_down, { desc = "Copy Line Below (Duplicate Down)" })
map({ "n", "i", "s", "v" }, "<M-S-Up>", _G.copy_line_up, { desc = "Copy Line Above (Duplicate Up)" })
map({ "n", "i", "s", "v" }, "<A-S-Up>", _G.copy_line_up, { desc = "Copy Line Above (Duplicate Up)" })

-- Multi-Cursor & Multi-Select & Multi-Edit (VS Code Parity)
map({ "n", "i", "s", "v" }, "<C-M-Down>", "<cmd>MultipleCursorsAddDown<cr>", { desc = "Add Cursor Below" })
map({ "n", "i", "s", "v" }, "<C-A-Down>", "<cmd>MultipleCursorsAddDown<cr>", { desc = "Add Cursor Below" })
map({ "n", "i", "s", "v" }, "<C-M-Up>", "<cmd>MultipleCursorsAddUp<cr>", { desc = "Add Cursor Above" })
map({ "n", "i", "s", "v" }, "<C-A-Up>", "<cmd>MultipleCursorsAddUp<cr>", { desc = "Add Cursor Above" })

map({ "n", "i", "s", "v" }, "<C-d>", _G.multicursor_add_next, { desc = "Add Selection to Next Match (Multi-Select)" })
map({ "n", "i", "s", "v" }, "<C-S-l>", _G.multicursor_select_all, { desc = "Select All Occurrences (Multi-Edit)" })
map({ "n", "i", "s", "v" }, "<C-S-L>", _G.multicursor_select_all, { desc = "Select All Occurrences (Multi-Edit)" })
map({ "n", "i", "s", "v" }, "<C-k><C-d>", "<cmd>MultipleCursorsJumpNextMatch<cr>", { desc = "Skip Match and Jump to Next" })

map({ "n", "i", "s", "v" }, "<C-LeftMouse>", "<cmd>MultipleCursorsMouseAddDelete<cr>", { desc = "Add/Remove Cursor at Mouse Click" })
map({ "n", "i", "s", "v" }, "<M-LeftMouse>", "<cmd>MultipleCursorsMouseAddDelete<cr>", { desc = "Add/Remove Cursor at Mouse Click" })
map({ "n", "v", "s", "x" }, "<M-S-i>", "<cmd>MultipleCursorsAddVisualArea<cr>", { desc = "Add Cursors to Ends of Selected Lines" })
map({ "n", "v", "s", "x" }, "<M-S-I>", "<cmd>MultipleCursorsAddVisualArea<cr>", { desc = "Add Cursors to Ends of Selected Lines" })

-- Vim Relative Line Jumping (Alt+k / Alt+j) & Go to Line (Ctrl+G / Alt+G)
map({ "i", "n", "v", "s" }, "<M-k>", function() _G.relative_jump("up") end, { desc = "Jump Relative Lines Up" })
map({ "i", "n", "v", "s" }, "<M-j>", function() _G.relative_jump("down") end, { desc = "Jump Relative Lines Down" })
map({ "i", "n", "v", "s" }, "<C-g>", _G.goto_line, { desc = "Go to Line or Relative Jump" })
map({ "i", "n", "v", "s" }, "<M-g>", _G.goto_line, { desc = "Go to Line or Relative Jump" })

-- Tab Navigation: Ctrl+PageDown & Ctrl+PageUp
-- When inside integrated terminal, toggles terminal instances; when inside editor, toggles editor file tabs!
map({ "i", "n", "v", "s", "t" }, "<C-PageDown>", function()
  if vim.bo.buftype == "terminal" or (term_win and vim.api.nvim_get_current_win() == term_win) then
    _G.term_next()
  else
    _G.tab_next()
  end
end, { desc = "Next Tab (Editor or Terminal)" })

map({ "i", "n", "v", "s", "t" }, "<C-PgDn>", function()
  if vim.bo.buftype == "terminal" or (term_win and vim.api.nvim_get_current_win() == term_win) then
    _G.term_next()
  else
    _G.tab_next()
  end
end, { desc = "Next Tab (Editor or Terminal)" })

map({ "i", "n", "v", "s", "t" }, "<C-PageUp>", function()
  if vim.bo.buftype == "terminal" or (term_win and vim.api.nvim_get_current_win() == term_win) then
    _G.term_prev()
  else
    _G.tab_prev()
  end
end, { desc = "Previous Tab (Editor or Terminal)" })

map({ "i", "n", "v", "s", "t" }, "<C-PgUp>", function()
  if vim.bo.buftype == "terminal" or (term_win and vim.api.nvim_get_current_win() == term_win) then
    _G.term_prev()
  else
    _G.tab_prev()
  end
end, { desc = "Previous Tab (Editor or Terminal)" })

map({ "i", "n", "v", "s", "t" }, "<C-Tab>", function() _G.tab_next() end, { desc = "Next Tab" })
map({ "i", "n", "v", "s", "t" }, "<C-S-Tab>", function() _G.tab_prev() end, { desc = "Previous Tab" })

-- Terminal paste in terminal mode
map("t", "<C-v>", '<C-\\><C-n>"+pi', { desc = "Paste into Terminal" })

-- Jump to Tab 1-9 (Alt+1 through Alt+9)
for i = 1, 9 do
  map({ "i", "n", "v", "s", "t" }, "<M-" .. i .. ">", function()
    local bufs = get_listed_editor_bufs()
    if bufs[i] and vim.api.nvim_buf_is_valid(bufs[i]) then
      local ed = find_editor_win()
      if ed then vim.api.nvim_set_current_win(ed) end
      pcall(vim.api.nvim_set_current_buf, bufs[i])
      pcall(vim.cmd, "startinsert")
    end
  end, { desc = "Go to Tab " .. i })
end

-- Close File (Ctrl+W) & Quit (Ctrl+Q)
map({ "i", "n", "v", "s" }, "<C-w>", function() _G.close_buffer() end, { desc = "Close Active File" })
map({ "i", "n", "v", "s", "t" }, "<C-q>", "<cmd>qa<cr>", { desc = "Quit Notepad" })

_G.handle_escape = function()
  local ok_mc_mod, mc_mod = pcall(require, "multiple-cursors")
  if ok_mc_mod and mc_mod.deinit then
    pcall(mc_mod.deinit, true)
  end
  local ok_vc, vc = pcall(require, "multiple-cursors.virtual_cursors")
  if ok_vc and vc.clear then
    pcall(vc.clear)
  end
  local ns = vim.api.nvim_get_namespaces()["multiple-cursors"]
  if ns then
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(b) then
        pcall(vim.api.nvim_buf_clear_namespace, b, ns, 0, -1)
      end
    end
  end
  vim.g.minimal_mc_active = false
  vim.opt.selection = "exclusive"
  local m = vim.fn.mode()
  if m:match("[vVsS\x16\x13]") then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "nx", false)
  end
  vim.cmd("nohlsearch")
  vim.cmd("startinsert")
end

-- Escape: Deselects / Clears multi-cursors and search, stays in Insert Mode
map({ "i", "s", "x", "n" }, "<Esc>", _G.handle_escape, { desc = "Clear Selection / Multi-Cursors / Keep Typing" })

-- Disable colon command line access
map("n", ":", "<cmd>startinsert<cr>")

-- =============================================================================
-- EXHAUSTIVE KEYBOARD SAFETY FOR 15.6" LAPTOPS (deferred 5ms after paint)
-- =============================================================================
vim.defer_fn(function()
  -- 1. Block unassigned Ctrl keys so they never output digraphs, registers, or control characters
  local unassigned_ctrl = {
    "<C-l>", "<C-o>", "<C-p>", "<C-r>", "<C-t>",
    "<C-\\>", "<C-^>", "<C-@>",
  }
  for _, k in ipairs(unassigned_ctrl) do
    map({ "i", "n", "v", "s" }, k, "<nop>", { desc = "Disabled Unassigned Ctrl Key" })
  end

  -- 2. Prevent Insert key from ever entering Replace mode (-- REPLACE --)
  map({ "i", "n", "v", "s" }, "<Insert>", "<cmd>startinsert<cr>", { desc = "Prevent Replace Mode" })

  -- 3. Block F1 (Vim help) and F2-F12 accidental presses (plain, Shift, Ctrl, Alt, plus F13-F60 terminal codes)
  for i = 1, 60 do
    map({ "i", "n", "v", "s" }, "<F" .. i .. ">", "<nop>", { desc = "Disabled Function Key" })
    if i <= 12 then
      map({ "i", "n", "v", "s" }, "<S-F" .. i .. ">", "<nop>", { desc = "Disabled Function Key" })
      map({ "i", "n", "v", "s" }, "<C-F" .. i .. ">", "<nop>", { desc = "Disabled Function Key" })
      map({ "i", "n", "v", "s" }, "<M-F" .. i .. ">", "<nop>", { desc = "Disabled Function Key" })
      map({ "i", "n", "v", "s" }, "<C-S-F" .. i .. ">", "<nop>", { desc = "Disabled Function Key" })
    end
  end

  -- 4. Block unassigned Alt combinations so Alt keys never drop into Normal mode
  for c = 97, 122 do -- a-z
    local ch = string.char(c)
    if ch ~= "f" and ch ~= "c" and ch ~= "n" and ch ~= "k" and ch ~= "j" and ch ~= "g" and ch ~= "a" then
      map({ "i", "s" }, "<M-" .. ch .. ">", "<nop>")
      map({ "i", "s" }, "<M-" .. ch:upper() .. ">", "<nop>")
    end
  end
  map({ "i", "s" }, "<M-0>", "<nop>")

  -- Block Alt + punctuation/symbol combinations
  local alt_symbols = {
    "!", "@", "#", "$", "%", "^", "&", "*", "(", ")",
    "-", "_", "=", "+", "[", "]", "{", "}", ";", ":",
    "'", '"', ",", "<", ".", ">", "/", "?", "\\", "|",
    "`", "~", "<Space>",
  }
  for _, sym in ipairs(alt_symbols) do
    map({ "i", "s" }, "<M-" .. sym .. ">", "<nop>")
  end

  -- 5. Standardize 15.6" Laptop Numpad keys (Both NumLock ON and NumLock OFF)
  local numpad_keys = {
    ["<k0>"] = "0", ["<k1>"] = "1", ["<k2>"] = "2", ["<k3>"] = "3", ["<k4>"] = "4",
    ["<k5>"] = "5", ["<k6>"] = "6", ["<k7>"] = "7", ["<k8>"] = "8", ["<k9>"] = "9",
    ["<kPlus>"] = "+", ["<kMinus>"] = "-", ["<kMultiply>"] = "*", ["<kDivide>"] = "/",
    ["<kPoint>"] = ".", ["<kEnter>"] = "<CR>",
  }
  for k, v in pairs(numpad_keys) do
    map({ "i", "c", "s" }, k, v)
    map("n", k, function()
      vim.cmd("startinsert")
      vim.api.nvim_feedkeys(v, "m", false)
    end)
  end

  -- NumLock OFF navigation keys on full 15.6" keypad
  map({ "i", "n", "s" }, "<kHome>", "<Home>")
  map({ "i", "n", "s" }, "<kEnd>", "<End>")
  map({ "i", "n", "s" }, "<kPageUp>", "<PageUp>")
  map({ "i", "n", "s" }, "<kPageDown>", "<PageDown>")
  map({ "i", "n", "s" }, "<kLeft>", "<Left>")
  map({ "i", "n", "s" }, "<kRight>", "<Right>")
  map({ "i", "n", "s" }, "<kUp>", "<Up>")
  map({ "i", "n", "s" }, "<kDown>", "<Down>")
  map({ "i", "n", "v", "s" }, "<kInsert>", "<cmd>startinsert<cr>")
  map({ "i", "n", "s" }, "<kDel>", "<Del>")
  map({ "i", "n", "v", "s" }, "<kOrigin>", "<nop>")

  -- 6. Neutralize stray hardware and laptop media keys
  local stray_hardware_keys = { "<ScrollLock>", "<Pause>", "<Print>", "<Help>", "<Undo>" }
  for _, hk in ipairs(stray_hardware_keys) do
    map({ "i", "n", "v", "s" }, hk, "<nop>")
  end
end, 5)

-- 7. Smooth Scroll Navigation on Ctrl+Up / Ctrl+Down
map({ "i", "n", "v", "s" }, "<C-Up>", "<C-o><C-y>", { desc = "Scroll Viewport Up" })
map({ "i", "n", "v", "s" }, "<C-Down>", "<C-o><C-e>", { desc = "Scroll Viewport Down" })

-- 20. Sleek Modern Layout, Statusline & Window Highlights
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1e222a", fg = "#abb2bf" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#1e222a", fg = "#61afef" })
vim.api.nvim_set_hl(0, "Pmenu", { bg = "#21252b", fg = "#abb2bf" })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#3e4451", fg = "#ffffff", bold = true })
vim.api.nvim_set_hl(0, "PmenuBorder", { bg = "#21252b", fg = "#4b5263" })
vim.api.nvim_set_hl(0, "StatusLine", { bg = "#181a1f", fg = "#abb2bf" })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "#181a1f", fg = "#5c6370" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
vim.api.nvim_set_hl(0, "LineNr", { fg = "#4b5263" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#61afef", bold = true })

-- Modern VS Code-style Status Line (cached cwd + O(1) diagnostic counts)
local cached_cwd_raw = ""
local cached_cwd_display = ""
local function get_display_cwd()
  local cwd = vim.fn.getcwd()
  if cwd ~= cached_cwd_raw then
    cached_cwd_raw = cwd
    cached_cwd_display = vim.fn.fnamemodify(cwd, ":~")
  end
  return cached_cwd_display
end

function _G.editor_statusline()
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  if ft == "NvimTree" then return "  EXPLORER" end
  if ft == "minimal_home" then
    return "  Minimal %=" .. get_display_cwd() .. " "
  end
  if vim.bo[buf].buftype == "terminal" then
    return "  bash │ " .. get_display_cwd() .. " "
  end

  local branch = vim.b[buf].gitsigns_head or ""
  local branch_str = branch ~= "" and ("  " .. branch .. " │") or ""

  local counts = vim.diagnostic.count(buf)
  local diag_e = counts[vim.diagnostic.severity.ERROR] or 0
  local diag_w = counts[vim.diagnostic.severity.WARN] or 0
  local diag_str = ""
  if diag_e > 0 then diag_str = diag_str .. " 󰅚 " .. diag_e end
  if diag_w > 0 then diag_str = diag_str .. " 󰀪 " .. diag_w end
  if diag_str ~= "" then diag_str = diag_str .. " │" end

  local enc = (vim.bo[buf].fileencoding ~= "" and vim.bo[buf].fileencoding or "utf-8"):upper()

  return string.format("%s%s  %%f %%m %%=%s │ Spaces: %d │ Ln %%l, Col %%c ",
    branch_str, diag_str, enc, vim.bo[buf].shiftwidth)
end

vim.opt.statusline = "%!v:lua._G.editor_statusline()"

-- =============================================================================
-- 22. Rich Markdown (.md) Highlights, Visual Renderer & Productivity Suite
-- =============================================================================
local md_ns = vim.api.nvim_create_namespace("minimal_markdown_visuals")

_G.apply_markdown_highlights = function()
  local function copy_fg(target, fallback_fg, extra)
    local hl = vim.api.nvim_get_hl(0, { name = target, link = false })
    local fg = (hl and hl.fg) or fallback_fg
    local def = vim.tbl_extend("force", { fg = fg }, extra or {})
    return def
  end

  -- Distinct heading colors (linking/extending active theme)
  vim.api.nvim_set_hl(0, "MinimalMdH1", copy_fg("@markup.heading.1", "#61afef", { bold = true }))
  vim.api.nvim_set_hl(0, "MinimalMdH2", copy_fg("@markup.heading.2", "#98c379", { bold = true }))
  vim.api.nvim_set_hl(0, "MinimalMdH3", copy_fg("@markup.heading.3", "#e5c07b", { bold = true }))
  vim.api.nvim_set_hl(0, "MinimalMdH4", copy_fg("@markup.heading.4", "#cba6f7", { bold = true }))
  vim.api.nvim_set_hl(0, "MinimalMdH5", copy_fg("@markup.heading.5", "#fab387", { bold = true }))
  vim.api.nvim_set_hl(0, "MinimalMdH6", copy_fg("@markup.heading.6", "#89dceb", { bold = true }))

  vim.api.nvim_set_hl(0, "MinimalMdH1Bg", { bg = "#152030" })
  vim.api.nvim_set_hl(0, "MinimalMdH2Bg", { bg = "#14221d" })
  vim.api.nvim_set_hl(0, "MinimalMdCodeBlock", { bg = "#131620" })
  vim.api.nvim_set_hl(0, "MinimalMdCodeLang", { fg = "#61afef", bg = "#1f2433", bold = true })
  vim.api.nvim_set_hl(0, "MinimalMdQuoteBar", { fg = "#61afef", bold = true })
  vim.api.nvim_set_hl(0, "MinimalMdRule", { fg = "#3e4451" })
  vim.api.nvim_set_hl(0, "MinimalMdBullet", { fg = "#e5c07b", bold = true })
  vim.api.nvim_set_hl(0, "MinimalMdCheckboxTodo", { fg = "#e5c07b", bold = true })
  vim.api.nvim_set_hl(0, "MinimalMdCheckboxDone", { fg = "#98c379", bold = true })
  vim.api.nvim_set_hl(0, "MinimalMdDoneText", { fg = "#5c6370", strikethrough = true })
  vim.api.nvim_set_hl(0, "MinimalMdTableBorder", { fg = "#61afef" })
  vim.api.nvim_set_hl(0, "MinimalMdTableHead", { fg = "#e5c07b", bold = true })

  -- GitHub Callouts
  vim.api.nvim_set_hl(0, "MinimalMdCalloutNote", { fg = "#61afef", bold = true })
  vim.api.nvim_set_hl(0, "MinimalMdCalloutTip", { fg = "#98c379", bold = true })
  vim.api.nvim_set_hl(0, "MinimalMdCalloutImportant", { fg = "#cba6f7", bold = true })
  vim.api.nvim_set_hl(0, "MinimalMdCalloutWarning", { fg = "#fab387", bold = true })
  vim.api.nvim_set_hl(0, "MinimalMdCalloutCaution", { fg = "#f38ba8", bold = true })
end

local md_heading_icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " }
local md_bullets = { "•", "◦", "▪" }
local md_callouts = {
  NOTE = { icon = "󰋽 Note", hl = "MinimalMdCalloutNote" },
  TIP = { icon = "󰌶 Tip", hl = "MinimalMdCalloutTip" },
  IMPORTANT = { icon = "󰅾 Important", hl = "MinimalMdCalloutImportant" },
  WARNING = { icon = "󰀪 Warning", hl = "MinimalMdCalloutWarning" },
  CAUTION = { icon = "󰳦 Caution", hl = "MinimalMdCalloutCaution" },
}

local cached_md_devicons = nil
local function get_md_devicons()
  if cached_md_devicons == nil then
    local ok_dev, d = pcall(require, "nvim-web-devicons")
    cached_md_devicons = ok_dev and d or false
  end
  return cached_md_devicons or nil
end

local function render_md_line(buf, i, line, next_line, cur_row, fence_state)
  local r = i - 1
  local is_cur = (i == cur_row)

  if fence_state and fence_state.open then
    pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, 0, {
      line_hl_group = "MinimalMdCodeBlock",
      priority = 80,
    })
    local lang = fence_state.lang
    if lang and lang ~= "" and not is_cur then
      local icon = "󰅪 "
      local icon_hl = "MinimalMdCodeLang"
      local devicons = get_md_devicons()
      if devicons then
        local d_icon, d_hl = devicons.get_icon_by_filetype(lang, { default = false })
        if not d_icon then
          d_icon, d_hl = devicons.get_icon(lang, lang, { default = false })
        end
        if d_icon then
          icon = d_icon .. " "
          if d_hl and d_hl ~= "" then icon_hl = d_hl end
        end
      end
      pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, 0, {
        virt_text = {
          { "  " .. icon, icon_hl },
          { lang .. " ", "MinimalMdCodeLang" },
        },
        virt_text_pos = "eol",
        priority = 110,
      })
    end
    return
  elseif fence_state and fence_state.inside then
    pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, 0, {
      line_hl_group = "MinimalMdCodeBlock",
      priority = 80,
    })
    return
  end

  local hashes, _ = line:match("^(#+)%s+(.*)$")
  if hashes and #hashes <= 6 then
    local lvl = #hashes
    local hl_name = "MinimalMdH" .. lvl
    if lvl == 1 then
      pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, 0, {
        line_hl_group = "MinimalMdH1Bg",
        priority = 75,
      })
    elseif lvl == 2 then
      pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, 0, {
        line_hl_group = "MinimalMdH2Bg",
        priority = 75,
      })
    end
    pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, 0, {
      end_col = #line,
      hl_group = hl_name,
      priority = 120,
    })
    if not is_cur then
      pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, 0, {
        end_col = #hashes + 1,
        conceal = "",
        virt_text = { { md_heading_icons[lvl] or "# ", hl_name } },
        virt_text_pos = "inline",
        priority = 130,
      })
    end
  elseif line:match("^%s*([%-%*_])%s*%1%s*%1[%s%-%*_]*$") then
    if not is_cur then
      pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, 0, {
        end_col = #line,
        conceal = "",
        virt_text = { { string.rep("─", 56), "MinimalMdRule" } },
        virt_text_pos = "inline",
        priority = 110,
      })
    else
      pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, 0, {
        end_col = #line,
        hl_group = "MinimalMdRule",
        priority = 110,
      })
    end
  else
    local bindent, _, bstate, brest = line:match("^(%s*)([%-%*%+])%s+%[([ xX%-])%]%s*(.*)$")
    if bindent then
      local box_start = #bindent
      local box_end = #bindent + 5
      local done = (bstate == "x" or bstate == "X")
      local icon = done and "󰱒 " or "󰄱 "
      local box_hl = done and "MinimalMdCheckboxDone" or "MinimalMdCheckboxTodo"

      if not is_cur then
        pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, box_start, {
          end_col = math.min(#line, box_end + 1),
          conceal = "",
          virt_text = { { icon, box_hl } },
          virt_text_pos = "inline",
          priority = 130,
        })
      else
        pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, box_start, {
          end_col = math.min(#line, box_end),
          hl_group = box_hl,
          priority = 130,
        })
      end

      if done and brest ~= "" then
        pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, math.min(#line, box_end), {
          end_col = #line,
          hl_group = "MinimalMdDoneText",
          priority = 115,
        })
      end
    else
      local uindent, _ = line:match("^(%s*)([%-%*%+])%s+")
      if uindent then
        local depth = math.min(3, math.floor(#uindent / 2) + 1)
        local glyph = md_bullets[depth] or "•"
        local mcol = #uindent
        if not is_cur then
          pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, mcol, {
            end_col = mcol + 1,
            conceal = "",
            virt_text = { { glyph, "MinimalMdBullet" } },
            virt_text_pos = "inline",
            priority = 125,
          })
        else
          pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, mcol, {
            end_col = mcol + 1,
            hl_group = "MinimalMdBullet",
            priority = 125,
          })
        end
      end
    end

    local qindent, qrest = line:match("^(%s*)>(.*)$")
    if qindent then
      local qcol = #qindent
      local tag = qrest:match("^%s*%[!([A-Z]+)%]")
      local callout = tag and md_callouts[tag] or nil
      local bar_hl = callout and callout.hl or "MinimalMdQuoteBar"
      if not is_cur then
        pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, qcol, {
          end_col = qcol + 1,
          conceal = "",
          virt_text = { { "▎", bar_hl } },
          virt_text_pos = "inline",
          priority = 125,
        })
        if callout then
          local ts, te = line:find("%[![A-Z]+%]")
          if ts and te then
            pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, ts - 1, {
              end_col = te,
              conceal = "",
              virt_text = { { callout.icon, callout.hl } },
              virt_text_pos = "inline",
              priority = 135,
            })
          end
        end
      else
        pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, qcol, {
          end_col = qcol + 1,
          hl_group = bar_hl,
          priority = 125,
        })
      end
    end

    if line:match("^%s*|.*|%s*$") then
      local is_delim = line:match("^%s*|[:%-%s|]+|%s*$") ~= nil
      local is_header = (not is_delim) and ((next_line or ""):match("^%s*|[:%-%s|]+|%s*$") ~= nil)
      if is_delim then
        pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, 0, {
          end_col = #line,
          hl_group = "MinimalMdTableBorder",
          priority = 115,
        })
      else
        if is_header then
          pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, 0, {
            end_col = #line,
            hl_group = "MinimalMdTableHead",
            priority = 110,
          })
        end
        local pos = 1
        while true do
          local p = line:find("|", pos, true)
          if not p then break end
          pcall(vim.api.nvim_buf_set_extmark, buf, md_ns, r, p - 1, {
            end_col = p,
            hl_group = "MinimalMdTableBorder",
            priority = 125,
          })
          pos = p + 1
        end
      end
    end
  end
end

_G.render_markdown_visuals = function(buf, force_full)
  buf = (buf and buf ~= 0) and buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "markdown" then return end

  local line_count = vim.api.nvim_buf_line_count(buf)
  if line_count > 4000 then
    vim.api.nvim_buf_clear_namespace(buf, md_ns, 0, -1)
    return
  end

  local cur_row = -1
  local cur_win = vim.api.nvim_get_current_win()
  if cur_win and vim.api.nvim_win_is_valid(cur_win) and vim.api.nvim_win_get_buf(cur_win) == buf then
    cur_row = vim.api.nvim_win_get_cursor(cur_win)[1]
  end

  local tick = vim.api.nvim_buf_get_changedtick(buf)
  local prev_tick = vim.b[buf]._md_last_tick
  local prev_row = vim.b[buf]._md_last_row
  local fence_map = vim.b[buf]._md_fence_map

  -- Fast O(1) path on pure cursor movement without buffer edits
  if not force_full and prev_tick == tick and type(fence_map) == "table" then
    if prev_row == cur_row then return end
    for _, row_idx in ipairs({ prev_row, cur_row }) do
      if row_idx and row_idx >= 1 and row_idx <= line_count then
        vim.api.nvim_buf_clear_namespace(buf, md_ns, row_idx - 1, row_idx)
        local pair = vim.api.nvim_buf_get_lines(buf, row_idx - 1, math.min(line_count, row_idx + 1), false)
        render_md_line(buf, row_idx, pair[1] or "", pair[2] or "", cur_row, fence_map[row_idx])
      end
    end
    vim.b[buf]._md_last_row = cur_row
    return
  end

  vim.api.nvim_buf_clear_namespace(buf, md_ns, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local in_fence = false
  local fence_char = nil
  local fence_len = 0
  fence_map = {}

  for i, line in ipairs(lines) do
    local _, fseq, info = line:match("^(%s*)(```+)(.*)$")
    if not fseq then
      _, fseq, info = line:match("^(%s*)(~~~+)(.*)$")
    end

    local fstate = nil
    if fseq and not in_fence then
      in_fence = true
      fence_char = fseq:sub(1, 1)
      fence_len = #fseq
      local lang = vim.trim(info or ""):match("^(%S+)")
      fstate = { open = true, lang = lang }
    elseif in_fence then
      fstate = { inside = true }
      local close_pat = "^%s*" .. string.rep(fence_char, fence_len) .. "+%s*$"
      if line:match(close_pat) then
        in_fence = false
        fence_char = nil
        fence_len = 0
      end
    end
    fence_map[i] = fstate
    render_md_line(buf, i, line, lines[i + 1] or "", cur_row, fstate)
  end

  vim.b[buf]._md_last_tick = tick
  vim.b[buf]._md_last_row = cur_row
  vim.b[buf]._md_fence_map = fence_map
end

_G.md_toggle_checkbox = function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  local updated = line
  if line:match("^%s*[%-%*%+]%s+%[ %]") then
    updated = line:gsub("^(%s*[%-%*%+]%s+)%[ %]", "%1[x]", 1)
  elseif line:match("^%s*[%-%*%+]%s+%[[xX]%]") then
    updated = line:gsub("^(%s*[%-%*%+]%s+)%[[xX]%]", "%1[ ]", 1)
  elseif line:match("^%s*[%-%*%+]%s+") then
    updated = line:gsub("^(%s*[%-%*%+]%s+)", "%1[ ] ", 1)
  else
    updated = line:gsub("^(%s*)", "%1- [ ] ", 1)
  end
  if updated ~= line then
    vim.api.nvim_set_current_line(updated)
    _G.render_markdown_visuals(0)
  end
end

_G.md_wrap_text = function(prefix, suffix)
  suffix = suffix or prefix
  local mode = vim.api.nvim_get_mode().mode
  if mode:match("^[vVsS\x16]") then
    -- Wrap active visual/select range cleanly
    local p1 = vim.fn.getpos("v")
    local p2 = vim.fn.getpos(".")
    local r1, c1 = p1[2], p1[3]
    local r2, c2 = p2[2], p2[3]
    if r1 > r2 or (r1 == r2 and c1 > c2) then
      r1, r2 = r2, r1
      c1, c2 = c2, c1
    end
    if r1 == r2 then
      local line = vim.api.nvim_buf_get_lines(0, r1 - 1, r1, false)[1] or ""
      local sel_end = math.min(#line, mode:match("^[sS]") and (c2 - 1) or c2)
      if sel_end >= c1 then
        local selected = line:sub(c1, sel_end)
        local wrapped = prefix .. selected .. suffix
        local new_line = line:sub(1, c1 - 1) .. wrapped .. line:sub(sel_end + 1)
        vim.api.nvim_buf_set_lines(0, r1 - 1, r1, false, { new_line })
        vim.cmd("stopinsert")
        vim.api.nvim_win_set_cursor(0, { r1, c1 - 1 + #wrapped })
        vim.cmd("startinsert")
        return
      end
    end
  end

  -- Wrap or unwrap word under cursor
  local cur = vim.api.nvim_win_get_cursor(0)
  local row, col = cur[1], cur[2]
  local line = vim.api.nvim_get_current_line()
  local s_col = col + 1
  local e_col = col
  while s_col > 1 and not line:sub(s_col - 1, s_col - 1):match("%s") do
    s_col = s_col - 1
  end
  while e_col < #line and not line:sub(e_col + 1, e_col + 1):match("%s") do
    e_col = e_col + 1
  end
  if e_col >= s_col then
    local word = line:sub(s_col, e_col)
    local new_word
    if #word > (#prefix + #suffix) and word:sub(1, #prefix) == prefix and word:sub(-#suffix) == suffix then
      new_word = word:sub(#prefix + 1, #word - #suffix)
    else
      new_word = prefix .. word .. suffix
    end
    local new_line = line:sub(1, s_col - 1) .. new_word .. line:sub(e_col + 1)
    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { row, math.min(#new_line, col + #prefix) })
  else
    local new_line = line:sub(1, col) .. prefix .. suffix .. line:sub(col + 1)
    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { row, col + #prefix })
  end
end

_G.md_smart_enter = function()
  local ok_cmp, cmp = pcall(require, "cmp")
  if ok_cmp and cmp.visible() then
    cmp.confirm({ select = true })
    return
  end
  local cur = vim.api.nvim_win_get_cursor(0)
  local row, col = cur[1], cur[2]
  local line = vim.api.nvim_get_current_line()

  -- Only apply list continuation when cursor is at/near end of list line
  local indent, marker, rest
  indent, marker, rest = line:match("^(%s*)([%-%*%+]%s+%[[ xX%-]%]%s+)(.*)$")
  if indent then
    if vim.trim(rest) == "" then
      vim.api.nvim_set_current_line("")
      vim.api.nvim_win_set_cursor(0, { row, 0 })
      return
    elseif col >= #line - 1 then
      local next_prefix = indent .. marker:gsub("%[[xX%-]%]", "[ ]")
      local before = line:sub(1, col)
      local after = line:sub(col + 1)
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { before, next_prefix .. after })
      vim.api.nvim_win_set_cursor(0, { row + 1, #next_prefix })
      return
    end
  end

  indent, marker, rest = line:match("^(%s*)([%-%*%+]%s+)(.*)$")
  if indent then
    if vim.trim(rest) == "" then
      vim.api.nvim_set_current_line("")
      vim.api.nvim_win_set_cursor(0, { row, 0 })
      return
    elseif col >= #line - 1 then
      local next_prefix = indent .. marker
      local before = line:sub(1, col)
      local after = line:sub(col + 1)
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { before, next_prefix .. after })
      vim.api.nvim_win_set_cursor(0, { row + 1, #next_prefix })
      return
    end
  end

  local num_indent, num_str, num_sep, num_rest = line:match("^(%s*)(%d+)([%.%)])%s+(.*)$")
  if num_indent then
    if vim.trim(num_rest) == "" then
      vim.api.nvim_set_current_line("")
      vim.api.nvim_win_set_cursor(0, { row, 0 })
      return
    elseif col >= #line - 1 then
      local next_num = (tonumber(num_str) or 1) + 1
      local next_prefix = num_indent .. tostring(next_num) .. num_sep .. " "
      local before = line:sub(1, col)
      local after = line:sub(col + 1)
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { before, next_prefix .. after })
      vim.api.nvim_win_set_cursor(0, { row + 1, #next_prefix })
      return
    end
  end

  -- Default newline
  local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
  vim.api.nvim_feedkeys(cr, "n", false)
end

_G.md_open_link = function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local target = nil

  -- Find [label](target) enclosing cursor first, or first on line
  local pos = 1
  while true do
    local s, e, dest = line:find("%b[]%(([^)%s]+)%)", pos)
    if not s then break end
    if not target or (col >= s and col <= e) then
      target = dest
      if col >= s and col <= e then break end
    end
    pos = e + 1
  end

  if not target then
    target = line:match("https?://[^%s%)%>\"']+")
  end

  if not target then
    vim.notify("No Markdown link found on current line", vim.log.levels.INFO)
    return
  end

  if target:match("^https?://") then
    vim.fn.jobstart({ "xdg-open", target }, { detach = true })
    vim.notify("Opening URL: " .. target, vim.log.levels.INFO)
    return
  end

  -- Local file link (with optional #heading anchor)
  local fpath, anchor = target:match("^([^#]+)#?(.*)$")
  if fpath == "" and anchor ~= "" then
    -- Same-file heading jump (#section)
    local slug = anchor:lower():gsub("[^%w%-%s]", ""):gsub("%s+", "-")
    for idx, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
      local h = l:match("^#+%s+(.*)$")
      if h then
        local hsl = h:lower():gsub("[^%w%-%s]", ""):gsub("%s+", "-")
        if hsl == slug then
          vim.api.nvim_win_set_cursor(0, { idx, 0 })
          vim.cmd("normal! zz")
          return
        end
      end
    end
    return
  end

  local cur_dir = vim.fn.expand("%:p:h")
  local resolved = fpath:match("^/") and fpath or (cur_dir .. "/" .. fpath)
  if vim.fn.filereadable(resolved) == 1 then
    vim.cmd("silent! edit " .. vim.fn.fnameescape(resolved))
    if anchor and anchor ~= "" then
      local slug = anchor:lower():gsub("[^%w%-%s]", ""):gsub("%s+", "-")
      for idx, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
        local h = l:match("^#+%s+(.*)$")
        if h and h:lower():gsub("[^%w%-%s]", ""):gsub("%s+", "-") == slug then
          vim.api.nvim_win_set_cursor(0, { idx, 0 })
          break
        end
      end
    end
    vim.cmd("startinsert")
  else
    vim.notify("Linked file not found: " .. resolved, vim.log.levels.WARN)
  end
end

_G.md_align_tables = function()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local changed = false
  local i = 1
  while i <= #lines do
    if lines[i]:match("^%s*|.*|%s*$") then
      local j = i
      while j <= #lines and lines[j]:match("^%s*|.*|%s*$") do
        j = j + 1
      end
      j = j - 1
      if j > i then
        local rows = {}
        local col_widths = {}
        for k = i, j do
          local cells = {}
          local raw = lines[k]:gsub("^%s*|", ""):gsub("|%s*$", "")
          for cell in (raw .. "|"):gmatch("([^|]*)|") do
            local trimmed = vim.trim(cell)
            table.insert(cells, trimmed)
            local idx = #cells
            local w = vim.fn.strdisplaywidth(trimmed)
            if not col_widths[idx] or w > col_widths[idx] then
              col_widths[idx] = math.max(3, w)
            end
          end
          table.insert(rows, { cells = cells, is_delim = (lines[k]:match("^%s*|[:%-%s|]+|%s*$") ~= nil) })
        end
        for offset, row_data in ipairs(rows) do
          local out_parts = {}
          for cidx = 1, #col_widths do
            local val = row_data.cells[cidx] or ""
            local w = col_widths[cidx]
            if row_data.is_delim then
              local left_c = val:match("^:") and ":" or ""
              local right_c = val:match(":$") and ":" or ""
              local dash_n = math.max(1, w - #left_c - #right_c)
              table.insert(out_parts, " " .. left_c .. string.rep("-", dash_n) .. right_c .. " ")
            else
              local cur_w = vim.fn.strdisplaywidth(val)
              table.insert(out_parts, " " .. val .. string.rep(" ", math.max(0, w - cur_w)) .. " ")
            end
          end
          local aligned = "|" .. table.concat(out_parts, "|") .. "|"
          if aligned ~= lines[i + offset - 1] then
            lines[i + offset - 1] = aligned
            changed = true
          end
        end
      end
      i = j + 1
    else
      i = i + 1
    end
  end
  if changed then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    _G.render_markdown_visuals(buf)
    vim.notify("Markdown tables aligned", vim.log.levels.INFO)
  end
end

_G.open_markdown_outline = function()
  local src_buf = vim.api.nvim_get_current_buf()
  local src_win = vim.api.nvim_get_current_win()
  if vim.bo[src_buf].filetype ~= "markdown" then
    vim.notify("Outline is available for Markdown (.md) files", vim.log.levels.INFO)
    return
  end

  local headings = {}
  local in_fence = false
  local fchar, flen = nil, 0
  for idx, l in ipairs(vim.api.nvim_buf_get_lines(src_buf, 0, -1, false)) do
    local fseq = l:match("^%s*(```+)") or l:match("^%s*(~~~+)")
    if fseq and not in_fence then
      in_fence = true
      fchar = fseq:sub(1, 1)
      flen = #fseq
    elseif in_fence then
      if l:match("^%s*" .. string.rep(fchar, flen) .. "+%s*$") then
        in_fence = false
      end
    else
      local hashes, text = l:match("^(#+)%s+(.*)$")
      if hashes and #hashes <= 6 then
        table.insert(headings, {
          level = #hashes,
          text = vim.trim(text),
          line = idx,
        })
      end
    end
  end

  if #headings == 0 then
    vim.notify("No headings found in this Markdown file", vim.log.levels.INFO)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.b[buf].is_picker = true
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].undolevels = -1

  local ui = vim.api.nvim_list_uis()[1] or { width = 120, height = 40 }
  local width = math.min(68, math.max(46, ui.width - 6))
  local height = math.min(20, math.max(8, #headings + 4))
  local row = math.max(1, math.floor((ui.height - height) / 3))
  local col = math.max(1, math.floor((ui.width - width) / 2))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = string.format(" Markdown Outline (%d) ", #headings),
    title_pos = "center",
  })

  vim.cmd("stopinsert")
  vim.wo[win].cursorline = false
  vim.wo[win].wrap = false
  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

  local function close_outline()
    pcall(vim.api.nvim_win_close, win, true)
    if vim.api.nvim_win_is_valid(src_win) then
      vim.api.nvim_set_current_win(src_win)
      vim.cmd("startinsert")
    end
    _G.clear_active_menu(close_outline)
  end

  _G.register_active_menu(close_outline, win)
  _G.set_picker_cursor("FolderCursorHidden")

  local filtered = {}
  local selected_idx = 1
  local ns_id = vim.api.nvim_create_namespace("md_outline_hl")
  local sb = nil

  local function update_hl()
    if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then return end
    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
    pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "FolderPickerSearch", 0, 0, 10)
    pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "FolderPickerSep", 1, 0, -1)

    for i, item in ipairs(filtered) do
      local r = i + 2
      local hl = "MinimalMdH" .. math.min(6, item.level)
      pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, hl, r, 0, -1)
    end

    if #filtered > 0 then
      if selected_idx > #filtered then selected_idx = #filtered end
      if selected_idx < 1 then selected_idx = 1 end
      local target_line = 3 + selected_idx
      pcall(vim.api.nvim_buf_set_extmark, buf, ns_id, target_line - 1, 0, {
        line_hl_group = "FolderPickerSelected",
        priority = 200,
      })
      pcall(vim.api.nvim_win_set_cursor, win, { target_line, 0 })
    end
  end

  local function render()
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local query = sb and vim.trim(sb.get_text()):lower() or ""
    filtered = {}
    for _, h in ipairs(headings) do
      if query == "" or h.text:lower():find(query, 1, true) then
        table.insert(filtered, h)
      end
    end

    local search_line = sb and sb.get_display_line("  Search: ", "(filter headings...)") or "  Search: ▏ (filter headings...)"
    local sep_line = "  " .. string.rep("─", math.max(10, width - 4))
    local lines = { search_line, sep_line, "" }

    if #filtered == 0 then
      table.insert(lines, "   No matching headings")
    else
      for _, h in ipairs(filtered) do
        local indent = string.rep("  ", h.level - 1)
        local tag = md_heading_icons[h.level] or "#"
        table.insert(lines, string.format("   %s%s %s  (:%d)", indent, tag, h.text, h.line))
      end
    end

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    update_hl()
  end

  sb = make_searchbar("", function()
    selected_idx = 1
    render()
  end)
  bind_searchbar_keys(buf, sb)

  local function jump_selected()
    local item = filtered[selected_idx]
    close_outline()
    if item and vim.api.nvim_win_is_valid(src_win) then
      pcall(vim.api.nvim_win_set_cursor, src_win, { item.line, 0 })
      vim.cmd("normal! zz")
      vim.cmd("startinsert")
    end
  end

  local function move_up()
    if #filtered == 0 then return end
    selected_idx = selected_idx - 1
    if selected_idx < 1 then selected_idx = #filtered end
    update_hl()
  end

  local function move_down()
    if #filtered == 0 then return end
    selected_idx = selected_idx + 1
    if selected_idx > #filtered then selected_idx = 1 end
    update_hl()
  end

  vim.keymap.set({ "n", "i", "s", "v" }, "<Up>", move_up, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-p>", move_up, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<Down>", move_down, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-n>", move_down, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<CR>", jump_selected, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<Esc>", close_outline, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-c>", close_outline, { buffer = buf, nowait = true })
  vim.api.nvim_create_autocmd("WinLeave", { buffer = buf, once = true, callback = close_outline })

  render()
end

_G.preview_markdown = function()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype ~= "markdown" then
    vim.notify("Preview is available for Markdown (.md) files", vim.log.levels.INFO)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local title = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
  if title == "" then title = "Minimal Markdown Preview" end

  local function esc_html(s)
    return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
  end

  local function render_inline(s)
    s = esc_html(s)
    s = s:gsub("!%[([^%]]*)%]%(([^%)]+)%)", '<img alt="%1" src="%2" />')
    s = s:gsub("%[([^%]]+)%]%(([^%)]+)%)", '<a href="%2">%1</a>')
    s = s:gsub("`([^`]+)`", "<code>%1</code>")
    s = s:gsub("%*%*([^%*]+)%*%*", "<strong>%1</strong>")
    s = s:gsub("__([^_]+)__", "<strong>%1</strong>")
    s = s:gsub("%*([^%*]+)%*", "<em>%1</em>")
    s = s:gsub("~~([^~]+)~~", "<del>%1</del>")
    return s
  end

  local html = {}
  local in_code = false
  local in_ul = false
  local in_quote = false

  local function close_blocks()
    if in_ul then table.insert(html, "</ul>"); in_ul = false end
    if in_quote then table.insert(html, "</blockquote>"); in_quote = false end
  end

  local i = 1
  while i <= #lines do
    local l = lines[i]
    local fseq, info = l:match("^%s*(```+)(.*)$")
    if fseq and not in_code then
      close_blocks()
      in_code = true
      local lang = vim.trim(info or "")
      table.insert(html, '<pre><code class="language-' .. esc_html(lang) .. '">')
    elseif in_code and l:match("^%s*```+%s*$") then
      in_code = false
      table.insert(html, "</code></pre>")
    elseif in_code then
      table.insert(html, esc_html(l) .. "\n")
    elseif l:match("^%s*([%-%*_])%s*%1%s*%1[%s%-%*_]*$") then
      close_blocks()
      table.insert(html, "<hr />")
    elseif l:match("^(#+)%s+(.+)$") then
      close_blocks()
      local h, txt = l:match("^(#+)%s+(.+)$")
      local lvl = math.min(6, #h)
      table.insert(html, string.format("<h%d>%s</h%d>", lvl, render_inline(txt), lvl))
    elseif l:match("^%s*|.*|%s*$") then
      close_blocks()
      table.insert(html, "<table>")
      local is_header = true
      while i <= #lines and lines[i]:match("^%s*|.*|%s*$") do
        local row_l = lines[i]
        if row_l:match("^%s*|[:%-%s|]+|%s*$") then
          is_header = false
        else
          local tag = is_header and "th" or "td"
          table.insert(html, "<tr>")
          local raw = row_l:gsub("^%s*|", ""):gsub("|%s*$", "")
          for cell in (raw .. "|"):gmatch("([^|]*)|") do
            table.insert(html, "<" .. tag .. ">" .. render_inline(vim.trim(cell)) .. "</" .. tag .. ">")
          end
          table.insert(html, "</tr>")
          if is_header and not (lines[i + 1] or ""):match("^%s*|[:%-%s|]+|%s*$") then
            is_header = false
          end
        end
        i = i + 1
      end
      table.insert(html, "</table>")
      i = i - 1
    elseif l:match("^%s*>%s?(.*)$") then
      if in_ul then table.insert(html, "</ul>"); in_ul = false end
      if not in_quote then table.insert(html, "<blockquote>"); in_quote = true end
      local qtxt = l:match("^%s*>%s?(.*)$")
      table.insert(html, "<p>" .. render_inline(qtxt) .. "</p>")
    elseif l:match("^%s*[%-%*%+]%s+%[([ xX%-])%]%s*(.*)$") then
      if in_quote then table.insert(html, "</blockquote>"); in_quote = false end
      if not in_ul then table.insert(html, '<ul class="task-list">'); in_ul = true end
      local st, txt = l:match("^%s*[%-%*%+]%s+%[([ xX%-])%]%s*(.*)$")
      local chk = (st == "x" or st == "X") and ' checked disabled' or ' disabled'
      table.insert(html, '<li class="task"><input type="checkbox"' .. chk .. ' /> ' .. render_inline(txt) .. "</li>")
    elseif l:match("^%s*[%-%*%+]%s+(.*)$") then
      if in_quote then table.insert(html, "</blockquote>"); in_quote = false end
      if not in_ul then table.insert(html, "<ul>"); in_ul = true end
      local txt = l:match("^%s*[%-%*%+]%s+(.*)$")
      table.insert(html, "<li>" .. render_inline(txt) .. "</li>")
    elseif vim.trim(l) == "" then
      close_blocks()
    else
      close_blocks()
      table.insert(html, "<p>" .. render_inline(l) .. "</p>")
    end
    i = i + 1
  end
  close_blocks()
  if in_code then table.insert(html, "</code></pre>") end

  local out_path = "/tmp/minimal_md_preview.html"
  local full_html = string.format([[<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>%s</title>
<style>
  body { background: #0e1017; color: #dce3ec; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; line-height: 1.7; max-width: 860px; margin: 40px auto; padding: 0 24px; }
  h1, h2, h3, h4 { margin-top: 1.6em; margin-bottom: 0.6em; font-weight: 700; }
  h1 { color: #61afef; border-bottom: 1px solid #242a38; padding-bottom: 0.3em; }
  h2 { color: #98c379; border-bottom: 1px solid #1e2330; padding-bottom: 0.25em; }
  h3 { color: #e5c07b; }
  h4 { color: #cba6f7; }
  a { color: #61afef; text-decoration: none; }
  a:hover { text-decoration: underline; }
  code { background: #1a1f2b; color: #f38ba8; padding: 0.15em 0.4em; border-radius: 5px; font-family: "JetBrainsMono Nerd Font", monospace; font-size: 0.92em; }
  pre { background: #131722; border: 1px solid #232938; border-radius: 8px; padding: 14px 16px; overflow-x: auto; }
  pre code { background: none; color: #dce3ec; padding: 0; }
  blockquote { border-left: 4px solid #61afef; background: #141925; margin: 1em 0; padding: 0.6em 1em; color: #9aa5b8; border-radius: 0 6px 6px 0; }
  table { border-collapse: collapse; width: 100%%; margin: 1.2em 0; }
  th, td { border: 1px solid #2a3142; padding: 8px 12px; text-align: left; }
  th { background: #191e2b; color: #e5c07b; }
  hr { border: none; border-top: 1px solid #293040; margin: 2em 0; }
  ul.task-list { list-style: none; padding-left: 0.6em; }
  img { max-width: 100%%; border-radius: 8px; }
</style>
</head>
<body>
%s
</body>
</html>]], esc_html(title), table.concat(html, "\n"))

  local fh = io.open(out_path, "w")
  if fh then
    fh:write(full_html)
    fh:close()
    vim.fn.jobstart({ "xdg-open", out_path }, { detach = true })
    vim.notify("Opened Markdown preview in browser", vim.log.levels.INFO)
  end
end

vim.api.nvim_create_user_command("MdOutline", function() _G.open_markdown_outline() end, {})
vim.api.nvim_create_user_command("MdPreview", function() _G.preview_markdown() end, {})
vim.api.nvim_create_user_command("MdToggleCheckbox", function() _G.md_toggle_checkbox() end, {})
vim.api.nvim_create_user_command("MdTableAlign", function() _G.md_align_tables() end, {})

_G.apply_markdown_highlights()

_G.setup_markdown_buffer = function(b)
  if not b or not vim.api.nvim_buf_is_valid(b) or vim.bo[b].filetype ~= "markdown" then return end
  vim.bo[b].tabstop = 2
  vim.bo[b].shiftwidth = 2
  vim.bo[b].expandtab = true

  local cur_win = vim.api.nvim_get_current_win()
  if cur_win and vim.api.nvim_win_is_valid(cur_win) and vim.api.nvim_win_get_buf(cur_win) == b then
    vim.wo[cur_win].wrap = true
    vim.wo[cur_win].linebreak = true
    vim.wo[cur_win].spell = true
    vim.bo[b].spellcapcheck = ""
    vim.wo[cur_win].conceallevel = 2
    vim.wo[cur_win].concealcursor = ""
  end

  if not vim.b[b].minimal_md_keys_set then
    vim.b[b].minimal_md_keys_set = true
    vim.keymap.set({ "i", "n", "v", "s" }, "<M-x>", _G.md_toggle_checkbox, { buffer = b, silent = true, desc = "Toggle Checkbox" })
    vim.keymap.set({ "i", "n", "v", "s" }, "<M-b>", function() _G.md_wrap_text("**", "**") end, { buffer = b, silent = true, desc = "Bold Markdown" })
    vim.keymap.set({ "i", "n", "v", "s" }, "<M-i>", function() _G.md_wrap_text("*", "*") end, { buffer = b, silent = true, desc = "Italic Markdown" })
    vim.keymap.set({ "i", "n", "v", "s" }, "<M-e>", function() _G.md_wrap_text("`", "`") end, { buffer = b, silent = true, desc = "Inline Code Markdown" })
    vim.keymap.set({ "i", "n", "v", "s" }, "<M-l>", function() _G.md_wrap_text("[", "](url)") end, { buffer = b, silent = true, desc = "Insert Link Markdown" })
    vim.keymap.set({ "i", "n", "v", "s" }, "<M-m>", _G.open_markdown_outline, { buffer = b, silent = true, desc = "Markdown Outline" })
    vim.keymap.set({ "i", "n", "v", "s" }, "<M-p>", _G.preview_markdown, { buffer = b, silent = true, desc = "Markdown Preview" })
    vim.keymap.set({ "i", "n", "v", "s" }, "<M-o>", _G.md_open_link, { buffer = b, silent = true, desc = "Open Link" })
    vim.keymap.set("n", "gx", _G.md_open_link, { buffer = b, silent = true, desc = "Open Markdown Link" })
    vim.keymap.set("i", "<CR>", _G.md_smart_enter, { buffer = b, silent = true, desc = "Smart List Continuation" })
  end

  _G.render_markdown_visuals(b)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    _G.setup_markdown_buffer(args.buf)
  end,
})

for _, existing_buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_valid(existing_buf) and vim.bo[existing_buf].filetype == "markdown" then
    _G.setup_markdown_buffer(existing_buf)
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TextChanged", "TextChangedI", "CursorMoved", "CursorMovedI" }, {
  callback = function(args)
    local b = args.buf
    if vim.api.nvim_buf_is_valid(b) and vim.bo[b].filetype == "markdown" then
      if not vim.b[b].minimal_md_keys_set then
        _G.setup_markdown_buffer(b)
      else
        local win = vim.api.nvim_get_current_win()
        if win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == b then
          vim.wo[win].conceallevel = 2
          vim.wo[win].concealcursor = ""
        end
        _G.render_markdown_visuals(b)
      end
    end
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    _G.apply_markdown_highlights()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) then
        local b = vim.api.nvim_win_get_buf(win)
        if vim.bo[b].filetype == "markdown" then
          _G.render_markdown_visuals(b, true)
        end
      end
    end
  end,
})

-- 21. Neovide-Specific Visuals (Only applies inside Neovide window)
if vim.g.neovide then
  -- Apply persisted font, size, boldness and line-spacing on startup
  FontEngine.apply_config(FontEngine.get_config())

  -- Smooth cursor flow
  vim.g.neovide_cursor_animation_length = 0.08
  vim.g.neovide_cursor_trail_size = 0.7
  vim.g.neovide_cursor_vfx_mode = ""

  -- Smooth scrolling
  vim.g.neovide_scroll_animation_length = 0.12

  -- Window padding & Frosted glass opacity (frosted transparency showing blurred wallpaper)
  vim.g.neovide_opacity = 0.78
  vim.g.neovide_padding_top = 10
  vim.g.neovide_padding_bottom = 10
  vim.g.neovide_padding_left = 12
  vim.g.neovide_padding_right = 12

  -- Remember window position
  vim.g.neovide_remember_window_size = true
end
