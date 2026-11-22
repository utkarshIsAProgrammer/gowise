-- ============================================================================
-- Gowise Universal Keymaps (100% Modeless VS Code & Zed Parity)
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
  if ft == "snacks_dashboard" or ft:find("dashboard") or ft:find("picker") or ft:find("snacks") then
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
      and vim.fn.mode() ~= "i"
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
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "InsertLeave", "FocusGained", "VimEnter", "ModeChanged" }, {
  callback = function(args)
    if args.event == "ModeChanged" and not args.match:find(":n") then
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

-- Neutralize Normal Mode: Any printable character typed in an editable document
-- immediately starts typing that character. Zero Vim single-key commands can execute.
local function bind_normal_mode_typing()
  for code = 32, 126 do
    local char = string.char(code)
    local key_repr = char
    if char == " " then
      key_repr = "<Space>"
    elseif char == "|" then
      key_repr = "<Bar>"
    elseif char == "\\" then
      key_repr = "<Bslash>"
    end
    map("n", key_repr, function()
      local cur_buf = vim.api.nvim_get_current_buf()
      local ft = vim.bo[cur_buf].filetype
      local bt = vim.bo[cur_buf].buftype

      -- If on dashboard and user starts typing (not a menu hotkey), open new buffer and type immediately
      if ft == "snacks_dashboard" then
        local dashboard_keys = { n = 1, p = 1, f = 1, r = 1, t = 1, b = 1, j = 1, d = 1, q = 1 }
        if not dashboard_keys[char:lower()] then
          vim.cmd("ene")
          pcall(vim.cmd, "startinsert")
          return "i" .. char
        end
        return char
      end

      -- If inside picker, explorer, or terminal, preserve their keys
      if ft:find("picker") or ft:find("explorer") or bt == "terminal" then
        return char
      end

      -- If regular buffer is not modifiable, ensure modifiable if not readonly
      if bt == "" and not vim.bo[cur_buf].modifiable and not vim.bo[cur_buf].readonly then
        pcall(function() vim.bo[cur_buf].modifiable = true end)
      end

      if bt == "" and vim.bo[cur_buf].modifiable then
        return "i" .. char
      end

      -- In any other non-modifiable buffer (help, floating docs, etc.), never execute destructive normal commands like 'c'/'d'/'x'
      return ""
    end, { expr = true, silent = true, desc = "Type " .. char .. " (100% Modeless)" })
  end
end
bind_normal_mode_typing()

-- Normal Mode Enter & Backspace: behave like a normal editor
map("n", "<CR>", function()
  local bt = vim.bo.buftype
  local ft = vim.bo.filetype
  if bt == "" and ft ~= "snacks_dashboard" then
    if not vim.bo.modifiable and not vim.bo.readonly then
      pcall(function() vim.bo.modifiable = true end)
    end
    if vim.bo.modifiable then
      return "o"
    end
  end
  return "<CR>"
end, { expr = true, silent = true })

map("n", "<BS>", function()
  local bt = vim.bo.buftype
  local ft = vim.bo.filetype
  if bt == "" and ft ~= "snacks_dashboard" then
    if not vim.bo.modifiable and not vim.bo.readonly then
      pcall(function() vim.bo.modifiable = true end)
    end
    if vim.bo.modifiable then
      return "i<BS>"
    end
  end
  return "<BS>"
end, { expr = true, silent = true })

map("n", "<Del>", function()
  local bt = vim.bo.buftype
  local ft = vim.bo.filetype
  if bt == "" and ft ~= "snacks_dashboard" then
    if not vim.bo.modifiable and not vim.bo.readonly then
      pcall(function() vim.bo.modifiable = true end)
    end
    if vim.bo.modifiable then
      return '"_x'
    end
  end
  return "<Del>"
end, { expr = true, silent = true })

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
    require("gowise.components.tree").toggle()
    return
  end

  -- If inside terminal drawer, hide it
  if ft == "snacks_terminal" or bt == "terminal" then
    require("gowise.components.terminal").toggle()
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

map({ "n", "i", "s", "x" }, "<Esc>", handle_escape, { nowait = true, desc = "Dismiss Popups / Deselect (Modeless Esc)" })
map({ "n", "i", "s", "x" }, "<S-Esc>", handle_escape, { nowait = true, desc = "Dismiss Popups / Deselect (Modeless Esc)" })
_G.handle_escape = handle_escape

-- ============================================================================
-- 3. FILE, BUFFER & TAB MANAGEMENT
-- ============================================================================

local function smart_save()
  local buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(buf)
  pcall(function() vim.cmd("silent write") end)
  if vim.bo.buftype == "" and vim.bo.modifiable then
    pcall(vim.cmd, "startinsert")
  end
  local fname = buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":t") or "[Untitled]"
  vim.notify("✓ Saved: " .. fname, vim.log.levels.INFO, { title = "Gowise" })
