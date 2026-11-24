-- =============================================================================
-- Minimal Code Editor - The Fluent, Modeless Code Editor for Linux
-- Crafted by indiedev
-- =============================================================================

-- Ensure both standalone minimal and standard nvim packpaths are recognized for plugins
local minimal_site = vim.fn.expand("~/.local/share/minimal/site")
if vim.fn.isdirectory(minimal_site) == 1 and not vim.tbl_contains(vim.opt.packpath:get(), minimal_site) then
  vim.opt.packpath:prepend(minimal_site)
end
local nvim_site = vim.fn.expand("~/.local/share/nvim/site")
if vim.fn.isdirectory(nvim_site) == 1 and not vim.tbl_contains(vim.opt.packpath:get(), nvim_site) then
  vim.opt.packpath:append(nvim_site)
end

-- Silence deprecation warning for vim.tbl_flatten across all plugins
if vim.iter then
  vim.tbl_flatten = function(t)
    return vim.iter(t):flatten(math.huge):totable()
  end
end

-- Disable default netrw file browser (nvim-tree replaces it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 1. General Editor Behavior & Layout
vim.opt.shell = "/bin/bash"              -- Force standard Bash shell instead of parent terminal shell (e.g. Zsh/Kitty)
vim.opt.mouse = "a"                      -- Full mouse support (click, drag to select)
vim.opt.clipboard = "unnamedplus"        -- System clipboard integration
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

-- Code Spell Checker (VS Code style with camelCase identifier support)
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }
pcall(function() vim.opt.spelloptions:append("camel") end)
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
vim.api.nvim_set_hl(0, "SpellBad", { undercurl = true, sp = "#f38ba8" })
vim.api.nvim_set_hl(0, "SpellCap", { undercurl = true, sp = "#fab387" })
vim.api.nvim_set_hl(0, "SpellLocal", { undercurl = true, sp = "#61afef" })
vim.api.nvim_set_hl(0, "SpellRare", { undercurl = true, sp = "#cba6f7" })
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
vim.opt.timeoutlen = 1000                -- Comfortable chord timeout for Ctrl+K chords (VS Code style)
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

-- 2. Windows / Notepad-style Selection & Modeless Rules
vim.opt.keymodel = "startsel,stopsel"    -- Shift keys start selection, non-shift stops
vim.opt.selection = "exclusive"          -- Selection ends before cursor col (Notepad standard)
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
    vim.cmd("stopinsert")
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

-- 4. Syntax Highlighting & Full Dev Stack Language Support
vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")

vim.filetype.add({
  extension = {
    redis = "conf",
    env = "sh",
    conf = "conf",
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
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- Visual Color Highlighting & Color Decorators (VS Code style)
local ok_colorizer, colorizer = pcall(require, "colorizer")
if ok_colorizer then
  colorizer.setup({
    "*",
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

-- Visual Interactive Color Picker (VS Code style color-picker.nvim)
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

_G.open_color_picker = function()
  if _G.register_active_menu then
    _G.register_active_menu()
  end
  vim.cmd("stopinsert")
  local ok = pcall(vim.cmd, "PickColorInsert")
  if not ok then
    pcall(vim.cmd, "PickColor")
  end
end

-- 5. Colorful Rainbow Indentations & Colored Filled Space
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
      remove_blankline_trail = false, -- Colored fill across indented space
    },
    scope = {
      enabled = true,
      show_start = false,
      show_end = false,
    },
  })
end

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

-- 7. Auto-Closing Quotes and Brackets (nvim-autopairs)
local ok_autopairs, autopairs = pcall(require, "nvim-autopairs")
if ok_autopairs then
  autopairs.setup({
    check_ts = false,
    enable_check_bracket_line = false,
    fast_wrap = {},
  })
end

-- 8. Snippets (LuaSnip + VS Code Friendly-Snippets)
local ok_luasnip, luasnip = pcall(require, "luasnip")
if ok_luasnip then
  luasnip.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
    enable_autosnippets = true,
  })
  pcall(function()
    local fs_path = vim.fn.stdpath("data") .. "/site/pack/plugins/start/friendly-snippets"
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
end

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

-- 10. Native LSP Setup (Auto-Imports & Diagnostics for all Languages)
local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp_lsp then
  lsp_capabilities = cmp_nvim_lsp.default_capabilities(lsp_capabilities)
end
lsp_capabilities.workspace = lsp_capabilities.workspace or {}
lsp_capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = true }

-- Configure language servers
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

pcall(vim.lsp.enable, {
  "pyright",
  "ts_ls",
  "gopls",
  "clangd",
  "bashls",
  "dockerls",
  "jsonls",
  "html",
  "cssls",
  "svelte",
  "tailwindcss",
})

