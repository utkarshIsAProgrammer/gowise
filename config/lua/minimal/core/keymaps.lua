-- ============================================================================
-- Minimal Universal Keymaps (100% Modeless VS Code & Zed Parity)
-- Pure Non-Modal Editor: Always ready to type, zero Vim Normal mode traps.
-- ============================================================================

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ============================================================================
-- 1. 100% MODELESS TYPING ENGINE: PURE NON-MODAL EDITING
-- ============================================================================

_G.skip_insert_autocmd = false

local function ensure_insert_mode(buf)
  if _G.skip_insert_autocmd then return end
  buf = buf or vim.api.nvim_get_current_buf()
  if not (vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "") then
    return
  end
  local ft = vim.bo[buf].filetype
  if ft == "snacks_dashboard" or ft:find("dashboard") or ft:find("picker") or ft:find("snacks") or ft:find("explorer") then
    return
  end
  if not vim.bo[buf].modifiable and not vim.bo[buf].readonly then
    pcall(function() vim.bo[buf].modifiable = true end)
  end
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf)
      and vim.bo[buf].buftype == ""
      and vim.bo[buf].filetype ~= "snacks_dashboard"
      and not vim.bo[buf].filetype:find("picker")
      and not vim.bo[buf].filetype:find("explorer")
      and not vim.bo[buf].filetype:find("snacks")
      and vim.fn.mode() == "n"
    then
      if not vim.bo[buf].modifiable and not vim.bo[buf].readonly then
        pcall(function() vim.bo[buf].modifiable = true end)
      end
      if vim.bo[buf].modifiable then
        pcall(vim.cmd, "startinsert")
      end
    end
  end)
end

-- Automatically maintain Insert mode in all editable documents
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "InsertLeave", "FocusGained", "ModeChanged" }, {
  callback = function(args)
    if args.event == "ModeChanged" and not args.match:find(":n") then
      return
    end
    -- Do not interrupt visual or select mode
    local m = vim.fn.mode()
    if m == "v" or m == "V" or m == "\22" or m == "s" or m == "S" then
      return
    end
    ensure_insert_mode(args.buf)
  end,
  desc = "Maintain 100% Modeless Typing in all editable documents",
})

-- Automatically enter Terminal mode whenever a terminal buffer is focused
vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter", "WinEnter" }, {
  callback = function(args)
    local buf = args.buf
    if vim.api.nvim_buf_is_valid(buf) and (vim.bo[buf].buftype == "terminal" or vim.bo[buf].filetype == "snacks_terminal") then
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_get_current_buf() == buf then
          pcall(vim.cmd, "startinsert")
        end
      end)
    end
  end,
  desc = "Automatically enter terminal mode in terminal buffers",
})

-- Mouse Click: Click anywhere in document to focus and type immediately
map("n", "<LeftMouse>", "<LeftMouse><cmd>startinsert<cr>", { desc = "Click to focus and type (Modeless)" })

-- Normal Mode Editing Keys: Always enter insert mode cleanly without modal artifacts
map("n", "<CR>", function()
  if vim.bo.filetype == "snacks_dashboard" then
    return "<CR>"
  end
  return "<cmd>startinsert<CR><CR>"
end, { expr = true, silent = true, desc = "Enter" })

map("n", "<BS>", function()
  if vim.bo.filetype == "snacks_dashboard" then
    return "<BS>"
  end
  return "<cmd>startinsert<CR><BS>"
end, { expr = true, silent = true, desc = "Backspace" })

map("n", "<Del>", function()
  if vim.bo.filetype == "snacks_dashboard" then
    return "<Del>"
  end
  return "<cmd>startinsert<CR><Del>"
end, { expr = true, silent = true, desc = "Delete" })

map("n", "<Space>", function()
  if vim.bo.filetype == "snacks_dashboard" then
    return "<Space>"
  end
  return "<cmd>startinsert<CR><Space>"
end, { expr = true, silent = true, desc = "Space" })

map("n", "<Up>", "<cmd>startinsert<CR><Up>", { silent = true, desc = "Cursor Up" })
map("n", "<Down>", "<cmd>startinsert<CR><Down>", { silent = true, desc = "Cursor Down" })
map("n", "<Left>", "<cmd>startinsert<CR><Left>", { silent = true, desc = "Cursor Left" })
map("n", "<Right>", "<cmd>startinsert<CR><Right>", { silent = true, desc = "Cursor Right" })

-- ============================================================================
-- 2. UNIVERSAL MODELESS ESCAPE KEY (Dismiss, Cancel, Deselect)
-- In a modeless editor, Esc is the universal "Cancel / Dismiss" key:
-- 1) Closes autocomplete / code suggestions popup
-- 2) Closes hover doc / parameter signature help / diagnostics
-- 3) Closes pickers, search palettes, and floating overlays
-- 4) Deselects highlighted text and returns cleanly to typing
-- 5) NEVER locks the editor into a non-typing Normal mode
-- ============================================================================