end

local function smart_save_all()
  pcall(function() vim.cmd("silent wa") end)
  if vim.bo.buftype == "" and vim.bo.modifiable then
    pcall(vim.cmd, "startinsert")
  end
  vim.notify("✓ Saved all files", vim.log.levels.INFO, { title = "Gowise" })
end

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

-- Save File (Ctrl+S)
map({ "n", "i", "v", "x" }, "<C-s>", smart_save, { desc = "Save File (Ctrl+S)", silent = true })

-- Save All (Ctrl+Shift+S)
map({ "n", "i", "v", "x" }, "<C-S-s>", smart_save_all, { desc = "Save All Files", silent = true })

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
  vim.notify("Selection copied to clipboard", vim.log.levels.INFO, { title = "Gowise Clipboard" })
end

local function copy_line()
  local line = vim.api.nvim_get_current_line()
  vim.fn.setreg('+', line .. '\n', 'l')
  vim.fn.setreg('*', line .. '\n', 'l')
  vim.fn.setreg('"', line .. '\n', 'l')
  vim.notify("Line copied to clipboard", vim.log.levels.INFO, { title = "Gowise Clipboard" })
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

-- Word Left / Right (Ctrl+Left / Ctrl+Right & ANSI terminal sequences)
local function move_word_left_insert()
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
  vim.api.nvim_feedkeys(esc, "nx", false)
  vim.cmd("normal! b")
  vim.cmd("startinsert")
end

local function move_word_right_insert()
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
  vim.api.nvim_feedkeys(esc, "nx", false)
  vim.cmd("normal! w")
  vim.cmd("startinsert")
end

local ctrl_left_keys = { "<C-Left>", "<C-kLeft>", "\27[1;5D", "\27[5D", "\27[57419;5u" }
local ctrl_right_keys = { "<C-Right>", "<C-kRight>", "\27[1;5C", "\27[5C", "\27[57421;5u" }

for _, k in ipairs(ctrl_left_keys) do
  map("n", k, "b<cmd>startinsert<cr>", opts)
  map("v", k, "b", opts)
  map("i", k, move_word_left_insert, opts)
end

for _, k in ipairs(ctrl_right_keys) do
  map("n", k, "w<cmd>startinsert<cr>", opts)
  map("v", k, "w", opts)
  map("i", k, move_word_right_insert, opts)
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

local function is_word_char(ch)
  if not ch or ch == "" then return false end
  return ch:match("[%w_]") ~= nil
end

local function select_word_right_vis()
  local vpos = vim.fn.getpos("v")
  local cpos = vim.fn.getpos(".")
  local cmp = (cpos[2] > vpos[2] or (cpos[2] == vpos[2] and cpos[3] >= vpos[3])) and 1 or -1
  if cmp >= 0 then
    local old_c = vim.fn.getpos(".")
    vim.cmd("normal! e")
    local new_c = vim.fn.getpos(".")
    if old_c[2] == new_c[2] and old_c[3] == new_c[3] then
      vim.cmd("normal! w")
    end
  else
    vim.cmd("normal! w")
    local new_c = vim.fn.getpos(".")
    if new_c[2] > vpos[2] or (new_c[2] == vpos[2] and new_c[3] >= vpos[3]) then
      vim.cmd("normal! e")
    end
  end
end

local function select_word_left_vis()
  local vpos = vim.fn.getpos("v")
  local cpos = vim.fn.getpos(".")
  local cmp = (cpos[2] < vpos[2] or (cpos[2] == vpos[2] and cpos[3] <= vpos[3])) and -1 or 1
  if cmp <= 0 then
    local old_c = vim.fn.getpos(".")
    vim.cmd("normal! b")
    local new_c = vim.fn.getpos(".")
    if old_c[2] == new_c[2] and old_c[3] == new_c[3] then
      vim.cmd("normal! ge")
    end
  else
    vim.cmd("normal! ge")
    local new_c = vim.fn.getpos(".")
    if new_c[2] < vpos[2] or (new_c[2] == vpos[2] and new_c[3] <= vpos[3]) then
      vim.cmd("normal! b")
    end
  end
end

local function select_word_right_norm()
  local cur = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  if #line == 0 then return end
  local ch = line:sub(cur[2] + 1, cur[2] + 1)
  if is_word_char(ch) then
    vim.cmd("normal! viw")
  else
    vim.cmd("normal! ve")
  end
end

local function select_word_left_norm()
  local cur = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  if #line == 0 then return end
  local ch = line:sub(cur[2] + 1, cur[2] + 1)
  if is_word_char(ch) then
    vim.cmd("normal! viwo")
  else
    vim.cmd("normal! vb")
  end
