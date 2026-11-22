-- Gowise Universal Keymaps (VS Code & Zed Parity)
-- Complete modeless editing experience across Linux, macOS, and Windows

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Helper function to close current buffer safely
local function close_active_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local modified = vim.bo[bufnr].modified
  if modified then
    local choice = vim.fn.confirm("Save changes before closing?", "&Yes\n&No\n&Cancel", 1)
    if choice == 1 then
      vim.cmd("silent! write")
      vim.cmd("bdelete")
    elseif choice == 2 then
      vim.cmd("bdelete!")
    end
  else
    vim.cmd("bdelete")
  end
end

-- ============================================================================
-- 1. BASIC EDITING, CLIPBOARD & UNDO/REDO (VS Code Standard)
-- ============================================================================

-- Save File (Ctrl+S)
map({ "n", "i", "v", "x" }, "<C-s>", "<Esc>:w<CR>", { desc = "Save File", silent = true })

-- Save All (Ctrl+Shift+S)
map({ "n", "i", "v", "x" }, "<C-S-s>", "<Esc>:wa<CR>", { desc = "Save All Files", silent = true })

-- Close Current Tab / Buffer (Ctrl+W in Normal/Visual, Ctrl+Q in all modes)
map({ "n", "v" }, "<C-w>", function()
  close_active_buffer()
end, { desc = "Close Tab", silent = true })

map({ "n", "i", "v" }, "<C-q>", function()
  close_active_buffer()
end, { desc = "Close Tab", silent = true })

-- Select All (Ctrl+A)
map({ "n", "i", "x" }, "<C-a>", "<Esc>ggVG", { desc = "Select All", silent = true })

-- Undo (Ctrl+Z)
map("n", "<C-z>", "u", opts)
map("i", "<C-z>", "<C-o>u", opts)
map("v", "<C-z>", "<Esc>u", opts)

-- Redo (Ctrl+Y or Ctrl+Shift+Z)
map("n", "<C-y>", "<C-r>", opts)
map("i", "<C-y>", "<C-o><C-r>", opts)
map("n", "<C-S-z>", "<C-r>", opts)
map("i", "<C-S-z>", "<C-o><C-r>", opts)

-- Cut (Ctrl+X)
map("v", "<C-x>", '"+d', opts)
map("x", "<C-x>", '"+d', opts)
map("n", "<C-x>", '"+dd', opts)
map("i", "<C-x>", '<C-o>"+dd', opts)

-- Copy (Ctrl+C)
map("v", "<C-c>", '"+y', opts)
map("x", "<C-c>", '"+y', opts)
map("n", "<C-c>", '"+yy', opts)
map("i", "<C-c>", '<C-o>"+yy', opts)

-- Paste (Ctrl+V)
map("n", "<C-v>", '"+P', opts)
map("i", "<C-v>", '<C-r>+', opts)
map("v", "<C-v>", '"+p', opts)
map("x", "<C-v>", '"+p', opts)
map("c", "<C-v>", '<C-r>+', { noremap = true })

-- ============================================================================
-- 2. WORD NAVIGATION & WORD DELETION (Exact Word Boundaries)
-- ============================================================================

-- Word Left / Right
map({ "n", "i" }, "<C-Left>", "<C-o>b", opts)
map({ "n", "i" }, "<C-Right>", "<C-o>e<Right>", opts)

-- Word Delete Left (Ctrl+Backspace, Alt+Backspace, Ctrl+W, Ctrl+H in insert mode)
local function delete_word_left()
  local col = vim.fn.col(".")
  if col <= 1 then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<BS>", true, true, true), "n", false)
    return
  end
  local line = vim.api.nvim_get_current_line()
  local left = line:sub(1, col - 1)
  local space_match = left:match("(%s+)$")
  local len = 0
  if space_match then
    local trimmed = left:sub(1, #left - #space_match)
    local word_match = trimmed:match("([%w_]+)$") or trimmed:match("([^%w_%s]+)$")
    len = #space_match + (word_match and #word_match or 0)
  else
    local word_match = left:match("([%w_]+)$") or left:match("([^%w_%s]+)$")
    len = word_match and #word_match or 1
  end
  local new_line = left:sub(1, #left - len) .. line:sub(col)
  vim.api.nvim_set_current_line(new_line)
  vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), col - len })
end

-- Map all possible terminal variations of Ctrl+Backspace to delete_word_left
map("i", "<C-BS>", delete_word_left, opts)
map("i", "<M-BS>", delete_word_left, opts)
map("i", "<C-w>", delete_word_left, { desc = "Delete Word Left", silent = true })
map("i", "<C-h>", delete_word_left, { desc = "Delete Word Left", silent = true })
map("i", "<M-h>", delete_word_left, { desc = "Delete Word Left", silent = true })
map("n", "<C-BS>", "db", opts)
map("n", "<M-BS>", "db", opts)