-- 11. Auto-Completions, Path Intellisense & Normal Text Suggestions (nvim-cmp)
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

  -- 10. Cross-File Classes & HTML/CSS IntelliSense Source
  local cross_file_source = {}
  function cross_file_source:new()
    return setmetatable({}, { __index = cross_file_source })
  end
  function cross_file_source:get_trigger_characters()
    return { ".", "-", "_", '"', "'", " " }
  end
  function cross_file_source:complete(params, callback)
    local items = {}
    local seen = {}

    local function scan_text(text, source_type)
      if not text or text == "" then return end
      -- HTML class="..." and JSX className="..."
      for cls in text:gmatch('class%s*=%s*["\']([^"\']+)["\']') do
        for word in cls:gmatch("[%w%-_]+") do
          if not seen[word] and #word > 1 then
            seen[word] = true
            table.insert(items, { label = word, kind = cmp.lsp.CompletionItemKind.Class, detail = source_type or "HTML Class" })
          end
        end
      end
      for cls in text:gmatch('className%s*=%s*["\']([^"\']+)["\']') do
        for word in cls:gmatch("[%w%-_]+") do
          if not seen[word] and #word > 1 then
            seen[word] = true
            table.insert(items, { label = word, kind = cmp.lsp.CompletionItemKind.Class, detail = "React/JSX Class" })
          end
        end
      end
      -- CSS .class-name
      for cls in text:gmatch('%.([%a_][%w%-_]*)') do
        if not seen[cls] and #cls > 1 then
          seen[cls] = true
          table.insert(items, { label = cls, kind = cmp.lsp.CompletionItemKind.Class, detail = "CSS Class" })
        end
      end
    end

    -- 1. Scan loaded buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) then
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        scan_text(table.concat(lines, "\n"), "Buffer Class")
      end
    end

    -- 2. Scan workspace files (*.html, *.css, *.jsx, *.tsx, *.svelte, *.vue)
    pcall(function()
      local cwd = vim.fn.getcwd()
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
            scan_text(content, ext:upper() .. " Class")
          end
        end
      end
    end)

    callback({ items = items, isIncomplete = false })
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
      completeopt = "menu,menuone,noinsert",
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
      ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
      ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
      ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
      ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
      ["<CR>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.confirm({ select = true })
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
      { name = "cross_file_classes", priority = 750, keyword_length = 2 },
      {
        name = "buffer",
        priority = 600,
        keyword_length = 2,
        option = {
          get_bufnrs = function()
            return vim.api.nvim_list_bufs()
          end,
        },
      },
      { name = "nvim_lua", priority = 200 },
    }),
  })

  -- Automatically insert () when confirming function/method completion
  if ok_autopairs then
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end
end

-- 12. Prettier, Auto-Imports & Multi-Language Formatter (conform.nvim)
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
      python = { "ruff_organize_imports", "ruff_format" }, -- Auto-imports and formats Python
      go = { "goimports", "gofmt" },                        -- Auto-imports and formats Go
      c = { "clang-format" },
      cpp = { "clang-format" },
      rust = { "rustfmt" },
      sql = { "sql_formatter" },                            -- Formats SQL / Postgres
      sh = { "shfmt" },
      bash = { "shfmt" },
    },
    default_format_opts = {
      lsp_format = "fallback",
    },
  })
end

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

-- 15. Code Editor Sidebar with Git Activity & Diagnostic Badges (nvim-tree)
local ok_devicons, devicons = pcall(require, "nvim-web-devicons")
if ok_devicons then
  devicons.setup({
    default = true,
    color_icons = true,
    override = {
      py = { icon = "󰌠", color = "#ffd43b", name = "Py" },
      python = { icon = "󰌠", color = "#ffd43b", name = "Python" },
      md = { icon = "󰂺", color = "#519aba", name = "Md" },
      markdown = { icon = "󰂺", color = "#519aba", name = "Markdown" },
      txt = { icon = "󰈙", color = "#89e051", name = "Txt" },
      sh = { icon = "", color = "#4ebd54", name = "Sh" },
      bash = { icon = "", color = "#4ebd54", name = "Bash" },
      zsh = { icon = "", color = "#4ebd54", name = "Zsh" },
      conf = { icon = "", color = "#e5c07b", name = "Conf" },
      cfg = { icon = "", color = "#e5c07b", name = "Cfg" },
      ini = { icon = "", color = "#e5c07b", name = "Ini" },
      toml = { icon = "", color = "#9c8675", name = "Toml" },
      yaml = { icon = "", color = "#e5c07b", name = "Yaml" },
      yml = { icon = "", color = "#e5c07b", name = "Yml" },
      json = { icon = "", color = "#cbcb41", name = "Json" },
      lua = { icon = "", color = "#51a0cf", name = "Lua" },
      js = { icon = "", color = "#cbcb41", name = "Js" },
      ts = { icon = "", color = "#519aba", name = "Ts" },
      jsx = { icon = "", color = "#519aba", name = "Jsx" },
      tsx = { icon = "", color = "#1354bf", name = "Tsx" },
      html = { icon = "", color = "#e34c26", name = "Html" },
      css = { icon = "", color = "#563d7c", name = "Css" },
      log = { icon = "󰌱", color = "#fab387", name = "Log" },
      csv = { icon = "󰈙", color = "#a6e3a1", name = "Csv" },
      c = { icon = "", color = "#599eff", name = "C" },
      cpp = { icon = "", color = "#599eff", name = "Cpp" },
      h = { icon = "", color = "#a074c4", name = "H" },
      hpp = { icon = "", color = "#a074c4", name = "Hpp" },
      rs = { icon = "󱘗", color = "#dea584", name = "Rs" },
      go = { icon = "", color = "#00add8", name = "Go" },
      sql = { icon = "", color = "#dad8d8", name = "Sql" },
      makefile = { icon = "", color = "#fab387", name = "Makefile" },
      dockerfile = { icon = "󰡨", color = "#458ee6", name = "Dockerfile" },
    },
    override_by_filename = {
      ["main.py"] = { icon = "󰌠", color = "#ffd43b", name = "Py" },
      ["menu.py"] = { icon = "󰌠", color = "#ffd43b", name = "Py" },
      ["README.md"] = { icon = "󰂺", color = "#519aba", name = "Readme" },
      ["readme.md"] = { icon = "󰂺", color = "#519aba", name = "Readme" },
      ["README"] = { icon = "󰂺", color = "#519aba", name = "Readme" },
      ["readme"] = { icon = "󰂺", color = "#519aba", name = "Readme" },
      ["Makefile"] = { icon = "", color = "#fab387", name = "Makefile" },
      ["makefile"] = { icon = "", color = "#fab387", name = "Makefile" },
      ["Dockerfile"] = { icon = "󰡨", color = "#458ee6", name = "Dockerfile" },
      ["dockerfile"] = { icon = "󰡨", color = "#458ee6", name = "Dockerfile" },
      ["docker-compose.yml"] = { icon = "󰡨", color = "#458ee6", name = "DockerCompose" },
      ["docker-compose.yaml"] = { icon = "󰡨", color = "#458ee6", name = "DockerCompose" },
      ["package.json"] = { icon = "", color = "#e8274b", name = "PackageJson" },
      ["CMakeLists.txt"] = { icon = "", color = "#064f8c", name = "CMakeLists" },
      ["LICENSE"] = { icon = "󰈙", color = "#d0bf41", name = "License" },
      ["license"] = { icon = "󰈙", color = "#d0bf41", name = "License" },
    },
    default_icon = { icon = "󰈙", color = "#61afef", name = "Default" },
  })
  pcall(devicons.set_default_icon, "󰈙", "#61afef", 75)