local function handle_escape()
  vim.cmd("nohlsearch")

  -- Close code suggestion popup (blink.cmp) or native popup immediately
  local ok_blink, blink = pcall(require, "blink.cmp")
  if ok_blink then
    pcall(blink.cancel)
    pcall(blink.hide)
  end

  if vim.fn.pumvisible() == 1 then
    pcall(vim.fn.feedkeys, vim.api.nvim_replace_termcodes("<C-e>", true, false, true), "n")
  end

  -- Close Snacks picker if open
  local ok_snacks, snacks = pcall(require, "snacks")
  if ok_snacks and snacks.picker then
    local pickers = snacks.picker.get()
    if #pickers > 0 then
      for _, p in ipairs(pickers) do
        pcall(function() p:close() end)
      end
      return
    end
  end

  local cur_win = vim.api.nvim_get_current_win()
  local cur_buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[cur_buf].filetype
  local bt = vim.bo[cur_buf].buftype
  local win_cfg = vim.api.nvim_win_get_config(cur_win)

  -- On dashboard: keep dashboard intact
  if ft == "snacks_dashboard" or ft:find("dashboard") then
    return
  end

  -- If inside explorer sidebar, close it
  if ft == "snacks_explorer" or ft:find("explorer") or ft:find("snacks_picker") then
    require("minimal.components.tree").toggle()
    return
  end

  -- If inside terminal drawer, hide it
  if ft == "snacks_terminal" or bt == "terminal" then
    require("minimal.components.terminal").toggle()
    return
  end

  -- If inside a floating window (dialogs, popups, inputs, hover docs), close it
  if win_cfg.relative ~= "" then
    pcall(vim.api.nvim_win_close, cur_win, true)
    return
  end

  -- Close any open floating windows across the tabpage
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= cur_win and vim.api.nvim_win_is_valid(win) then
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative ~= "" then
        pcall(vim.api.nvim_win_close, win, true)
      end
    end
  end

  -- If in selection mode (visual/select), cancel selection and stay in typing mode
  local m = vim.fn.mode()
  if m == "s" or m == "x" or m == "v" or m == "V" or m == "\22" then
    vim.cmd("normal! \x1b")
    vim.cmd("startinsert")
    return
  end

  -- Always remain in Insert / Typing mode
  if vim.fn.mode() ~= "i" and vim.bo.buftype == "" and vim.bo.modifiable then
    vim.cmd("startinsert")
  end
end

map("i", "<Esc>", "<cmd>lua handle_escape()<CR>", { nowait = true, desc = "Dismiss Popups / Deselect (Modeless Esc)", silent = true })
map("n", "<Esc>", "<cmd>lua handle_escape()<CR><cmd>startinsert<CR>", { nowait = true, desc = "Dismiss Popups / Deselect (Modeless Esc)", silent = true })
map({ "s", "x", "v" }, "<Esc>", "<cmd>lua handle_escape()<CR>", { nowait = true, desc = "Dismiss Popups / Deselect (Modeless Esc)", silent = true })

map("i", "<S-Esc>", "<cmd>lua handle_escape()<CR>", { nowait = true, desc = "Dismiss Popups / Deselect (Modeless Esc)", silent = true })
map("n", "<S-Esc>", "<cmd>lua handle_escape()<CR><cmd>startinsert<CR>", { nowait = true, desc = "Dismiss Popups / Deselect (Modeless Esc)", silent = true })
map({ "s", "x", "v" }, "<S-Esc>", "<cmd>lua handle_escape()<CR>", { nowait = true, desc = "Dismiss Popups / Deselect (Modeless Esc)", silent = true })
_G.handle_escape = handle_escape

-- ============================================================================
-- 3. FILE, BUFFER & TAB MANAGEMENT
-- ============================================================================

local function notify_saved()
  local buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local fname = buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":t") or "[Untitled]"
  vim.notify("✓ Saved: " .. fname, vim.log.levels.INFO, { title = "Minimal" })
end
_G.minimal_notify_saved = notify_saved

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
  if vim.bo.buftype == "" and vim.bo.modifiable then
    pcall(vim.cmd, "startinsert")
  end
end

-- Save File (Ctrl+S) - 100% Modeless: Never drops out of insert mode
map("i", "<C-s>", "<cmd>silent! write<CR><cmd>lua _G.minimal_notify_saved()<CR>", { desc = "Save File (Ctrl+S)", silent = true })
map({ "n", "v", "x", "s" }, "<C-s>", "<cmd>silent! write<CR><cmd>lua _G.minimal_notify_saved()<CR><cmd>startinsert<CR>", { desc = "Save File (Ctrl+S)", silent = true })

-- Save All (Ctrl+Shift+S)
map("i", "<C-S-s>", "<cmd>silent! wa<CR><cmd>lua vim.notify('✓ Saved all files', vim.log.levels.INFO, { title = 'Minimal' })<CR>", { desc = "Save All Files", silent = true })
map({ "n", "v", "x", "s" }, "<C-S-s>", "<cmd>silent! wa<CR><cmd>lua vim.notify('✓ Saved all files', vim.log.levels.INFO, { title = 'Minimal' })<CR><cmd>startinsert<CR>", { desc = "Save All Files", silent = true })

-- New File (Ctrl+N)
map({ "n", "i", "v" }, "<C-n>", "<cmd>enew<CR><cmd>startinsert<CR>", { desc = "New File", silent = true })

-- Close Current Tab / Buffer (Ctrl+W and Ctrl+Q)
map({ "n", "v", "x" }, "<C-w>", close_active_buffer, { desc = "Close Tab", silent = true })
map({ "n", "i", "v", "x" }, "<C-q>", close_active_buffer, { desc = "Close Tab", silent = true })

-- Switch Tabs (Ctrl+Tab, Ctrl+Shift+Tab, Ctrl+PageDown, Ctrl+PageUp)
map({ "n", "i", "v" }, "<C-Tab>", "<cmd>bnext<CR><cmd>startinsert<CR>", opts)
map({ "n", "i", "v" }, "<C-S-Tab>", "<cmd>bprevious<CR><cmd>startinsert<CR>", opts)
map({ "n", "i", "v" }, "<C-PageDown>", "<cmd>bnext<CR><cmd>startinsert<CR>", opts)
map({ "n", "i", "v" }, "<C-PageUp>", "<cmd>bprevious<CR><cmd>startinsert<CR>", opts)

