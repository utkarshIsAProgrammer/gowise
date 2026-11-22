-- Gowise Optimized Plugin Architecture
-- Ultra-lightweight: sub-30ms startup, compiled Rust/Lua cores, and zero bloat

local plugins = {
  -- 1. Folke Snacks: Ultra-fast Pickers, Indent Scope, Smooth Scroll, Notifier, Explorer
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        width = 62,
        preset = {
          header = [[
   ██████╗  ██████╗ ██╗    ██╗██╗███████╗███████╗
  ██╔════╝ ██╔═══██╗██║    ██║██║██╔════╝██╔════╝
  ██║  ███╗██║   ██║██║ █╗ ██║██║███████╗█████╗  
  ██║   ██║██║   ██║██║███╗██║██║╚════██║██╔══╝  
  ╚██████╔╝╚██████╔╝╚███╔███╔╝██║███████║███████╗
   ╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚═╝╚══════╝╚══════╝

        ⚡ The Fluent, Modeless Terminal IDE]],
          keys = {
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "p", desc = "Quick Open File (Ctrl+P)", action = ":lua Snacks.picker.files()" },
            { icon = " ", key = "f", desc = "Find Text / Grep (Ctrl+Shift+F)", action = ":lua Snacks.picker.grep()" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
            { icon = " ", key = "t", desc = "Change Theme (Ctrl+K Ctrl+T)", action = ":lua require('gowise.themes.engine').theme_picker()" },
            { icon = " ", key = "b", desc = "File Explorer (Ctrl+B)", action = ":lua require('gowise.components.tree').toggle()" },
            { icon = " ", key = "j", desc = "Terminal Drawer (Ctrl+`)", action = ":lua require('gowise.components.terminal').toggle()" },
            { icon = "🩺", key = "d", desc = "Health Doctor", action = ":!gowise --doctor" },
            { icon = " ", key = "q", desc = "Quit Editor", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "recent_files", icon = " ", title = "Recent Files", indent = 2, padding = 1 },
          { section = "startup" },
        },
      },
      notifier = { enabled = true, timeout = 3000 },
      quickfile = { enabled = true },
      statuscolumn = { enabled = false },
      words = { enabled = true },
      scroll = {
        enabled = true,
        animate = {
          duration = { step = 15, total = 200 },
          easing = "linear",
        },
      },
      indent = {
        enabled = true,
        char = "│",
        scope = {
          enabled = true,
          char = "▎",
          underline = false,
          hl = "SnacksIndentScope",
        },
      },
      picker = {
        enabled = true,
        ui_select = true,
      },
      explorer = {
        enabled = true,
      },
    },
  },

  -- 2. Blink.cmp: Ultra-fast C/Rust-compiled Autocompletion
  require("gowise.lsp.completion").spec,

  -- 3. Tree-sitter: Polyglot AST Semantic Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        "go", "gomod", "gosum",
        "typescript", "javascript", "tsx",
        "python", "rust", "c", "cpp",
        "html", "css", "json", "yaml", "toml", "markdown",
        "bash", "dockerfile", "sql", "lua",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        ts_configs.setup(opts)
      else
        local ok2, ts_main = pcall(require, "nvim-treesitter")
        if ok2 then
          ts_main.setup(opts)
        end
      end
    end,
  },

  -- 4. Rainbow Delimiters: Color-coded bracket nesting () {} []
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local rainbow = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow.strategy["global"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiter1",
          "RainbowDelimiter2",
          "RainbowDelimiter3",
          "RainbowDelimiter4",
          "RainbowDelimiter5",
          "RainbowDelimiter6",
        },
      }
    end,
  },

  -- 5. Mini.hipatterns: Inline Realtime Hex & CSS Colorizer (#00E5FF, #FF007F)
  {
    "echasnovski/mini.hipatterns",
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local hi = require("mini.hipatterns")
      return {
        highlighters = {
          hex_color = hi.gen_highlighter.hex_color(),
        },
      }
    end,
  },

  -- 6. Mini.pairs: Ultra-lightweight Auto-pairs
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },

  -- 7. Mini.icons: Fast HD icons for files and folders
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {},
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- 8. GitSigns: Realtime Git Gutter & Inline Blame
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = " " },
        topdelete    = { text = "▔" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 300,
        virt_text_pos = "eol",
      },
    },
  },

  -- 9. LSP Configuration & Mason Automated Installer
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("mason").setup({ ui = { border = "rounded" } })
      require("mason-lspconfig").setup({
        ensure_installed = { "gopls", "ts_ls", "pyright", "rust_analyzer", "clangd", "bashls", "emmet_language_server", "html", "cssls" },
        automatic_installation = true,
      })
      require("gowise.lsp.servers").setup()
      require("gowise.lsp.errorlens").setup()
    end,
  },

  -- 10. Multi-cursor Editing (VS Code Ctrl+D and multi-caret)
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      -- Ctrl+D: Select next match
      vim.keymap.set({ "n", "v", "i" }, "<C-d>", function()
        mc.matchAddCursor(1)
      end, { desc = "Add Cursor to Next Match" })

      -- Skip match
      vim.keymap.set({ "n", "v", "i" }, "<C-S-d>", function()
        mc.matchSkipCursor(1)
      end, { desc = "Skip Match" })

      -- Clear multi-cursor with Esc
      vim.keymap.set("n", "<Esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        elseif mc.hasCursors() then
          mc.clearCursors()
        else
          vim.cmd("nohlsearch")
        end
      end)
    end,
  },

  -- 11. Comment.nvim: Rock-solid Single-line (Ctrl+/) and Multi-line/Block (Shift+Alt+A) Comments
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- 12. Conform.nvim: Universal High-Speed Code Formatter for All Files
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "black", stop_after_first = true },
        javascript = { "prettier", stop_after_first = true },
        typescript = { "prettier", stop_after_first = true },
        javascriptreact = { "prettier", stop_after_first = true },
        typescriptreact = { "prettier", stop_after_first = true },
        html = { "prettier", stop_after_first = true },
        css = { "prettier", stop_after_first = true },
        scss = { "prettier", stop_after_first = true },
        less = { "prettier", stop_after_first = true },
        json = { "prettier", stop_after_first = true },
        jsonc = { "prettier", stop_after_first = true },
        yaml = { "prettier", stop_after_first = true },
        markdown = { "prettier", stop_after_first = true },
        go = { "gofmt", "goimports" },
        rust = { "rustfmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
      format_on_save = {
        timeout_ms = 1500,
        lsp_format = "fallback",
      },
    },
  },
}

-- Initialize Lazy package manager
require("lazy").setup(plugins, {
  root = vim.fn.stdpath("data") .. "/lazy",
  defaults = { lazy = false },
  performance = {
    cache = { enabled = true },
    reset_packpath = true,
    rtp = {
      reset = true,
      paths = {},
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin", "tarPlugin",
        "tohtml", "tutor", "zipPlugin",
      },
    },
  },
  ui = {
    border = "rounded",
  },
})

-- Apply Theme and Fluent visual cues
require("gowise.themes.engine").setup()
require("gowise.ui.fluent").setup()