end

_G.reapply_all_icon_colors = function()
  local ok_dev, dev = pcall(require, "nvim-web-devicons")
  if ok_dev then
    pcall(dev.set_up_highlights, true)
    pcall(dev.set_default_icon, "󰈙", "#61afef", 75)
  end
  local ok_bl, bl_h = pcall(require, "bufferline.highlights")
  if ok_bl then
    pcall(bl_h.reset_icon_hl_cache)
  end
  vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = "#e5c07b", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeClosedFolderIcon", { fg = "#e5c07b", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderIcon", { fg = "#e5c07b", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeFileIcon", { fg = "#61afef" })
  vim.api.nvim_set_hl(0, "DevIconDefault", { fg = "#61afef" })

  local ok_tree, t_api = pcall(require, "nvim-tree.api")
  if ok_tree and t_api.tree.is_visible() then
    pcall(t_api.tree.reload)
  end
  pcall(vim.cmd, "redrawtabline")
end

local ok_tree, tree = pcall(require, "nvim-tree")
if ok_tree then
  local api = require("nvim-tree.api")

  local function notify_lsp_file_deleted(filepath)
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
                    if ob_ft ~= "NvimTree" and ob_bt ~= "terminal" then
                      other_buf = ob.bufnr
                      break
                    end
                  end
                end
                if other_buf then
                  vim.api.nvim_win_set_buf(w, other_buf)
                else
                  local new_empty = vim.api.nvim_create_buf(true, false)
                  vim.api.nvim_win_set_buf(w, new_empty)
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
      width = 24,
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
      indent_width = 2,
      indent_markers = {
        enable = true,
        inline_arrows = true,
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
            enable = true,
            color = true,
          },
        },
        padding = " ",
        symlink_arrow = " 󰁔 ",
        show = {
          file = true,
          folder = true,
          folder_arrow = true,
          git = true,
          modified = true,
          diagnostics = true,
        },
        glyphs = {
          default = "",
          symlink = "",
          bookmark = "󰆤",
          modified = "●",
          folder = {
            arrow_closed = "",
            arrow_open = "",
            default = "",
            open = "",
            empty = "",
            empty_open = "",
            symlink = "",
            symlink_open = "",
          },
          git = {
            unstaged = "󰜥",
            staged = "󰄬",
            unmerged = "",
            renamed = "󰁔",
            untracked = "󰄱",
            deleted = "󰅖",
            ignored = "󰅚",
          },
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
      api.tree.open({ focus = false, find_file = true })
      if cur_win and vim.api.nvim_win_is_valid(cur_win) then
        vim.api.nvim_set_current_win(cur_win)
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
      local ed = find_editor_win()
      if ed and vim.api.nvim_win_is_valid(ed) then
        vim.api.nvim_set_current_win(ed)
        local cur_buf = vim.api.nvim_get_current_buf()
        if vim.fn.argc() > 0 and not vim.b[cur_buf].is_renaming and not vim.b[cur_buf].is_picker and vim.bo[cur_buf].buftype == "" then
          vim.cmd("startinsert")
        end
      end
    end)
  end

  vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_sidebar_on_startup })

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
        vim.api.nvim_set_current_buf(bufnr)
        vim.cmd("startinsert")
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
        local ok_d, d = pcall(require, "nvim-web-devicons")
        if not ok_d then return end
        local fname = vim.fn.fnamemodify(element.path, ":t")
        local ext = vim.fn.fnamemodify(element.path, ":e")
        local icon, hl
        if fname ~= "" then
          icon, hl = d.get_icon(fname, ext, { default = false })
        end
        if not icon and element.filetype and element.filetype ~= "" then
          icon, hl = d.get_icon_by_filetype(element.filetype, { default = false })
        end
        if not icon then
          icon, hl = d.get_icon(fname, ext, { default = true })
        end
        if not hl or hl == "" then
          hl = "DevIconDefault"
        end
        return icon, hl
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
  vim.api.nvim_set_current_buf(bufs[next_idx])
  vim.cmd("startinsert")
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
  vim.api.nvim_set_current_buf(bufs[prev_idx])
  vim.cmd("startinsert")
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
    if vim.bo[args.buf].buftype == "terminal" then
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
      vim.api.nvim_win_hide(term_win)
      term_win = nil
      local ed = find_editor_win()
      if ed then
        vim.api.nvim_set_current_win(ed)
        vim.cmd("startinsert")
      end
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

    vim.cmd.edit(vim.fn.fnameescape(file_path))
    vim.cmd("startinsert")

    local ok_t, t_api = pcall(require, "nvim-tree.api")
    if ok_t and t_api.tree.is_visible() then
      pcall(t_api.tree.find_file, file_path)
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
      vim.cmd("silent! spellgood " .. vim.fn.fnameescape(action.word))
      vim.notify('Added "' .. action.word .. '" to user dictionary', vim.log.levels.INFO)
    elseif action.kind == "dict_ignore" then
      vim.cmd("silent! spellrare " .. vim.fn.fnameescape(action.word))
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