-- Split Editor (Ctrl+\)
map({ "n", "i", "v" }, "<C-\\>", "<cmd>vsplit<CR><cmd>startinsert<CR>", opts)

-- ============================================================================
-- 4. MODELESS CLIPBOARD OPERATIONS (Ctrl+C, Ctrl+V, Ctrl+X)
-- ============================================================================

local function copy_selection()
  vim.cmd('normal! \x1bgv"+y')
  local content = vim.fn.getreg('+')
  vim.fn.setreg('*', content)
  vim.fn.setreg('"', content)
  vim.cmd('normal! gv')
  vim.notify("Selection copied to clipboard", vim.log.levels.INFO, { title = "Minimal Clipboard" })
end

local function copy_line()
  local line = vim.api.nvim_get_current_line()
  vim.fn.setreg('+', line .. '\n', 'l')
  vim.fn.setreg('*', line .. '\n', 'l')
  vim.fn.setreg('"', line .. '\n', 'l')
  vim.notify("Line copied to clipboard", vim.log.levels.INFO, { title = "Minimal Clipboard" })
end

local function cut_selection()
  vim.cmd('normal! \x1bgv"+d')
  local content = vim.fn.getreg('+')
  vim.fn.setreg('*', content)
  vim.fn.setreg('"', content)
  vim.cmd('startinsert')
end

local function cut_line()
  local line = vim.api.nvim_get_current_line()
  vim.fn.setreg('+', line .. '\n', 'l')
  vim.fn.setreg('*', line .. '\n', 'l')
  vim.fn.setreg('"', line .. '\n', 'l')
  vim.cmd('normal! "_dd')
  vim.cmd('startinsert')
end

local function paste_over_selection()
  vim.cmd('normal! \x1bgv"_d')
  vim.cmd('startinsert')
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-r><C-o>+', true, false, true), 'n', false)
end

local function delete_selection()
  vim.cmd('normal! \x1bgv"_d')
  vim.cmd('startinsert')
end

-- Copy (Ctrl+C)
map({ "v", "x", "s" }, "<C-c>", copy_selection, { desc = "Copy Selection", silent = true })
map({ "n", "i" }, "<C-c>", copy_line, { desc = "Copy Current Line", silent = true })
map({ "v", "x" }, "<C-Insert>", copy_selection, { desc = "Copy Selection", silent = true })
map({ "n", "i" }, "<C-Insert>", copy_line, { desc = "Copy Current Line", silent = true })

-- Cut (Ctrl+X and Shift+Delete)
map({ "v", "x", "s" }, "<C-x>", cut_selection, { desc = "Cut Selection", silent = true })
map({ "n", "i" }, "<C-x>", cut_line, { desc = "Cut Current Line", silent = true })

local s_del_keys = { "<S-Del>", "\27[3;2~" }
for _, k in ipairs(s_del_keys) do
  map({ "v", "x", "s" }, k, cut_selection, { desc = "Cut Selection", silent = true })
  map({ "n", "i" }, k, cut_line, { desc = "Cut Current Line", silent = true })
end

-- Paste (Ctrl+V and Shift+Insert)
map({ "v", "x", "s" }, "<C-v>", paste_over_selection, { desc = "Paste Over Selection", silent = true })
map("i", "<C-v>", "<C-r><C-o>+", { desc = "Paste from Clipboard", silent = true })
map("n", "<C-v>", '"+p<cmd>startinsert<CR>', { desc = "Paste", silent = true })

map({ "v", "x", "s" }, "<S-Insert>", paste_over_selection, { desc = "Paste Over Selection", silent = true })
map("i", "<S-Insert>", "<C-r><C-o>+", { desc = "Paste from Clipboard", silent = true })
map("n", "<S-Insert>", '"+p<cmd>startinsert<CR>', { desc = "Paste", silent = true })

-- Backspace & Delete over selection (Deletes without overwriting clipboard)
map({ "v", "x", "s" }, "<BS>", delete_selection, { desc = "Delete Selection", silent = true })
map({ "v", "x", "s" }, "<Del>", delete_selection, { desc = "Delete Selection", silent = true })

-- ============================================================================
-- 5. UNDO, REDO & SELECT ALL
-- ============================================================================

-- Undo (Ctrl+Z)
map({ "n", "i" }, "<C-z>", "<C-o>u", { desc = "Undo", silent = true })
map({ "v", "x", "s" }, "<C-z>", "<Esc>u<cmd>startinsert<cr>", { desc = "Undo", silent = true })

-- Redo (Ctrl+Y and Ctrl+Shift+Z)
map({ "n", "i" }, "<C-y>", "<C-o><C-r>", { desc = "Redo", silent = true })
map({ "n", "i" }, "<C-S-z>", "<C-o><C-r>", { desc = "Redo", silent = true })
map({ "v", "x", "s" }, "<C-y>", "<Esc><C-r><cmd>startinsert<cr>", { desc = "Redo", silent = true })
map({ "v", "x", "s" }, "<C-S-z>", "<Esc><C-r><cmd>startinsert<cr>", { desc = "Redo", silent = true })

-- Select All (Ctrl+A)
map({ "n", "i", "v", "x", "s" }, "<C-a>", "<Esc>ggVG", { desc = "Select All", silent = true })

-- ============================================================================
-- 6. WORD NAVIGATION & WORD/LINE DELETIONS
-- ============================================================================