end

-- Key codes for terminal compatibility (standard termcodes + xterm CSI + Kitty protocol sequences)
local c_s_left_keys = { "<C-S-Left>", "<C-S-kLeft>", "\27[1;6D", "\27[6D", "\27[57419;6u" }
local c_s_right_keys = { "<C-S-Right>", "<C-S-kRight>", "\27[1;6C", "\27[6C", "\27[57421;6u" }
local s_left_keys = { "<S-Left>", "\27[1;2D", "\27[2D", "\27[57419;2u" }
local s_right_keys = { "<S-Right>", "\27[1;2C", "\27[2C", "\27[57421;2u" }
local s_up_keys = { "<S-Up>", "\27[1;2A", "\27[2A", "\27[57418;2u" }
local s_down_keys = { "<S-Down>", "\27[1;2B", "\27[2B", "\27[57420;2u" }

for _, k in ipairs(c_s_left_keys) do
  map("n", k, select_word_left_norm, { desc = "Select Word Left", silent = true })
  map("i", k, "<Esc>viwo", { desc = "Select Word Left", silent = true })
  map({ "v", "x" }, k, select_word_left_vis, { desc = "Select Word Left", silent = true })
end

for _, k in ipairs(c_s_right_keys) do
  map("n", k, select_word_right_norm, { desc = "Select Word Right", silent = true })
  map("i", k, "<Esc>lviw", { desc = "Select Word Right", silent = true })
  map({ "v", "x" }, k, select_word_right_vis, { desc = "Select Word Right", silent = true })
end

for _, k in ipairs(s_left_keys) do
  map("n", k, "vh", { desc = "Select Left Character", silent = true })
  map("i", k, "<Esc>v", { desc = "Select Left Character", silent = true })
  map({ "v", "x" }, k, "h", { desc = "Select Left Character", silent = true })
end

for _, k in ipairs(s_right_keys) do
  map("n", k, "vl", { desc = "Select Right Character", silent = true })
  map("i", k, "<Esc>lv", { desc = "Select Right Character", silent = true })
  map({ "v", "x" }, k, "l", { desc = "Select Right Character", silent = true })
end

for _, k in ipairs(s_up_keys) do
  map("n", k, "vk", { desc = "Select Line Up", silent = true })
  map("i", k, "<Esc>vk", { desc = "Select Line Up", silent = true })
  map({ "v", "x" }, k, "k", { desc = "Select Line Up", silent = true })
end

for _, k in ipairs(s_down_keys) do
  map("n", k, "vj", { desc = "Select Line Down", silent = true })
  map("i", k, "<Esc>vj", { desc = "Select Line Down", silent = true })
  map({ "v", "x" }, k, "j", { desc = "Select Line Down", silent = true })
end

-- ============================================================================
-- 8. AUTO-SURROUND SELECTION WITH QUOTES OR BRACKETS (VS Code style)
-- ============================================================================

local function wrap_selection(open_delim, close_delim)
  local mode = vim.fn.visualmode()
  if mode == "" then mode = vim.fn.mode() end
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

  if s_row > e_row or (s_row == e_row and s_col >= e_col) then return end

  local lines = vim.api.nvim_buf_get_text(0, s_row, s_col, e_row, e_col, {})
  if #lines == 0 then return end

  if #lines == 1 then
    lines[1] = open_delim .. lines[1] .. close_delim
  else
    lines[1] = open_delim .. lines[1]
    lines[#lines] = lines[#lines] .. close_delim
  end

  vim.api.nvim_buf_set_text(0, s_row, s_col, e_row, e_col, lines)

  if #lines == 1 then
    vim.api.nvim_win_set_cursor(0, { e_row + 1, e_col + #open_delim + #close_delim - 1 })
  else
    vim.api.nvim_win_set_cursor(0, { e_row + 1, #lines[#lines] - 1 })
  end
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
  map({ "v", "x" }, trigger_key, function()
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
-- 11. UI DOCKS: SIDEBAR & TERMINAL (Toggleable from ALL modes without Esc!)
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

-- Toggle Transparency (Ctrl+K Ctrl+U)
map({ "n", "i" }, "<C-k><C-u>", function()
  require("gowise.themes.engine").toggle_transparency()
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
  require("gowise.components.terminal").resize(2)
end

local function resize_terminal_down()
  require("gowise.components.terminal").resize(-2)
end

local ctrl_up_keys = { "<C-Up>", "\27[1;5A", "\27[5A", "\27[57418;5u" }
local ctrl_down_keys = { "<C-Down>", "\27[1;5B", "\27[5B", "\27[57420;5u" }

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
