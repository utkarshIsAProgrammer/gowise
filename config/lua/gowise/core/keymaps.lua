-- Gowise Universal Keymaps (Full VS Code & Zed Parity)
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
-- 1. FILE, BUFFER & TAB MANAGEMENT
-- ============================================================================

-- Save File (Ctrl+S)
map({ "n", "i", "v", "x" }, "<C-s>", "<Esc>:w<CR>", { desc = "Save File", silent = true })

-- Save All (Ctrl+Shift+S)
map({ "n", "i", "v", "x" }, "<C-S-s>", "<Esc>:wa<CR>", { desc = "Save All Files", silent = true })

-- New File (Ctrl+N)
map({ "n", "i", "v" }, "<C-n>", "<Esc>:ene<CR>:startinsert<CR>", { desc = "New File", silent = true })

-- Close Current Tab / Buffer (Ctrl+W in Normal/Visual, Ctrl+Q in all modes)
map({ "n", "v", "x" }, "<C-w>", function()
  close_active_buffer()
end, { desc = "Close Tab", silent = true })

map({ "n", "i", "v", "x" }, "<C-q>", function()
  close_active_buffer()
end, { desc = "Close Tab", silent = true })

-- Switch Tabs (Ctrl+Tab, Ctrl+Shift+Tab, Ctrl+PageDown, Ctrl+PageUp)
map({ "n", "i", "v" }, "<C-Tab>", ":bnext<CR>", opts)
map({ "n", "i", "v" }, "<C-S-Tab>", ":bprevious<CR>", opts)
map({ "n", "i", "v" }, "<C-PageDown>", ":bnext<CR>", opts)
map({ "n", "i", "v" }, "<C-PageUp>", ":bprevious<CR>", opts)

-- Split Editor (Ctrl+\)
map({ "n", "i", "v" }, "<C-\\>", "<Esc>:vsplit<CR>", opts)

-- ============================================================================
-- 2. CLIPBOARD, SELECT ALL & UNDO/REDO
-- ============================================================================

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

-- Copy (Ctrl+C and Ctrl+Insert)
map("v", "<C-c>", '"+y', opts)
map("x", "<C-c>", '"+y', opts)
map("n", "<C-c>", '"+yy', opts)
map("i", "<C-c>", '<C-o>"+yy', opts)
map({ "n", "v", "x" }, "<C-Insert>", '"+y', opts)
map("i", "<C-Insert>", '<C-o>"+yy', opts)

-- Cut (Ctrl+X and Shift+Delete)
map("v", "<C-x>", '"+d', opts)
map("x", "<C-x>", '"+d', opts)
map("n", "<C-x>", '"+dd', opts)
map("i", "<C-x>", '<C-o>"+dd', opts)

map({ "v", "x" }, "<S-Del>", '"+d', { desc = "Cut Selection", silent = true })
map("n", "<S-Del>", '"+dd', { desc = "Cut Current Line", silent = true })
map("i", "<S-Del>", '<Esc>"+ddi', { desc = "Cut Current Line", silent = true })

-- Paste (Ctrl+V and Shift+Insert)
map("n", "<C-v>", '"+P', opts)
map("i", "<C-v>", '<C-r>+', opts)
map("v", "<C-v>", '"+p', opts)
map("x", "<C-v>", '"+p', opts)
map("c", "<C-v>", '<C-r>+', { noremap = true })

map("n", "<S-Insert>", '"+P', opts)
map("i", "<S-Insert>", '<C-r>+', opts)
map("v", "<S-Insert>", '"+p', opts)

-- ============================================================================
-- 3. WORD NAVIGATION & WORD/LINE DELETIONS
-- ============================================================================

-- Word Left / Right (Ctrl+Left / Ctrl+Right & ANSI terminal sequences)
local function move_word_left_insert()
  vim.cmd("stopinsert")
  vim.cmd("normal! b")
  vim.cmd("startinsert")
end

local function move_word_right_insert()
  vim.cmd("stopinsert")
  vim.cmd("normal! w")
  vim.cmd("startinsert")