local function move_word_right(mode)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local col = cursor[2]
  local cur_line = vim.api.nvim_get_current_line()
  local line_len = #cur_line
  local max_col = (mode == "i" or vim.o.virtualedit:find("onemore")) and line_len or math.max(0, line_len - 1)

  if col >= max_col then
    if row < vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
    end
    return
  end

  local sub = cur_line:sub(col + 1)
  local _, s_end = sub:find("^%s+")
  local offset = s_end or 0
  local rest = sub:sub(offset + 1)

  if #rest == 0 then
    vim.api.nvim_win_set_cursor(0, { row, max_col })
    return
  end

  local match_len = 0
  local first_char = rest:sub(1, 1)
  if first_char:match("[%w_]") then
    local _, w_end = rest:find("^[%w_]+")
    match_len = w_end or 1
  else
    local _, p_end = rest:find("^[^%w_%s]+")
    match_len = p_end or 1
  end

  local new_col = math.min(col + offset + match_len, max_col)
  vim.api.nvim_win_set_cursor(0, { row, new_col })
end

local function move_word_left(mode)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local col = cursor[2]

  if col <= 0 then
    if row > 1 then
      local prev_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1] or ""
      local prev_len = #prev_line
      local max_col = (mode == "i" or vim.o.virtualedit:find("onemore")) and prev_len or math.max(0, prev_len - 1)
      vim.api.nvim_win_set_cursor(0, { row - 1, max_col })
    end
    return
  end

  local cur_line = vim.api.nvim_get_current_line()
  local sub = cur_line:sub(1, col)
  local trimmed = sub:gsub("%s+$", "")
  local trimmed_len = #trimmed

  if trimmed_len == 0 then
    vim.api.nvim_win_set_cursor(0, { row, 0 })
    return
  end

  local last_char = trimmed:sub(trimmed_len, trimmed_len)
  local word_start = 1
  if last_char:match("[%w_]") then
    local s = trimmed:find("[%w_]+$")
    word_start = s or 1
  else
    local s = trimmed:find("[^%w_%s]+$")
    word_start = s or 1
  end

  local new_col = word_start - 1
  vim.api.nvim_win_set_cursor(0, { row, math.max(0, new_col) })
end

-- Word Left / Right (Ctrl+Left / Ctrl+Right & ANSI terminal sequences)
local ctrl_left_keys = { "<C-Left>", "<C-kLeft>", "\27[1;5D", "\27[5D", "\27[57419;5u" }
local ctrl_right_keys = { "<C-Right>", "<C-kRight>", "\27[1;5C", "\27[5C", "\27[57421;5u" }

for _, k in ipairs(ctrl_left_keys) do
  map({ "n", "x", "s" }, k, function() move_word_left("n") end, opts)
  map("i", k, function() move_word_left("i") end, opts)
end

for _, k in ipairs(ctrl_right_keys) do
  map({ "n", "x", "s" }, k, function() move_word_right("n") end, opts)
  map("i", k, function() move_word_right("i") end, opts)
end

-- Home & End (Line Start / End)
map({ "n", "i" }, "<Home>", "<C-o>^", opts)
map("v", "<Home>", "^", opts)
map({ "n", "i" }, "<End>", "<C-o>$", opts)
map("v", "<End>", "$", opts)

-- Ctrl+Home & Ctrl+End (File Start / End)
map({ "n", "i" }, "<C-Home>", "<C-o>gg", opts)
map("v", "<C-Home>", "gg", opts)
map({ "n", "i" }, "<C-End>", "<C-o>G", opts)
map("v", "<C-End>", "G", opts)

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

map({ "i", "n" }, "<C-BS>", delete_word_left, opts)
map({ "i", "n" }, "<M-BS>", delete_word_left, opts)
map({ "i", "n" }, "<C-w>", delete_word_left, { desc = "Delete Word Left", silent = true })

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

local c_del_keys = { "<C-Del>", "<M-Del>", "\27[3;5~" }
for _, k in ipairs(c_del_keys) do
  map({ "i", "n" }, k, delete_word_right, opts)
end

-- Delete Line (Ctrl+Shift+K)
map({ "n", "i" }, "<C-S-k>", cut_line, { desc = "Delete Current Line", silent = true })
map({ "v", "x" }, "<C-S-k>", "d", opts)

-- ============================================================================
-- 7. SELECTION (Shift+Arrows & Ctrl+Shift+Arrows Word Selection)
-- ============================================================================

local function select_word_right()
  local m = vim.fn.mode()
  if m == "i" then
    vim.cmd("stopinsert")
    vim.cmd("normal! v")
  elseif m == "n" then
    vim.cmd("normal! v")
  elseif m == "s" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>", true, false, true), "n", false)
  end
  move_word_right("v")
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>", true, false, true), "n", false)
end

local function select_word_left()
  local m = vim.fn.mode()
  if m == "i" then
    vim.cmd("stopinsert")
    vim.cmd("normal! v")
  elseif m == "n" then
    vim.cmd("normal! v")
  elseif m == "s" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>", true, false, true), "n", false)
  end
  move_word_left("v")
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>", true, false, true), "n", false)
end

-- Key codes for terminal compatibility (standard termcodes + xterm CSI + Kitty protocol sequences)
local c_s_left_keys = { "<C-S-Left>", "<C-S-kLeft>", "\27[1;6D", "\27[6D", "\27[57419;6u" }
local c_s_right_keys = { "<C-S-Right>", "<C-S-kRight>", "\27[1;6C", "\27[6C", "\27[57421;6u" }
local s_left_keys = { "\27[1;2D", "\27[2D", "\27[57419;2u" }
local s_right_keys = { "\27[1;2C", "\27[2C", "\27[57421;2u" }
local s_up_keys = { "\27[1;2A", "\27[2A", "\27[57418;2u" }
local s_down_keys = { "\27[1;2B", "\27[2B", "\27[57420;2u" }