-- Word Delete Right (Ctrl+Delete)
map("i", "<C-Del>", "<C-o>de", opts)
map("i", "<M-Del>", "<C-o>de", opts)
map("n", "<C-Del>", "de", opts)

-- Delete Current Line (Ctrl+Shift+K)
map({ "n", "i" }, "<C-S-k>", "<Esc>ddi", opts)

-- ============================================================================
-- 3. LINE MOVEMENT & DUPLICATION (VS Code & Zed)
-- ============================================================================

-- Move Line Up / Down (Alt+Up / Alt+Down)
map("n", "<A-Down>", ":m .+1<CR>==", opts)
map("n", "<A-Up>", ":m .-2<CR>==", opts)
map("i", "<A-Down>", "<Esc>:m .+1<CR>==gi", opts)
map("i", "<A-Up>", "<Esc>:m .-2<CR>==gi", opts)
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", opts)
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", opts)

-- Duplicate Line (Shift+Alt+Down / Shift+Alt+Up)
map("n", "<A-S-Down>", ":t.<CR>", opts)
map("n", "<A-S-Up>", ":t.-1<CR>", opts)
map("i", "<A-S-Down>", "<Esc>:t.<CR>gi", opts)
map("i", "<A-S-Up>", "<Esc>:t.-1<CR>gi", opts)
map("v", "<A-S-Down>", ":t'><CR>gv=gv", opts)
map("v", "<A-S-Up>", ":t'<-1<CR>gv=gv", opts)

-- Insert Line Below / Above (Ctrl+Enter / Ctrl+Shift+Enter)
map({ "n", "i" }, "<C-CR>", "<Esc>o", opts)
map({ "n", "i" }, "<C-S-CR>", "<Esc>O", opts)

-- ============================================================================
-- 4. INDENTATION & COMMENTS
-- ============================================================================

-- Indent / Unindent with Tab and Shift+Tab
map("v", "<Tab>", ">gv", opts)
map("v", "<S-Tab>", "<gv", opts)

-- Toggle Line Comment (Ctrl+/ and Ctrl+_)
map({ "n", "i" }, "<C-/>", "<Esc>gccgi", { desc = "Toggle Comment", remap = true })
map({ "n", "i" }, "<C-_>", "<Esc>gccgi", { desc = "Toggle Comment", remap = true })
map("v", "<C-/>", "gc", { desc = "Toggle Comment", remap = true })
map("v", "<C-_>", "gc", { desc = "Toggle Comment", remap = true })

-- Code Folding (Ctrl+Shift+[ and Ctrl+Shift+])
map({ "n", "i", "v" }, "<C-S-[>", "<Esc>zc", { desc = "Fold Block", silent = true })
map({ "n", "i", "v" }, "<C-S-]>", "<Esc>zo", { desc = "Unfold Block", silent = true })

-- ============================================================================
-- 5. SHIFT-SELECTION (Standard PC Selection)
-- ============================================================================

map("n", "<S-Left>", "v<Left>", opts)
map("n", "<S-Right>", "v<Right>", opts)
map("n", "<S-Up>", "v<Up>", opts)
map("n", "<S-Down>", "v<Down>", opts)
map("i", "<S-Left>", "<Esc>v<Left>", opts)
map("i", "<S-Right>", "<Esc>v<Right>", opts)
map("i", "<S-Up>", "<Esc>v<Up>", opts)
map("i", "<S-Down>", "<Esc>v<Down>", opts)
map("v", "<S-Left>", "<Left>", opts)
map("v", "<S-Right>", "<Right>", opts)
map("v", "<S-Up>", "<Up>", opts)
map("v", "<S-Down>", "<Down>", opts)

-- Shift+Home / Shift+End
map({ "n", "i" }, "<S-Home>", "<Esc>v^", opts)
map({ "n", "i" }, "<S-End>", "<Esc>v$", opts)
map("v", "<S-Home>", "^", opts)
map("v", "<S-End>", "$", opts)

-- ============================================================================
-- 6. NAVIGATION & PICKERS (VS Code Standards)
-- ============================================================================

-- Quick Open File (Ctrl+P)
map({ "n", "i" }, "<C-p>", function()
  if Snacks and Snacks.picker then
    Snacks.picker.files()
  else
    vim.cmd("find")
  end
end, { desc = "Quick Open File", silent = true })

-- Command Palette (Ctrl+Shift+P)
map({ "n", "i" }, "<C-S-p>", function()
  if Snacks and Snacks.picker then
    Snacks.picker.commands()
  end
end, { desc = "Command Palette", silent = true })

-- Global Project Search / Live Grep (Ctrl+Shift+F)
map({ "n", "i" }, "<C-S-f>", function()
  if Snacks and Snacks.picker then
    Snacks.picker.grep()
  end
end, { desc = "Global Live Grep", silent = true })