end

local ctrl_left_keys = { "<C-Left>", "<Esc>[1;5D", "<Esc>[5D" }
local ctrl_right_keys = { "<C-Right>", "<Esc>[1;5C", "<Esc>[5C" }

for _, k in ipairs(ctrl_left_keys) do
  map("n", k, "b", opts)
  map("v", k, "b", opts)
  map("i", k, move_word_left_insert, opts)
end

for _, k in ipairs(ctrl_right_keys) do
  map("n", k, "w", opts)
  map("v", k, "w", opts)
  map("i", k, move_word_right_insert, opts)
end

-- Home & End (Line Start / End)
map({ "n", "v" }, "<Home>", "^", opts)
map("i", "<Home>", "<C-o>^", opts)
map({ "n", "v" }, "<End>", "$", opts)
map("i", "<End>", "<C-o>$", opts)

-- Ctrl+Home & Ctrl+End (File Start / End)
map({ "n", "v" }, "<C-Home>", "gg", opts)
map("i", "<C-Home>", "<C-o>gg", opts)
map({ "n", "v" }, "<C-End>", "G", opts)
map("i", "<C-End>", "<C-o>G", opts)

-- Word Delete Left (Ctrl+Backspace)
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

map("i", "<C-BS>", delete_word_left, opts)
map("i", "<M-BS>", delete_word_left, opts)
map("i", "<C-w>", delete_word_left, { desc = "Delete Word Left", silent = true })
map("n", "<C-BS>", "db", opts)
map("n", "<M-BS>", "db", opts)