for _, k in ipairs(c_s_left_keys) do
  map({ "n", "i", "v", "x", "s" }, k, select_word_left, { desc = "Select Word Left (Ctrl+Shift+Left)", silent = true })
end

for _, k in ipairs(c_s_right_keys) do
  map({ "n", "i", "v", "x", "s" }, k, select_word_right, { desc = "Select Word Right (Ctrl+Shift+Right)", silent = true })
end

for _, k in ipairs(s_left_keys) do
  map({ "i", "n", "v", "x", "s" }, k, "<S-Left>", { remap = true, silent = true })
end

for _, k in ipairs(s_right_keys) do
  map({ "i", "n", "v", "x", "s" }, k, "<S-Right>", { remap = true, silent = true })
end

for _, k in ipairs(s_up_keys) do
  map({ "i", "n", "v", "x", "s" }, k, "<S-Up>", { remap = true, silent = true })
end

for _, k in ipairs(s_down_keys) do
  map({ "i", "n", "v", "x", "s" }, k, "<S-Down>", { remap = true, silent = true })
end

-- Select Mode (<s-mode>) deselect on unshifted arrow keys and Home/End
map("s", "<Left>", "<Esc><cmd>startinsert<cr><Left>", { desc = "Deselect Left (Modeless)", silent = true })
map("s", "<Right>", "<Esc><cmd>startinsert<cr><Right>", { desc = "Deselect Right (Modeless)", silent = true })
map("s", "<Up>", "<Esc><cmd>startinsert<cr><Up>", { desc = "Deselect Up (Modeless)", silent = true })
map("s", "<Down>", "<Esc><cmd>startinsert<cr><Down>", { desc = "Deselect Down (Modeless)", silent = true })
map("s", "<Home>", "<Esc><cmd>startinsert<cr><C-o>^", { desc = "Start of Line Text", silent = true })
map("s", "<End>", "<Esc><cmd>startinsert<cr><C-o>$", { desc = "End of Line", silent = true })

-- ============================================================================
-- 8. AUTO-SURROUND SELECTION WITH QUOTES OR BRACKETS (VS Code style)
-- ============================================================================