-- Track active file and persist session safely
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
    autosave_all_modified()
    save_session()
  end,
})

vim.api.nvim_create_autocmd({ "BufDelete", "DirChanged" }, {
  callback = function()
    if is_quitting or not session_restored then return end
    vim.schedule(save_session)
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
-- DESKTOP FONTS & OPTIONS PANEL (Ctrl+Shift+K+T)
-- Multi-tab control: Family, Size, Weight, and Line Spacing with live preview
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
  if vim.fn.filereadable(FontEngine.config_file) == 1 then
    local content = vim.fn.readfile(FontEngine.config_file)
    if content and #content > 0 then
      local ok, data = pcall(vim.fn.json_decode, table.concat(content, "\n"))
      if ok and type(data) == "table" and data.family then
        data.size = tostring(data.size or "11.5")
        data.weight = data.weight or "regular"
        data.line_space = tonumber(data.line_space) or 0
        return data
      end
    end
  end
  local legacy_name = "CaskaydiaCove Nerd Font"
  if vim.fn.filereadable(FontEngine.legacy_file) == 1 then
    local l = vim.fn.readfile(FontEngine.legacy_file)
    if l and l[1] and l[1]:match("%S") then
      legacy_name = vim.trim(l[1])
    end
  end
  return {
    family = legacy_name,
    size = "11.5",
    bold = false,
    weight = "regular",
    line_space = 0,
  }
end

function FontEngine.save_config(cfg)
  pcall(vim.fn.mkdir, vim.fn.fnamemodify(FontEngine.config_file, ":p:h"), "p")
  local encoded = vim.fn.json_encode(cfg)
  vim.fn.writefile({ encoded }, FontEngine.config_file)
  pcall(vim.fn.writefile, { cfg.family }, FontEngine.legacy_file)
end

function FontEngine.apply_config(cfg)
  if not cfg or not cfg.family or cfg.family == "" then return end
  local font_str = cfg.family .. ":h" .. (cfg.size or "11.5")
  if cfg.bold or cfg.weight == "bold" then
    font_str = font_str .. ":b"
  elseif cfg.weight and cfg.weight ~= "regular" and cfg.weight ~= "" then
    font_str = font_str .. ":" .. cfg.weight
  end
  pcall(function()
    vim.o.guifont = font_str
  end)
  if vim.g.neovide then
    pcall(function()
      vim.g.neovide_line_space = tonumber(cfg.line_space) or 0
    end)
  end
end

function FontEngine.get_active_font()
  return FontEngine.get_config().family
end

function FontEngine.apply_font(font_name)
  local cfg = FontEngine.get_config()
  cfg.family = font_name
  FontEngine.apply_config(cfg)
end

function FontEngine.save_active_font(font_name)
  local cfg = FontEngine.get_config()
  cfg.family = font_name
  FontEngine.save_config(cfg)
end

_G.open_font_picker = function()
  local all_fonts = FontEngine.get_installed_fonts()
  local initial_cfg = FontEngine.get_config()
  local working_cfg = vim.deepcopy(initial_cfg)

  local active_tab = 1
  local tab_names = { "Family", "Size", "Weight", "Spacing" }
  local filtered_fonts = {}
  local sel_idx = { [1] = 1, [2] = 1, [3] = 1, [4] = 1 }

  -- Identify initial selections
  for i, f in ipairs(all_fonts) do
    if f == working_cfg.family then
      sel_idx[1] = i
      break
    end
  end
  for i, s in ipairs(FontEngine.font_sizes) do
    if s == working_cfg.size then
      sel_idx[2] = i
      break
    end
  end
  for i, w in ipairs(FontEngine.font_weights) do
    if w.id == working_cfg.weight or (working_cfg.bold and w.id == "bold") then
      sel_idx[3] = i
      break
    end
  end
  for i, sp in ipairs(FontEngine.line_spacings) do
    if sp.val == working_cfg.line_space then
      sel_idx[4] = i
      break
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.b[buf].is_picker = true
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].undolevels = -1

  local ui = vim.api.nvim_list_uis()[1] or { width = 120, height = 40 }
  local width = math.min(62, ui.width - 6)
  local height = math.min(18, ui.height - 6)
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
    title = string.format(" Typography & Font Settings (%d Fonts) ", #all_fonts),
    title_pos = "center",
    footer = " Tab: Next Tab ",
    footer_pos = "center",
  })

  vim.cmd("stopinsert")
  vim.wo[win].cursorline = false
  vim.wo[win].wrap = false
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

  vim.api.nvim_set_hl(0, "FontTabActive", { fg = "#ffffff", bg = "#3b4252", bold = true })
  vim.api.nvim_set_hl(0, "FontTabInactive", { fg = "#7f848e", bg = "#21252b" })
  vim.api.nvim_set_hl(0, "FontItemArrow", { fg = "#61afef", bold = true })

  local sb
  local function render(update_preview)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local query = sb and sb.get_text() or ""
    local lines = {}

    -- Line 1: Tab headers with distinct pill background
    local tab_parts = {
      { id = 1, text = " 1: Family " },
      { id = 2, text = " 2: Size " },
      { id = 3, text = " 3: Weight " },
      { id = 4, text = " 4: Spacing " },
    }
    local tab_spans = {}
    local tab_line = "  "
    for _, tp in ipairs(tab_parts) do
      local s_col = #tab_line
      tab_line = tab_line .. tp.text
      local e_col = #tab_line
      tab_line = tab_line .. "  "
      table.insert(tab_spans, { id = tp.id, s = s_col, e = e_col })
    end
    table.insert(lines, tab_line)

    -- Line 2: Subheader for search (Family tab only) & Separator
    if active_tab == 1 then
      local search_line = sb and sb.get_display_line("  Search Family: ", "(type to filter fonts...)") or "  Search Family: ▏ (type to filter fonts...)"
      table.insert(lines, search_line)
      table.insert(lines, "  ────────────────────────────────────────────────────────────")
    else
      table.insert(lines, "  ────────────────────────────────────────────────────────────")
    end

    -- Tab-specific item rows (clean indicator, no redundant status text)
    if active_tab == 1 then
      filtered_fonts = {}
      for _, f in ipairs(all_fonts) do
        if query == "" or f:lower():find(query:lower(), 1, true) then
          table.insert(filtered_fonts, f)
        end
      end
      if #filtered_fonts == 0 then
        table.insert(lines, "   No fonts matching '" .. query .. "'")
      else
        if sel_idx[1] > #filtered_fonts then sel_idx[1] = #filtered_fonts end
        if sel_idx[1] < 1 then sel_idx[1] = 1 end
        for i, f in ipairs(filtered_fonts) do
          local prefix = (i == sel_idx[1]) and " > " or "   "
          table.insert(lines, prefix .. f)
        end
        working_cfg.family = filtered_fonts[sel_idx[1]]
      end
    elseif active_tab == 2 then
      for i, s in ipairs(FontEngine.font_sizes) do
        local prefix = (i == sel_idx[2]) and " > " or "   "
        table.insert(lines, prefix .. s .. " pt")
      end
    elseif active_tab == 3 then
      for i, w in ipairs(FontEngine.font_weights) do
        local prefix = (i == sel_idx[3]) and " > " or "   "
        table.insert(lines, prefix .. w.name)
      end
    elseif active_tab == 4 then
      for i, sp in ipairs(FontEngine.line_spacings) do
        local prefix = (i == sel_idx[4]) and " > " or "   "
        table.insert(lines, prefix .. sp.name)
      end
    end

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    local ns_id = vim.api.nvim_create_namespace("font_picker_hl")
    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
    for _, sp in ipairs(tab_spans) do
      local hl_group = (sp.id == active_tab) and "FontTabActive" or "FontTabInactive"
      pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, hl_group, 0, sp.s, sp.e)
    end

    local header_lines = (active_tab == 1 and 3 or 2)
    local target_row = header_lines + sel_idx[active_tab]
    local total_lines = #lines
    if target_row > total_lines then target_row = total_lines end
    if target_row < (header_lines + 1) and total_lines >= (header_lines + 1) then
      target_row = header_lines + 1
    end
    if vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_set_cursor, win, { target_row, 1 })
      if target_row <= total_lines then
        pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, "FontItemArrow", target_row - 1, 0, 4)
      end
    end

    if update_preview ~= false then
      FontEngine.apply_config(working_cfg)
    end
  end

  sb = make_searchbar("", function()
    if active_tab == 1 then
      sel_idx[1] = 1
      render(true)
    end
  end)

  bind_searchbar_keys(buf, sb, function() return active_tab == 1 end)

  render(false)

  local function confirm_selection()
    confirmed = true
    FontEngine.save_config(working_cfg)
    FontEngine.apply_config(working_cfg)
    pcall(vim.api.nvim_win_close, win, true)
    local ed = find_editor_win()
    if ed and vim.api.nvim_win_is_valid(ed) then
      vim.api.nvim_set_current_win(ed)
    end
    vim.cmd("startinsert")
    _G.clear_active_menu(cancel_selection)
    vim.notify(string.format("Font saved: %s, %s pt, %s", working_cfg.family, working_cfg.size, working_cfg.bold and "Bold" or working_cfg.weight), vim.log.levels.INFO)
  end

  local function next_tab()
    active_tab = (active_tab % #tab_names) + 1
    render(false)
  end

  local function prev_tab()
    active_tab = active_tab - 1
    if active_tab < 1 then active_tab = #tab_names end
    render(false)
  end

  local function move_up()
    if active_tab == 1 then
      if #filtered_fonts == 0 then return end
      sel_idx[1] = sel_idx[1] - 1
      if sel_idx[1] < 1 then sel_idx[1] = #filtered_fonts end
      working_cfg.family = filtered_fonts[sel_idx[1]]
    elseif active_tab == 2 then
      sel_idx[2] = sel_idx[2] - 1
      if sel_idx[2] < 1 then sel_idx[2] = #FontEngine.font_sizes end
      working_cfg.size = FontEngine.font_sizes[sel_idx[2]]
    elseif active_tab == 3 then
      sel_idx[3] = sel_idx[3] - 1
      if sel_idx[3] < 1 then sel_idx[3] = #FontEngine.font_weights end
      local sel = FontEngine.font_weights[sel_idx[3]]
      working_cfg.weight = sel.id
      working_cfg.bold = sel.bold
    elseif active_tab == 4 then
      sel_idx[4] = sel_idx[4] - 1
      if sel_idx[4] < 1 then sel_idx[4] = #FontEngine.line_spacings end
      working_cfg.line_space = FontEngine.line_spacings[sel_idx[4]].val
    end
    render(true)
  end

  local function move_down()
    if active_tab == 1 then
      if #filtered_fonts == 0 then return end
      sel_idx[1] = sel_idx[1] + 1
      if sel_idx[1] > #filtered_fonts then sel_idx[1] = 1 end
      working_cfg.family = filtered_fonts[sel_idx[1]]
    elseif active_tab == 2 then
      sel_idx[2] = sel_idx[2] + 1
      if sel_idx[2] > #FontEngine.font_sizes then sel_idx[2] = 1 end
      working_cfg.size = FontEngine.font_sizes[sel_idx[2]]
    elseif active_tab == 3 then
      sel_idx[3] = sel_idx[3] + 1
      if sel_idx[3] > #FontEngine.font_weights then sel_idx[3] = 1 end
      local sel = FontEngine.font_weights[sel_idx[3]]
      working_cfg.weight = sel.id
      working_cfg.bold = sel.bold
    elseif active_tab == 4 then
      sel_idx[4] = sel_idx[4] + 1
      if sel_idx[4] > #FontEngine.line_spacings then sel_idx[4] = 1 end
      working_cfg.line_space = FontEngine.line_spacings[sel_idx[4]].val
    end
    render(true)
  end

  local function page_up()
    if active_tab == 1 and #filtered_fonts > 0 then
      sel_idx[1] = math.max(1, sel_idx[1] - 8)
      working_cfg.family = filtered_fonts[sel_idx[1]]
      render(true)
    else
      move_up()
    end
  end

  local function page_down()
    if active_tab == 1 and #filtered_fonts > 0 then
      sel_idx[1] = math.min(#filtered_fonts, sel_idx[1] + 8)
      working_cfg.family = filtered_fonts[sel_idx[1]]
      render(true)
    else
      move_down()
    end
  end

  -- Left / Right: search cursor movement on Family tab, or previous/next tab on other tabs
  vim.keymap.set({ "n", "i", "s", "v" }, "<Left>", function()
    if active_tab == 1 then
      sb.move_left()
    else
      prev_tab()
    end
  end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<Right>", function()
    if active_tab == 1 then
      sb.move_right()
    else
      next_tab()
    end
  end, { buffer = buf, nowait = true })

  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = buf,
    once = true,
    callback = cancel_selection,
  })

  -- Tab navigation
  vim.keymap.set({ "n", "i", "s", "v" }, "<Tab>", next_tab, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<S-Tab>", prev_tab, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-1>", function() active_tab = 1; render(false) end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-2>", function() active_tab = 2; render(false) end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-3>", function() active_tab = 3; render(false) end, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<M-4>", function() active_tab = 4; render(false) end, { buffer = buf, nowait = true })

  vim.keymap.set({ "n", "i", "s", "v" }, "<CR>", confirm_selection, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<Esc>", cancel_selection, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "<C-c>", cancel_selection, { buffer = buf, nowait = true })
  vim.keymap.set({ "n", "i", "s", "v" }, "q", function()
    if active_tab == 1 then
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
    { cat = "EDITING", key = "Tab", desc = "Indent line or selection" },
    { cat = "EDITING", key = "Shift + Tab", desc = "Unindent line or selection" },
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

-- Load and apply persisted active theme
ThemeEngine.apply_theme(ThemeEngine.get_active_theme())
if _G.reapply_all_icon_colors then
  _G.reapply_all_icon_colors()
end

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
local ok_mc, mc = pcall(require, "multiple-cursors")
if ok_mc then
  mc.setup({
    custom_key_maps = {
      { { "x", "s" }, "<BS>", function() require("multiple-cursors.visual_mode.delete_yank_change_put").d() end },
      { { "x", "s" }, "<Del>", function() require("multiple-cursors.visual_mode.delete_yank_change_put").d() end },
    },
  })
end

_G.multicursor_add_next = function()
  local ok, mcp = pcall(require, "multiple-cursors")
  if not ok then return end
  local m = vim.fn.mode()
  if m:match("[is]") then
    vim.cmd("stopinsert")
  end
  pcall(mcp.add_cursor_and_jump_to_next_match)
end

_G.multicursor_select_all = function()
  local ok, mcp = pcall(require, "multiple-cursors")
  if not ok then return end
  local m = vim.fn.mode()
  if m:match("[is]") then vim.cmd("stopinsert") end
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
local function toggle_comment()
  local mode = vim.fn.mode()
  if mode == "s" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>", true, false, true), "nx", false)
    vim.cmd("normal gc")
    vim.cmd("startinsert")
  elseif mode == "x" or mode == "v" or mode == "V" then
    vim.cmd("normal gc")
    vim.cmd("startinsert")
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

  vim.schedule(function()
    if new_e_col >= max_col then
      vim.api.nvim_win_set_cursor(0, { new_e_row, math.max(0, max_col - 1) })
      vim.cmd("startinsert!")
    else
      vim.api.nvim_win_set_cursor(0, { new_e_row, new_e_col })
      vim.cmd("startinsert")
    end
  end)
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

-- Line Deletion (Shift+Delete & Ctrl+Shift+K like VS Code / Notepad)
map({ "i", "n", "v", "s" }, "<S-Del>", _G.delete_line, { desc = "Delete Line or Selection" })
map({ "i", "n", "v", "s" }, "<S-Delete>", _G.delete_line, { desc = "Delete Line or Selection" })
map({ "i", "n", "v", "s" }, "<C-S-Del>", _G.delete_line, { desc = "Delete Line or Selection" })
map({ "i", "n", "v", "s" }, "<C-S-Delete>", _G.delete_line, { desc = "Delete Line or Selection" })
map({ "i", "n", "v", "s" }, "<S-kDel>", _G.delete_line, { desc = "Delete Line or Selection" })
map({ "i", "n", "v", "s" }, "<C-S-kDel>", _G.delete_line, { desc = "Delete Line or Selection" })
map({ "i", "n", "v", "s" }, "<C-S-k>", _G.delete_line, { desc = "Delete Line" })
map({ "i", "n", "v", "s" }, "<C-S-K>", _G.delete_line, { desc = "Delete Line" })

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

-- Home / End Selection
map("i", "<S-Home>", "<C-o>v0<C-g>", { desc = "Select to Line Start" })
map("s", "<S-Home>", "<C-g>0<C-g>", { desc = "Select to Line Start" })
map("i", "<S-End>", "<C-o>v$<C-g>", { desc = "Select to Line End" })
map("s", "<S-End>", "<C-g>$<C-g>", { desc = "Select to Line End" })
map("i", "<C-S-Home>", "<C-o>vgg0<C-g>", { desc = "Select to Document Start" })
map("s", "<C-S-Home>", "<C-g>gg0<C-g>", { desc = "Select to Document Start" })
map("i", "<C-S-End>", "<C-o>vG$<C-g>", { desc = "Select to Document End" })
map("s", "<C-S-End>", "<C-g>G$<C-g>", { desc = "Select to Document End" })

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

-- Desktop Fonts Picker (Ctrl+Shift+K+T / Ctrl+Shift+K t)
map({ "i", "n", "v", "s", "t" }, "<C-S-k><C-S-t>", _G.open_font_picker, { desc = "Desktop Font Picker" })
map({ "i", "n", "v", "s", "t" }, "<C-S-K><C-S-T>", _G.open_font_picker, { desc = "Desktop Font Picker" })
map({ "i", "n", "v", "s", "t" }, "<C-S-k>t", _G.open_font_picker, { desc = "Desktop Font Picker" })
map({ "i", "n", "v", "s", "t" }, "<C-S-K>t", _G.open_font_picker, { desc = "Desktop Font Picker" })
map({ "i", "n", "v", "s", "t" }, "<C-S-k><C-t>", _G.open_font_picker, { desc = "Desktop Font Picker" })
map({ "i", "n", "v", "s", "t" }, "<C-k><C-S-t>", _G.open_font_picker, { desc = "Desktop Font Picker" })
map({ "i", "n", "v", "s", "t" }, "<C-k><C-S-T>", _G.open_font_picker, { desc = "Desktop Font Picker" })
map({ "i", "n", "v", "s", "t" }, "<C-S-k>", "<nop>", { desc = "Chord Prefix (No Digraph)" })

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
  local ok, t = pcall(require, "nvim-tree.api")
  if ok then t.tree.toggle({ focus = false }) end
end

map({ "i", "n", "v", "s", "t" }, "<C-b>", _G.toggle_tree, { desc = "Toggle Sidebar" })

map({ "i", "n", "v", "s", "t" }, "<C-S-e>", _G.toggle_sidebar_focus, { desc = "Toggle Sidebar Focus" })
map({ "i", "n", "v", "s", "t" }, "<C-S-E>", _G.toggle_sidebar_focus, { desc = "Toggle Sidebar Focus" })
map({ "i", "n", "v", "s", "t" }, "<C-E>", _G.toggle_sidebar_focus, { desc = "Toggle Sidebar Focus" })

-- Built-in Terminal Drawer Toggle (Ctrl+` / Ctrl+~ / Ctrl+J) in ALL modes
map({ "i", "n", "v", "s", "t" }, "<C-`>", _G.toggle_terminal, { desc = "Toggle Built-in Terminal" })
map({ "i", "n", "v", "s", "t" }, "<C-~>", _G.toggle_terminal, { desc = "Toggle Built-in Terminal" })
map({ "i", "n", "v", "s", "t" }, "<C-j>", _G.toggle_terminal, { desc = "Toggle Built-in Terminal" })

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
    if bufs[i] then
      local ed = find_editor_win()
      if ed then vim.api.nvim_set_current_win(ed) end
      vim.api.nvim_set_current_buf(bufs[i])
      vim.cmd("startinsert")
    end
  end, { desc = "Go to Tab " .. i })
end

-- Close File (Ctrl+W) & Quit (Ctrl+Q)
map({ "i", "n", "v", "s" }, "<C-w>", function() _G.close_buffer() end, { desc = "Close Active File" })
map({ "i", "n", "v", "s", "t" }, "<C-q>", "<cmd>qa<cr>", { desc = "Quit Notepad" })

_G.handle_escape = function()
  local ok_mc, vc = pcall(require, "multiple-cursors.virtual_cursors")
  if ok_mc and vc.get_num_virtual_cursors() > 0 then
    pcall(require("multiple-cursors").normal_escape)
  end
  vim.cmd("nohlsearch")
  vim.cmd("startinsert")
end

-- Escape: Deselects / Clears multi-cursors and search, stays in Insert Mode
map({ "i", "s", "x", "n" }, "<Esc>", _G.handle_escape, { desc = "Clear Selection / Multi-Cursors / Keep Typing" })

-- Disable colon command line access
map("n", ":", "<cmd>startinsert<cr>")

-- =============================================================================
-- EXHAUSTIVE KEYBOARD SAFETY FOR 15.6" LAPTOPS (Blocks all unexpected text/modes)
-- =============================================================================

-- 1. Block unassigned Ctrl keys so they never output digraphs, registers, or control characters
local unassigned_ctrl = {
  "<C-l>", "<C-o>", "<C-p>", "<C-r>", "<C-t>",
  "<C-\\>", "<C-]>", "<C-^>", "<C-@>",
}
for _, k in ipairs(unassigned_ctrl) do
  map({ "i", "n", "v", "s" }, k, "<nop>", { desc = "Disabled Unassigned Ctrl Key" })
end

-- 2. Prevent Insert key from ever entering Replace mode (-- REPLACE --)
map({ "i", "n", "v", "s" }, "<Insert>", "<cmd>startinsert<cr>", { desc = "Prevent Replace Mode" })

-- 3. Block F1 (Vim help) and F2-F12 accidental presses (plain, Shift, Ctrl, and Alt)
for i = 1, 12 do
  map({ "i", "n", "v", "s" }, "<F" .. i .. ">", "<nop>", { desc = "Disabled Function Key" })
  map({ "i", "n", "v", "s" }, "<S-F" .. i .. ">", "<nop>", { desc = "Disabled Function Key" })
  map({ "i", "n", "v", "s" }, "<C-F" .. i .. ">", "<nop>", { desc = "Disabled Function Key" })
  map({ "i", "n", "v", "s" }, "<M-F" .. i .. ">", "<nop>", { desc = "Disabled Function Key" })
end

-- 4. Block unassigned Alt combinations so Alt keys never drop into Normal mode
for c = 97, 122 do -- a-z
  local ch = string.char(c)
  if ch ~= "f" and ch ~= "c" and ch ~= "n" and ch ~= "k" and ch ~= "j" and ch ~= "g" and ch ~= "a" then -- f is format, c is ColorPicker, n is Alt+N T terminal, k is Shift+Alt+K kill / Alt+k jump up, j is Alt+j jump down, g is Alt+g goto line, a is Shift+Alt+A multiline block comment
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

-- Modern VS Code-style Status Line (No emojis)
function _G.editor_statusline()
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  if ft == "NvimTree" then return "  EXPLORER" end
  if ft == "minimal_home" then
    return "  Minimal %=" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":~") .. " "
  end
  if vim.bo[buf].buftype == "terminal" then
    return "  bash │ " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":~") .. " "
  end

  local branch = vim.b[buf].gitsigns_head or ""
  local branch_str = branch ~= "" and ("  " .. branch .. " │") or ""

  local diag_e = #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.ERROR })
  local diag_w = #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.WARN })
  local diag_str = ""
  if diag_e > 0 then diag_str = diag_str .. " 󰅚 " .. diag_e end
  if diag_w > 0 then diag_str = diag_str .. " 󰀪 " .. diag_w end
  if diag_str ~= "" then diag_str = diag_str .. " │" end

  local enc = (vim.bo[buf].fileencoding ~= "" and vim.bo[buf].fileencoding or "utf-8"):upper()

  return string.format("%s%s  %%f %%m %%=%s │ Spaces: %d │ Ln %%l, Col %%c ",
    branch_str, diag_str, enc, vim.bo[buf].shiftwidth)
end

vim.opt.statusline = "%!v:lua._G.editor_statusline()"

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