-- Find in File (Ctrl+F)
map({ "n", "i", "v" }, "<C-f>", function()
  if Snacks and Snacks.picker then
    Snacks.picker.lines()
  else
    vim.cmd("/")
  end
end, { desc = "Find in File", silent = true })

-- Toggle File Tree Sidebar (Ctrl+B)
map({ "n", "i" }, "<C-b>", function()
  require("gowise.components.tree").toggle()
end, { desc = "Toggle Sidebar", silent = true })

-- Toggle Terminal Drawer (Ctrl+` or Ctrl+J)
map({ "n", "i", "t" }, "<C-`>", function()
  require("gowise.components.terminal").toggle()
end, { desc = "Toggle Terminal Drawer", silent = true })

map({ "n", "i", "t" }, "<C-j>", function()
  require("gowise.components.terminal").toggle()
end, { desc = "Toggle Terminal Drawer", silent = true })

-- New Terminal Tab (Ctrl+Shift+`)
map({ "n", "i", "t" }, "<C-S-`>", function()
  require("gowise.components.terminal").new_instance()
end, { desc = "New Terminal Instance", silent = true })

-- Run Code (F5) & Stop Code (Shift+F5)
map({ "n", "i" }, "<F5>", function()
  require("gowise.components.runner").run()
end, { desc = "Run Code (F5)", silent = true })

map({ "n", "i" }, "<S-F5>", function()
  require("gowise.components.runner").stop()
end, { desc = "Stop Code (Shift+F5)", silent = true })

-- ============================================================================
-- 7. TAB & SPLIT WINDOW MANAGEMENT
-- ============================================================================

-- Switch Tabs (Ctrl+Tab and Ctrl+Shift+Tab)
map({ "n", "i" }, "<C-Tab>", ":bnext<CR>", opts)
map({ "n", "i" }, "<C-S-Tab>", ":bprevious<CR>", opts)

-- Split Panes (Ctrl+\ vertical split, Ctrl+K Ctrl+\ horizontal split)
map({ "n", "i" }, "<C-\\>", "<Esc>:vsplit<CR>", opts)

-- ============================================================================
-- 8. LANGUAGE SERVER (LSP) SHORTCUTS
-- ============================================================================

-- Go to Definition (F12)
map({ "n", "i" }, "<F12>", vim.lsp.buf.definition, { desc = "Go to Definition" })

-- Peek Definition (Alt+F12)
map({ "n", "i" }, "<A-F12>", function()
  if Snacks and Snacks.picker then
    Snacks.picker.lsp_definitions()
  else
    vim.lsp.buf.definition()
  end
end, { desc = "Peek Definition" })

-- Find References (Shift+F12)
map({ "n", "i" }, "<S-F12>", function()
  if Snacks and Snacks.picker then
    Snacks.picker.lsp_references()
  else
    vim.lsp.buf.references()
  end
end, { desc = "Find References" })

-- Rename Symbol (F2)
map({ "n", "i" }, "<F2>", vim.lsp.buf.rename, { desc = "Rename Symbol" })

-- Quick Fix / Code Action (Ctrl+.)
map({ "n", "i" }, "<C-.>", vim.lsp.buf.code_action, { desc = "Code Action" })

-- Format Document (Shift+Alt+F)
map({ "n", "i", "v" }, "<A-S-f>", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format Document" })

-- Parameter Hints / Signature Help (Ctrl+Shift+Space)
map("i", "<C-S-Space>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

-- Toggle Diagnostics / Problems Panel (Ctrl+Shift+M)
map({ "n", "i" }, "<C-S-m>", function()
  if Snacks and Snacks.picker then
    Snacks.picker.diagnostics()
  else
    vim.diagnostic.setqflist()
  end
end, { desc = "Toggle Problems" })

-- ============================================================================
-- 9. TERMINAL MODE (POSIX Word Nav, Resize & Escape)
-- ============================================================================

-- In terminal mode: Ctrl+Left/Right jump words using POSIX readline escapes
map("t", "<C-Left>", "<Esc>b", opts)
map("t", "<C-Right>", "<Esc>f", opts)

-- In terminal mode: Ctrl+Backspace deletes word
map("t", "<C-BS>", "<C-w>", opts)
map("t", "<M-BS>", "<C-w>", opts)

-- In terminal mode: Ctrl+Up / Ctrl+Down resize the bottom terminal drawer
map("t", "<C-Up>", function()
  require("gowise.components.terminal").resize(-2)
end, opts)
map("t", "<C-Down>", function()
  require("gowise.components.terminal").resize(2)
end, opts)

-- Escape terminal mode with Esc
map("t", "<Esc><Esc>", "<C-\\><C-n>", opts)