local function wrap_selection(left, right)
  local reg_save = vim.fn.getreg('"')
  local regtype_save = vim.fn.getregtype('"')
  vim.cmd('normal! \x1bgv""y')
  local text = vim.fn.getreg('"')
  if not text or text == "" then
    vim.fn.setreg('"', reg_save, regtype_save)
    vim.cmd("startinsert")
    return
  end

  -- Intelligent Whitespace Handling:
  -- If text was selected with leading or trailing whitespace (e.g. from mouse drag,
  -- word selection, or double click), keep the whitespace OUTSIDE the quotes/brackets!
  local leading_ws = text:match("^(%s*)") or ""
  local trailing_ws = text:match("(%s*)$") or ""
  local trimmed = text:sub(#leading_ws + 1, #text - #trailing_ws)

  local wrapped
  if trimmed == "" then
    wrapped = left .. text .. right
  else
    wrapped = leading_ws .. left .. trimmed .. right .. trailing_ws
  end

  vim.fn.setreg('"', wrapped)
  vim.cmd('normal! gv""p')
  vim.fn.setreg('"', reg_save, regtype_save)

  -- Place cursor right after the closing quote/bracket in insert mode
  local cur = vim.api.nvim_win_get_cursor(0)
  local line_len = #vim.api.nvim_get_current_line()
  local target_col = math.min(cur[2] + 1, line_len)
  vim.api.nvim_win_set_cursor(0, { cur[1], target_col })
  vim.cmd("startinsert")
end

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
  map({ "v", "x", "s" }, trigger_key, function()
    wrap_selection(pair[1], pair[2])
  end, { desc = "Wrap selection with " .. pair[1] .. pair[2], silent = true })
end

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
-- 9. LINE MOVEMENT, DUPLICATION & COMMENTS
-- ============================================================================

-- Move Line Up / Down (Alt+Up / Alt+Down)
map({ "n", "i" }, "<A-Down>", "<Esc>:m .+1<CR>==gi", opts)
map({ "n", "i" }, "<A-Up>", "<Esc>:m .-2<CR>==gi", opts)
map({ "v", "x" }, "<A-Down>", ":m '>+1<CR>gv=gv", opts)
map({ "v", "x" }, "<A-Up>", ":m '<-2<CR>gv=gv", opts)

-- Duplicate Line (Shift+Alt+Down / Shift+Alt+Up)
map({ "n", "i" }, "<A-S-Down>", "<Esc>:t.<CR>gi", opts)
map({ "n", "i" }, "<A-S-Up>", "<Esc>:t.-1<CR>gi", opts)
map({ "v", "x" }, "<A-S-Down>", ":t'><CR>gv=gv", opts)
map({ "v", "x" }, "<A-S-Up>", ":t'<-1<CR>gv=gv", opts)

-- Insert Line Below / Above (Ctrl+Enter / Ctrl+Shift+Enter)
map({ "n", "i" }, "<C-CR>", "<Esc>o", opts)
map({ "n", "i" }, "<C-S-CR>", "<Esc>O", opts)

-- Indent / Unindent with Tab and Shift+Tab
map("v", "<Tab>", ">gv", opts)
map("v", "<S-Tab>", "<gv", opts)

-- Line & Block Commenting Handlers
local function ensure_comment()
  local ok_c, comment = pcall(require, "Comment")
  if ok_c and comment then
    local ok_cfg, cfg = pcall(require, "Comment.config")
    if ok_cfg and cfg and not cfg.state then
      comment.setup({})
    end
  end
end

local function ensure_commentstring()
  if vim.bo.commentstring == "" or not vim.bo.commentstring:find("%%s") then
    local ft = vim.bo.filetype
    local hash_fts = { python = true, sh = true, bash = true, yaml = true, toml = true, dockerfile = true, ruby = true, make = true }
    local dash_fts = { lua = true, sql = true }
    local html_fts = { html = true, xml = true, markdown = true }
    local css_fts = { css = true, scss = true, less = true }

    if hash_fts[ft] then
      vim.bo.commentstring = "# %s"
    elseif dash_fts[ft] then
      vim.bo.commentstring = "-- %s"
    elseif html_fts[ft] then
      vim.bo.commentstring = "<!-- %s -->"
    elseif css_fts[ft] then
      vim.bo.commentstring = "/* %s */"
    else
      vim.bo.commentstring = "// %s"
    end
  end
end

local function toggle_line_comment()
  ensure_comment()
  ensure_commentstring()
  local m = vim.fn.mode()
  if m == "v" or m == "V" or m == "\22" then
    local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
    vim.api.nvim_feedkeys(esc, "nx", false)
    local ok, Op = pcall(require, "Comment.opfunc")
    local ok_cfg, Config = pcall(require, "Comment.config")
    local ok_u, U = pcall(require, "Comment.utils")
    if ok and ok_cfg and ok_u then
      pcall(Op.opfunc, m, Config:get(), U.cmode.toggle, U.ctype.linewise)
    else
      pcall(vim.cmd, "normal! gvgc")
    end
  else
    local pos = vim.api.nvim_win_get_cursor(0)
    local ok, Op = pcall(require, "Comment.opfunc")
    local ok_cfg, Config = pcall(require, "Comment.config")
    local ok_u, U = pcall(require, "Comment.utils")
    if ok and ok_cfg and ok_u then
      pcall(Op.opfunc, nil, Config:get(), U.cmode.toggle, U.ctype.linewise)
    else
      pcall(vim.cmd, "normal! gcc")
    end
    pcall(vim.api.nvim_win_set_cursor, 0, pos)
  end
  if vim.bo.buftype == "" and vim.bo.modifiable then
    pcall(vim.cmd, "startinsert")
  end
end

local function toggle_block_comment()
  ensure_comment()
  ensure_commentstring()
  local m = vim.fn.mode()
  if m == "v" or m == "V" or m == "\22" then
    local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
    vim.api.nvim_feedkeys(esc, "nx", false)
    local ok, Op = pcall(require, "Comment.opfunc")
    local ok_cfg, Config = pcall(require, "Comment.config")
    local ok_u, U = pcall(require, "Comment.utils")
    if ok and ok_cfg and ok_u then
      pcall(Op.opfunc, m, Config:get(), U.cmode.toggle, U.ctype.blockwise)
    else
      pcall(vim.cmd, "normal! gvgb")
    end
  else
    local pos = vim.api.nvim_win_get_cursor(0)
    local ok, Op = pcall(require, "Comment.opfunc")
    local ok_cfg, Config = pcall(require, "Comment.config")
    local ok_u, U = pcall(require, "Comment.utils")
    if ok and ok_cfg and ok_u then
      pcall(Op.opfunc, nil, Config:get(), U.cmode.toggle, U.ctype.blockwise)
    else
      pcall(vim.cmd, "normal! gbc")
    end
    pcall(vim.api.nvim_win_set_cursor, 0, pos)
  end
  if vim.bo.buftype == "" and vim.bo.modifiable then
    pcall(vim.cmd, "startinsert")
  end
end

-- Toggle Line Comment (Ctrl+/ and Ctrl+_)
map({ "n", "i", "v" }, "<C-/>", toggle_line_comment, { desc = "Toggle Line Comment", silent = true })
map({ "n", "i", "v" }, "<C-_>", toggle_line_comment, { desc = "Toggle Line Comment", silent = true })
map({ "n", "i", "v" }, "<C-7>", toggle_line_comment, { desc = "Toggle Line Comment", silent = true })

-- Toggle Block Comment (Shift+Alt+A / Alt+Shift+A)
map({ "n", "i", "v" }, "<A-S-a>", toggle_block_comment, { desc = "Toggle Block Comment", silent = true })
map({ "n", "i", "v" }, "<M-A>", toggle_block_comment, { desc = "Toggle Block Comment", silent = true })

-- ============================================================================
-- 10. SEARCH, REPLACE & NAVIGATION PICKERS
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
map({ "n", "i" }, "<C-h>", function()
  local search = vim.fn.input("Find: ")
  if search and search ~= "" then
    local replace = vim.fn.input("Replace with: ")
    if replace then
      vim.cmd(string.format("%%s/%s/%s/gc", vim.fn.escape(search, "/"), vim.fn.escape(replace, "/")))
    end
  end
  if vim.bo.buftype == "" and vim.bo.modifiable then
    pcall(vim.cmd, "startinsert")
  end
end, { desc = "Replace in File", silent = true })

-- Go to Line (Ctrl+G)
map({ "n", "i" }, "<C-g>", function()
  local line = vim.fn.input("Go to Line: ")
  if line and tonumber(line) then
    vim.cmd(":" .. tonumber(line))
  end
  if vim.bo.buftype == "" and vim.bo.modifiable then
    pcall(vim.cmd, "startinsert")
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
-- 11. UI DOCKS: SIDEBAR, EDITOR & TERMINAL (Toggle & Direct Focus Switching)
-- ============================================================================

-- Direct Focus Functions
local function focus_sidebar()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      if ft:match("snacks_picker") or ft:match("snacks_explorer") or ft == "NvimTree" or ft == "neo-tree" then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  end
  require("minimal.components.tree").toggle()
end

local function focus_editor()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      local bt = vim.bo[buf].buftype
      local ft = vim.bo[buf].filetype
      if bt == "" and not ft:match("snacks") and not ft:match("explorer") and not ft:match("NvimTree") and not ft:match("neo%-tree") then
        vim.api.nvim_set_current_win(win)
        if vim.bo[buf].modifiable then
          pcall(vim.cmd, "startinsert")
        end
        return
      end
    end
  end
end

local function focus_terminal()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      local bt = vim.bo[buf].buftype
      local ft = vim.bo[buf].filetype
      if bt == "terminal" or ft == "snacks_terminal" or vim.b[buf].snacks_terminal then
        vim.api.nvim_set_current_win(win)
        pcall(vim.cmd, "startinsert")
        return
      end
    end
  end
  require("minimal.components.terminal").toggle()
end

-- Keymaps for direct focus:
-- Focus Sidebar: Ctrl+0, Ctrl+Shift+E, Alt+0
local focus_sidebar_keys = { "<C-0>", "<C-S-e>", "<C-S-E>", "<A-0>", "\27[48;5u" }
for _, k in ipairs(focus_sidebar_keys) do
  map({ "n", "i", "t", "v", "x", "s" }, k, focus_sidebar, { desc = "Focus Sidebar (VS Code Ctrl+0 / Ctrl+Shift+E)", silent = true })
end

-- Focus Editor: Ctrl+1, Alt+1, Alt+E
local focus_editor_keys = { "<C-1>", "<A-1>", "<A-e>", "<A-E>", "\27[49;5u" }
for _, k in ipairs(focus_editor_keys) do
  map({ "n", "i", "t", "v", "x", "s" }, k, focus_editor, { desc = "Focus Editor (VS Code Ctrl+1 / Alt+1)", silent = true })
end

-- Focus Terminal: Ctrl+2, Alt+2, Alt+T
local focus_term_keys = { "<C-2>", "<A-2>", "<A-t>", "<A-T>", "\27[50;5u" }
for _, k in ipairs(focus_term_keys) do
  map({ "n", "i", "t", "v", "x", "s" }, k, focus_terminal, { desc = "Focus Terminal (Ctrl+2 / Alt+2)", silent = true })
end

vim.api.nvim_create_user_command("FocusSidebar", focus_sidebar, { desc = "Focus Sidebar File Tree" })
vim.api.nvim_create_user_command("FocusEditor", focus_editor, { desc = "Focus Main Editor" })
vim.api.nvim_create_user_command("FocusTerminal", focus_terminal, { desc = "Focus Integrated Terminal" })

-- Toggle File Tree Sidebar (Ctrl+B across all modes: normal, insert, visual, terminal)
map({ "n", "i", "v", "t" }, "<C-b>", function()
  require("minimal.components.tree").toggle()
end, { desc = "Toggle Sidebar", silent = true })

-- ============================================================================
-- TERMINAL CLIENT RPC INTEGRATION (Zero Nested Instances)
-- ============================================================================

function _G.FocusEditorFromTerminal()
  pcall(function()
    if Snacks and Snacks.terminal then
      for _, t in ipairs(Snacks.terminal.list()) do
        if t:win_valid() then t:hide() end
      end
    end
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "terminal" or vim.bo[buf].filetype == "snacks_terminal" then
          pcall(vim.api.nvim_win_hide, win)
        end
      end
    end
  end)
  focus_editor()
  return "OK"
end

function _G.OpenFileFromTerminal(target_path)
  if not target_path or target_path == "" then
    return _G.FocusEditorFromTerminal()
  end
  local full = vim.fn.fnamemodify(vim.fn.expand(target_path), ":p")

  -- If target is a directory, change workspace
  if vim.fn.isdirectory(full) == 1 then
    vim.fn.chdir(full)
    pcall(function()
      if Snacks and Snacks.terminal then
        for _, t in ipairs(Snacks.terminal.list()) do
          if t:win_valid() then t:hide() end
        end
      end
      if Snacks and Snacks.explorer then
        Snacks.explorer({ cwd = full })
      end
    end)
    vim.notify("✓ Switched workspace: " .. full, vim.log.levels.INFO, { title = "Minimal Workspace" })
    return "OK"
  end

  -- Target is a file: hide terminal drawer to reveal editor
  pcall(function()
    if Snacks and Snacks.terminal then
      for _, t in ipairs(Snacks.terminal.list()) do
        if t:win_valid() then t:hide() end
      end
    end
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "terminal" or vim.bo[buf].filetype == "snacks_terminal" then
          pcall(vim.api.nvim_win_hide, win)
        end
      end
    end
  end)

  focus_editor()
  vim.cmd("edit " .. vim.fn.fnameescape(full))
  vim.cmd("startinsert")
  vim.notify("✓ Opened: " .. vim.fn.fnamemodify(full, ":t"), vim.log.levels.INFO, { title = "Minimal Editor" })
  return "OK"
end

-- Toggle Terminal Drawer (Ctrl+`, Ctrl+~, Ctrl+Shift+`, Ctrl+Shift+~, Ctrl+^, Ctrl+@, Ctrl+J across ALL modes)
local term_toggle_keys = {
  "<C-`>",
  "<C-~>",
  "<C-S-`>",
  "<C-S-~>",
  "<C-^>",
  "<C-@>",
  "<C-j>",
  "\27[96;5u",
  "\27[96;6u",
  "\27[126;5u",
  "\27[126;6u",
}
for _, key in ipairs(term_toggle_keys) do
  map({ "n", "i", "t", "v" }, key, function()
    require("minimal.components.terminal").toggle()
  end, { desc = "Toggle Terminal Drawer", silent = true })
end

-- New Terminal Instance (dedicated shortcut, preventing Ctrl+~ accidental split)
map({ "n", "i", "t", "v" }, "<leader>tn", function()
  require("minimal.components.terminal").new_instance()
end, { desc = "New Terminal Instance", silent = true })

-- Run Code (F5) & Stop Code (Shift+F5)
map({ "n", "i" }, "<F5>", function()
  require("minimal.components.runner").run()
end, { desc = "Run Code (F5)", silent = true })

map({ "n", "i" }, "<S-F5>", function()
  require("minimal.components.runner").stop()
end, { desc = "Stop Code (Shift+F5)", silent = true })

-- Theme Switcher (Ctrl+K Ctrl+T)
map({ "n", "i" }, "<C-k><C-t>", function()
  require("minimal.themes.engine").theme_picker()
end, { desc = "Preferences: Color Theme", silent = true })

-- Toggle Transparency (Ctrl+K Ctrl+U)
map({ "n", "i" }, "<C-k><C-u>", function()
  require("minimal.themes.engine").toggle_transparency()
end, { desc = "Toggle Transparency", silent = true })

-- ============================================================================
-- 12. LANGUAGE SERVER (LSP) SHORTCUTS
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

-- Quick Fix / Solutions (Ctrl+., Alt+Enter, Cmd+.) - Unified with Code Spell Checker & LSP Code Actions
local quick_fix_keys = { "<C-.>", "<M-CR>", "\27[46;5u", "<D-.>" }
for _, k in ipairs(quick_fix_keys) do
  map({ "n", "i", "v", "x" }, k, function()
    require("minimal.components.spell").quick_fix()
  end, { desc = "Quick Fix / Solutions (Ctrl+.)", silent = true })
end

-- Code Spell Checker (F7)
map({ "n", "i" }, "<F7>", function()
  require("minimal.components.spell").check()
end, { desc = "Code Spell Checker (F7)", silent = true })

vim.api.nvim_create_user_command("QuickFix", function()
  require("minimal.components.spell").quick_fix()
end, { desc = "Quick Fix / Solutions" })

vim.api.nvim_create_user_command("CodeAction", function()
  require("minimal.components.spell").quick_fix()
end, { desc = "Quick Fix / Code Actions" })

vim.api.nvim_create_user_command("SpellCheck", function()
  require("minimal.components.spell").check()
end, { desc = "Code Spell Checker Autocorrect" })

vim.api.nvim_create_user_command("FixSpelling", function()
  require("minimal.components.spell").check()
end, { desc = "Code Spell Checker Autocorrect" })

-- Format Document (Shift+Alt+F)
map({ "n", "i", "v" }, "<A-S-f>", function()
  local ok, conform = pcall(require, "conform")
  if ok and conform then
    conform.format({ async = true, lsp_format = "fallback" }, function(err)
      if not err then
        vim.notify("Formatted document successfully", vim.log.levels.INFO, { title = "Minimal Formatter" })
      end
    end)
  else
    vim.lsp.buf.format({ async = true })
  end
  if vim.bo.buftype == "" and vim.bo.modifiable then
    pcall(vim.cmd, "startinsert")
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
-- 13. TERMINAL MODE (POSIX Word Nav & Swapped Resize)
-- ============================================================================

-- In terminal mode: Ctrl+Left/Right jump words using POSIX readline escapes
map("t", "<C-Left>", "<Esc>b", opts)
map("t", "<C-Right>", "<Esc>f", opts)

-- In terminal mode: Ctrl+Backspace deletes word
map("t", "<C-BS>", "<C-w>", opts)
map("t", "<M-BS>", "<C-w>", opts)

-- Terminal Resize: Ctrl+Up increases height (taller), Ctrl+Down decreases height (shorter)
local function resize_terminal_up()
  require("minimal.components.terminal").resize(2)
end

local function resize_terminal_down()
  require("minimal.components.terminal").resize(-2)
end

local ctrl_up_keys = { "<C-Up>", "\27[1;5A", "\27[5A", "\27[57418;5u" }
local ctrl_down_keys = { "<C-Down>", "\27[1;5B", "\27[5B", "\27[57420;5u" }

for _, k in ipairs(ctrl_up_keys) do
  map("t", k, resize_terminal_up, { desc = "Expand Terminal Height (Ctrl+Up)", silent = true })
  map("n", k, function()
    local resized = require("minimal.components.terminal").resize(2)
    if not resized then
      vim.cmd("normal! 5<C-y>")
    end
  end, { desc = "Expand Terminal / Scroll Up", silent = true })
end

for _, k in ipairs(ctrl_down_keys) do
  map("t", k, resize_terminal_down, { desc = "Shrink Terminal Height (Ctrl+Down)", silent = true })
  map("n", k, function()
    local resized = require("minimal.components.terminal").resize(-2)
    if not resized then
      vim.cmd("normal! 5<C-e>")
    end
  end, { desc = "Shrink Terminal / Scroll Down", silent = true })
end

-- Escape terminal mode with Esc Esc
map("t", "<Esc><Esc>", "<C-\\><C-n>", opts)