-- Word Delete Right (Ctrl+Delete)
local function delete_word_right()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".")
  if col > #line then
    return
  end
  local right = line:sub(col)
  local space_match = right:match("^(%s+)")
  local len = 0
  if space_match then
    local trimmed = right:sub(#space_match + 1)
    local word_match = trimmed:match("^([%w_]+)") or trimmed:match("^([^%w_%s]+)")
    len = #space_match + (word_match and #word_match or 0)
  else
    local word_match = right:match("^([%w_]+)") or right:match("^([^%w_%s]+)")
    len = word_match and #word_match or 1
  end
  local new_line = line:sub(1, col - 1) .. line:sub(col + len)
  vim.api.nvim_set_current_line(new_line)
end

map("i", "<C-Del>", delete_word_right, opts)
map("i", "<M-Del>", delete_word_right, opts)
map("n", "<C-Del>", delete_word_right, opts)

-- Delete Line (Ctrl+Shift+K)
map("n", "<C-S-k>", "dd", opts)
map("i", "<C-S-k>", "<Esc>ddi", opts)
map("v", "<C-S-k>", "d", opts)

-- ============================================================================
-- 4. SELECTION (Shift+Arrows & Ctrl+Shift+Arrows Word Selection)
-- ============================================================================

-- Whole Word Selection Functions (VS Code Parity across all modes)
local function select_word_right()
  local mode = vim.fn.mode()
  if mode == "i" then
    local cur = vim.api.nvim_win_get_cursor(0)
    vim.cmd("stopinsert")
    local line = vim.api.nvim_get_current_line()
    if cur[2] < #line then
      vim.api.nvim_win_set_cursor(0, { cur[1], cur[2] })
      vim.cmd("normal! ve")
    end
  elseif mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd("normal! e")
  else
    vim.cmd("normal! ve")
  end
end

local function select_word_left()
  local mode = vim.fn.mode()
  if mode == "i" then
    local cur = vim.api.nvim_win_get_cursor(0)
    vim.cmd("stopinsert")
    if cur[2] > 0 then
      vim.api.nvim_win_set_cursor(0, { cur[1], cur[2] - 1 })
      vim.cmd("normal! vb")
    end
  elseif mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd("normal! b")
  else
    vim.cmd("normal! vb")
  end
end

-- Character-by-Character Selection Functions (Shift+Arrows across all modes)
local function select_char_right()
  local mode = vim.fn.mode()
  if mode == "i" then
    local cur = vim.api.nvim_win_get_cursor(0)
    vim.cmd("stopinsert")
    local line = vim.api.nvim_get_current_line()
    if cur[2] < #line then
      vim.api.nvim_win_set_cursor(0, { cur[1], cur[2] })
      vim.cmd("normal! v")
    end
  elseif mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd("normal! l")
  else
    vim.cmd("normal! vl")
  end
end

local function select_char_left()
  local mode = vim.fn.mode()
  if mode == "i" then
    local cur = vim.api.nvim_win_get_cursor(0)
    vim.cmd("stopinsert")
    if cur[2] > 0 then
      vim.api.nvim_win_set_cursor(0, { cur[1], cur[2] - 1 })
      vim.cmd("normal! v")
    end
  elseif mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd("normal! h")
  else
    vim.cmd("normal! vh")
  end
end

local function select_char_up()
  local mode = vim.fn.mode()
  if mode == "i" then
    vim.cmd("stopinsert")
    vim.cmd("normal! vk")
  elseif mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd("normal! k")
  else
    vim.cmd("normal! vk")
  end
end

local function select_char_down()
  local mode = vim.fn.mode()
  if mode == "i" then
    vim.cmd("stopinsert")
    vim.cmd("normal! vj")
  elseif mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd("normal! j")
  else
    vim.cmd("normal! vj")
  end
end

-- Key codes for terminal compatibility (standard termcodes + xterm CSI escape sequences)
local c_s_left_keys = { "<C-S-Left>", "<Esc>[1;6D", "<Esc>[6D" }
local c_s_right_keys = { "<C-S-Right>", "<Esc>[1;6C", "<Esc>[6C" }
local s_left_keys = { "<S-Left>", "<Esc>[1;2D", "<Esc>[2D" }
local s_right_keys = { "<S-Right>", "<Esc>[1;2C", "<Esc>[2C" }
local s_up_keys = { "<S-Up>", "<Esc>[1;2A", "<Esc>[2A" }
local s_down_keys = { "<S-Down>", "<Esc>[1;2B", "<Esc>[2B" }

local all_editor_modes = { "n", "i", "v", "x" }

for _, k in ipairs(c_s_left_keys) do
  map(all_editor_modes, k, select_word_left, { desc = "Select Word Left", silent = true })
end

for _, k in ipairs(c_s_right_keys) do
  map(all_editor_modes, k, select_word_right, { desc = "Select Word Right", silent = true })
end

for _, k in ipairs(s_left_keys) do
  map(all_editor_modes, k, select_char_left, { desc = "Select Left Character", silent = true })
end

for _, k in ipairs(s_right_keys) do
  map(all_editor_modes, k, select_char_right, { desc = "Select Right Character", silent = true })
end

for _, k in ipairs(s_up_keys) do
  map(all_editor_modes, k, select_char_up, { desc = "Select Line Up", silent = true })
end

for _, k in ipairs(s_down_keys) do
  map(all_editor_modes, k, select_char_down, { desc = "Select Line Down", silent = true })
end

-- ============================================================================
-- 4.1 VISUAL SELECTION SURROUND / WRAPPING (VS Code Parity)
-- When text is selected, typing quotes or brackets wraps both sides!
-- ============================================================================
local function wrap_selection(open_delim, close_delim)
  local mode = vim.fn.visualmode()
  if mode == "" then
    mode = vim.fn.mode()
  end
  local vpos = vim.fn.getpos("v")
  local dotpos = vim.fn.getpos(".")

  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
  vim.api.nvim_feedkeys(esc, "nx", false)

  local s_row, s_col, e_row, e_col
  if vpos[2] < dotpos[2] or (vpos[2] == dotpos[2] and vpos[3] <= dotpos[3]) then
    s_row, s_col = vpos[2] - 1, vpos[3] - 1
    e_row, e_col = dotpos[2] - 1, dotpos[3]
  else
    s_row, s_col = dotpos[2] - 1, dotpos[3] - 1
    e_row, e_col = vpos[2] - 1, vpos[3]
  end

  if mode == "V" then
    s_col = 0
    local last_line = vim.api.nvim_buf_get_lines(0, e_row, e_row + 1, false)[1] or ""
    e_col = #last_line
  end

  local start_line = vim.api.nvim_buf_get_lines(0, s_row, s_row + 1, false)[1] or ""
  local end_line = vim.api.nvim_buf_get_lines(0, e_row, e_row + 1, false)[1] or ""
  s_col = math.max(0, math.min(s_col, #start_line))
  e_col = math.max(0, math.min(e_col, #end_line))

  if s_row > e_row or (s_row == e_row and s_col >= e_col) then
    return
  end

  local lines = vim.api.nvim_buf_get_text(0, s_row, s_col, e_row, e_col, {})
  if #lines == 0 then
    return
  end

  if #lines == 1 then
    lines[1] = open_delim .. lines[1] .. close_delim
  else
    lines[1] = open_delim .. lines[1]
    lines[#lines] = lines[#lines] .. close_delim
  end

  vim.api.nvim_buf_set_text(0, s_row, s_col, e_row, e_col, lines)

  -- Move cursor to closing delimiter in normal mode
  if #lines == 1 then
    vim.api.nvim_win_set_cursor(0, { e_row + 1, e_col + #open_delim + #close_delim - 1 })
  else
    vim.api.nvim_win_set_cursor(0, { e_row + 1, #lines[#lines] - 1 })
  end
end

-- Delimiters auto-surround mappings in visual / selection mode
local wrap_pairs = {
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

for trigger_key, pair in pairs(wrap_pairs) do
  map({ "v", "x" }, trigger_key, function()
    wrap_selection(pair[1], pair[2])
  end, { desc = "Wrap selection with " .. pair[1] .. pair[2], silent = true })
end

-- Delete Selection with Backspace or Delete (VS Code Standard)
map({ "v", "x" }, "<BS>", '"_c', { desc = "Delete Selection", silent = true })
map({ "v", "x" }, "<Del>", '"_c', { desc = "Delete Selection", silent = true })
map({ "v", "x" }, "<C-BS>", '"_c', { desc = "Delete Selection", silent = true })
map({ "v", "x" }, "<M-BS>", '"_c', { desc = "Delete Selection", silent = true })
map({ "v", "x" }, "<C-w>", '"_c', { desc = "Delete Selection", silent = true })
map({ "v", "x" }, "<C-h>", '"_c', { desc = "Delete Selection", silent = true })

-- Line & Document Selection (Shift+Home, Shift+End, Ctrl+Shift+Home/End)
map({ "n", "i" }, "<S-Home>", "<Esc>v^", opts)
map({ "n", "i" }, "<S-End>", "<Esc>v$", opts)
map("v", "<S-Home>", "^", opts)
map("v", "<S-End>", "$", opts)

map({ "n", "i" }, "<C-S-Home>", "<Esc>vgg", opts)
map({ "n", "i" }, "<C-S-End>", "<Esc>vG", opts)
map("v", "<C-S-Home>", "gg", opts)
map("v", "<C-S-End>", "G", opts)

-- ============================================================================
-- 5. LINE MOVEMENT, DUPLICATION & COMMENTS
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

-- Indent / Unindent with Tab and Shift+Tab
map("v", "<Tab>", ">gv", opts)
map("v", "<S-Tab>", "<gv", opts)

-- Line & Block Commenting Handlers
local function toggle_line_comment_normal()
  local ok, comment_api = pcall(require, "Comment.api")
  if ok and comment_api then
    comment_api.toggle.linewise.current()
  else
    vim.cmd("normal gcc")
  end
end

local function toggle_line_comment_insert()
  local pos = vim.api.nvim_win_get_cursor(0)
  toggle_line_comment_normal()
  pcall(vim.api.nvim_win_set_cursor, 0, pos)
end

local function toggle_block_comment_normal()
  local ok, comment_api = pcall(require, "Comment.api")
  if ok and comment_api then
    comment_api.toggle.blockwise.current()
  else
    vim.cmd("normal gbc")
  end
end

local function toggle_block_comment_insert()
  local pos = vim.api.nvim_win_get_cursor(0)
  toggle_block_comment_normal()
  pcall(vim.api.nvim_win_set_cursor, 0, pos)
end

-- Toggle Line Comment (Ctrl+/ and Ctrl+_)
map("n", "<C-/>", toggle_line_comment_normal, { desc = "Toggle Line Comment", silent = true })
map("n", "<C-_>", toggle_line_comment_normal, { desc = "Toggle Line Comment", silent = true })
map("n", "<C-7>", toggle_line_comment_normal, { desc = "Toggle Line Comment", silent = true })

map("i", "<C-/>", toggle_line_comment_insert, { desc = "Toggle Line Comment", silent = true })
map("i", "<C-_>", toggle_line_comment_insert, { desc = "Toggle Line Comment", silent = true })
map("i", "<C-7>", toggle_line_comment_insert, { desc = "Toggle Line Comment", silent = true })

map("v", "<C-/>", "gc", { desc = "Toggle Line Comment", remap = true })
map("v", "<C-_>", "gc", { desc = "Toggle Line Comment", remap = true })
map("v", "<C-7>", "gc", { desc = "Toggle Line Comment", remap = true })

-- Toggle Block Comment (Shift+Alt+A / Alt+Shift+A)
map("n", "<A-S-a>", toggle_block_comment_normal, { desc = "Toggle Block Comment", silent = true })
map("n", "<M-A>", toggle_block_comment_normal, { desc = "Toggle Block Comment", silent = true })

map("i", "<A-S-a>", toggle_block_comment_insert, { desc = "Toggle Block Comment", silent = true })
map("i", "<M-A>", toggle_block_comment_insert, { desc = "Toggle Block Comment", silent = true })

map("v", "<A-S-a>", "gb", { desc = "Toggle Block Comment", remap = true })
map("v", "<M-A>", "gb", { desc = "Toggle Block Comment", remap = true })

-- Code Folding (Ctrl+Shift+[ and Ctrl+Shift+])
map({ "n", "i", "v" }, "<C-S-[>", "<Esc>zc", { desc = "Fold Block", silent = true })
map({ "n", "i", "v" }, "<C-S-]>", "<Esc>zo", { desc = "Unfold Block", silent = true })

-- ============================================================================
-- 6. SEARCH, REPLACE & NAVIGATION PICKERS
-- ============================================================================

-- Find in File (Ctrl+F)
map({ "n", "i", "v" }, "<C-f>", function()
  if Snacks and Snacks.picker then
    Snacks.picker.lines()
  else
    vim.cmd("/")
  end
end, { desc = "Find in File", silent = true })

-- Replace in File (Ctrl+H)
map("n", "<C-h>", function()
  local search = vim.fn.input("Find: ")
  if search and search ~= "" then
    local replace = vim.fn.input("Replace with: ")
    if replace then
      vim.cmd(string.format("%%s/%s/%s/gc", vim.fn.escape(search, "/"), vim.fn.escape(replace, "/")))
    end
  end
end, { desc = "Replace in File", silent = true })

-- Go to Line (Ctrl+G)
map({ "n", "i" }, "<C-g>", function()
  local line = vim.fn.input("Go to Line: ")
  if line and tonumber(line) then
    vim.cmd(":" .. tonumber(line))
  end
end, { desc = "Go to Line", silent = true })

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

-- Go to Symbol in File (Ctrl+Shift+O)
map({ "n", "i" }, "<C-S-o>", function()
  if Snacks and Snacks.picker then
    Snacks.picker.lsp_symbols()
  end
end, { desc = "Go to Symbol", silent = true })

-- ============================================================================
-- 7. UI DOCKS: SIDEBAR & TERMINAL (Toggleable from ALL modes without Esc!)
-- ============================================================================

-- Toggle File Tree Sidebar (Ctrl+B across all modes: normal, insert, visual, terminal)
map({ "n", "i", "v", "t" }, "<C-b>", function()
  require("gowise.components.tree").toggle()
end, { desc = "Toggle Sidebar", silent = true })

-- Toggle Terminal Drawer (Ctrl+`, Ctrl+~, Ctrl+^, Ctrl+@, Ctrl+J across ALL modes)
local term_toggle_keys = { "<C-`>", "<C-~>", "<C-^>", "<C-@>", "<C-j>" }
for _, key in ipairs(term_toggle_keys) do
  map({ "n", "i", "t", "v" }, key, function()
    require("gowise.components.terminal").toggle()
  end, { desc = "Toggle Terminal Drawer", silent = true })
end

-- New Terminal Tab (Ctrl+Shift+` and Ctrl+Shift+~)
map({ "n", "i", "t", "v" }, "<C-S-`>", function()
  require("gowise.components.terminal").new_instance()
end, { desc = "New Terminal Instance", silent = true })

map({ "n", "i", "t", "v" }, "<C-S-~>", function()
  require("gowise.components.terminal").new_instance()
end, { desc = "New Terminal Instance", silent = true })

-- Run Code (F5) & Stop Code (Shift+F5)
map({ "n", "i" }, "<F5>", function()
  require("gowise.components.runner").run()
end, { desc = "Run Code (F5)", silent = true })

map({ "n", "i" }, "<S-F5>", function()
  require("gowise.components.runner").stop()
end, { desc = "Stop Code (Shift+F5)", silent = true })

-- Theme Switcher (Ctrl+K Ctrl+T)
map({ "n", "i" }, "<C-k><C-t>", function()
  require("gowise.themes.engine").theme_picker()
end, { desc = "Preferences: Color Theme", silent = true })

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
  local ok, conform = pcall(require, "conform")
  if ok and conform then
    conform.format({ async = true, lsp_format = "fallback" }, function(err)
      if not err then
        vim.notify("Formatted document successfully", vim.log.levels.INFO, { title = "Gowise Formatter" })
      end
    end)
  else
    vim.lsp.buf.format({ async = true })
  end
end, { desc = "Format Document", silent = true })

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
-- 9. TERMINAL MODE (POSIX Word Nav, Swapped Resize & Escape)
-- ============================================================================

-- In terminal mode: Ctrl+Left/Right jump words using POSIX readline escapes
map("t", "<C-Left>", "<Esc>b", opts)
map("t", "<C-Right>", "<Esc>f", opts)

-- In terminal mode: Ctrl+Backspace deletes word
map("t", "<C-BS>", "<C-w>", opts)
map("t", "<M-BS>", "<C-w>", opts)

-- Terminal Resize: Ctrl+Up increases height (taller), Ctrl+Down decreases height (shorter)
local function resize_terminal_up()
  require("gowise.components.terminal").resize(2)
end

local function resize_terminal_down()
  require("gowise.components.terminal").resize(-2)
end

local ctrl_up_keys = { "<C-Up>", "<Esc>[1;5A", "<Esc>[5A" }
local ctrl_down_keys = { "<C-Down>", "<Esc>[1;5B", "<Esc>[5B" }

for _, k in ipairs(ctrl_up_keys) do
  map("t", k, resize_terminal_up, { desc = "Expand Terminal Height (Ctrl+Up)", silent = true })
  map("n", k, function()
    local resized = require("gowise.components.terminal").resize(2)
    if not resized then
      vim.cmd("normal! 5<C-y>")
    end
  end, { desc = "Expand Terminal / Scroll Up", silent = true })
end

for _, k in ipairs(ctrl_down_keys) do
  map("t", k, resize_terminal_down, { desc = "Shrink Terminal Height (Ctrl+Down)", silent = true })
  map("n", k, function()
    local resized = require("gowise.components.terminal").resize(-2)
    if not resized then
      vim.cmd("normal! 5<C-e>")
    end
  end, { desc = "Shrink Terminal / Scroll Down", silent = true })
end

-- Escape terminal mode with Esc Esc
map("t", "<Esc><Esc>", "<C-\\><C-n>", opts)
