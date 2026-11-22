-- Gowise Core Options
-- Tuned for maximum responsiveness, modeless VS Code experience, and low latency

local opt = vim.opt

-- Appearance & Theme Foundations
opt.termguicolors = true
opt.background = "dark"
opt.number = true
opt.relativenumber = true  -- Vim-style relative + absolute line numbering
opt.fillchars = { eob = " " } -- Hides the '~' characters at the end of the buffer!
opt.cursorline = true
opt.cursorlineopt = "both" -- Highlights the entire active line and number
opt.signcolumn = "yes:1"   -- Fixed sign column to prevent layout shifts
opt.showmode = false       -- No ugly -- INSERT -- text; handled by statusline
opt.showcmd = false
opt.ruler = false
opt.laststatus = 3         -- Global statusline across all windows
opt.pumheight = 10         -- Popup menu height
opt.pumblend = 5           -- Subtle transparency for completion menu
opt.winblend = 5           -- Subtle transparency for floating windows

-- Modeless Editing & Fluid Navigation
opt.mouse = "a"            -- Full mouse support (click, scroll, drag)
opt.clipboard = "unnamedplus" -- Sync with system clipboard seamlessly
opt.virtualedit = "onemore,block" -- Free visual block selection & one-past-line-end
opt.scrolloff = 8          -- Keep 8 lines of context vertically
opt.sidescrolloff = 8      -- Keep 8 columns of context horizontally
opt.wrap = false           -- No jarring line wraps by default
opt.linebreak = true       -- If wrap is enabled, break cleanly on words
opt.updatetime = 150       -- 150ms for responsive git signs, hover, and error lens
opt.timeoutlen = 300       -- Snappy key combo resolution
opt.keymodel = "startsel,stopsel" -- Native modeless Shift-selection (VS Code / Zed parity)
opt.selection = "inclusive"       -- Selection includes cursor endpoint
opt.selectmode = "mouse,key"      -- Typing immediately replaces selection

-- Code Spell Checker Configuration (CamelCase code identifiers & user dictionary)
opt.spell = true
opt.spelllang = { "en" }
opt.spelloptions = "camel"
opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"

-- Tabs & Indentation (Polyglot defaults)
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true       -- Spaces instead of tabs by default
opt.smartindent = true     -- Intelligent language-aware indent
opt.autoindent = true

-- Search & Replace
opt.ignorecase = true      -- Case-insensitive search by default
opt.smartcase = true       -- Case-sensitive if capital letters are used
opt.hlsearch = true
opt.incsearch = true

-- Splits & Windows
opt.splitbelow = true      -- Horizontal splits open below
opt.splitright = true      -- Vertical splits open to the right

-- History, Undo & Persistence
opt.undofile = true        -- Persistent undo across editor restarts
opt.undolevels = 10000
opt.swapfile = false       -- No annoying .swp files
opt.backup = false
opt.writebackup = false

-- Session Management
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"

-- Cursor styling for modeless terminal editing (always thin vertical beam, no block cursor)
opt.guicursor = "n-v-c-i-ci-ve:ver25-blinkwait300-blinkon200-blinkoff150,r-cr:hor20,o:hor50"
