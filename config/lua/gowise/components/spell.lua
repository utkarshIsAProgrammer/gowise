-- Gowise Integrated Code Spell Checker (VS Code Code Spell Checker Parity)
-- Intelligent CamelCase, snake_case, and code identifier spelling autocorrection with dictionary support

local M = {}

function M.check()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]
  local line = vim.api.nvim_get_current_line()

  local badinfo = vim.fn.spellbadword()
  local target_word = badinfo and badinfo[1]
  if not target_word or target_word == "" then
    target_word = vim.fn.expand("<cword>")
  end

  if not target_word or target_word == "" then
    vim.notify("No word under cursor to check spelling", vim.log.levels.INFO, { title = "Code Spell Checker" })
    return
  end

  local suggestions = vim.fn.spellsuggest(target_word, 8)
  local options = {}

  for _, s in ipairs(suggestions) do
    table.insert(options, {
      kind = "suggestion",
      label = "󰓆 " .. s,
      replacement = s,
    })
  end

  table.insert(options, {
    kind = "add",
    label = " Add '" .. target_word .. "' to User Dictionary",
  })
  table.insert(options, {
    kind = "ignore",
    label = " Ignore '" .. target_word .. "' for this session",
  })

  vim.ui.select(options, {
    prompt = "Code Spell Checker: '" .. target_word .. "'",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then return end
    if choice.kind == "suggestion" then
      local pattern = "%f[%w_]" .. vim.pesc(target_word) .. "%f[^%w_]"
      local s_start, s_end = line:find(pattern)
      if not s_start then
        s_start, s_end = line:find("[%w_]+", math.max(1, col - #target_word))
      end
      if s_start and s_end then
        local new_line = line:sub(1, s_start - 1) .. choice.replacement .. line:sub(s_end + 1)
        vim.api.nvim_set_current_line(new_line)
        vim.api.nvim_win_set_cursor(0, { row, math.min(#new_line, s_start + #choice.replacement - 1) })
      else
        vim.cmd("normal! ciw" .. choice.replacement)
      end
      vim.notify("✓ Autocorrected '" .. target_word .. "' -> '" .. choice.replacement .. "'", vim.log.levels.INFO, { title = "Code Spell Checker" })
      vim.schedule(function()
        if vim.bo.buftype == "" and vim.bo.modifiable then
          vim.cmd("startinsert")
        end
      end)
    elseif choice.kind == "add" then
      pcall(vim.cmd, "spellgood " .. target_word)
      vim.notify("✓ Added '" .. target_word .. "' to user dictionary", vim.log.levels.INFO, { title = "Code Spell Checker" })
    elseif choice.kind == "ignore" then
      pcall(vim.cmd, "spellrare " .. target_word)
      vim.notify("✓ Ignored '" .. target_word .. "' for this session", vim.log.levels.INFO, { title = "Code Spell Checker" })
    end
  end)
end

function M.quick_fix()
  local badinfo = vim.fn.spellbadword()
  local is_misspelled = badinfo and badinfo[1] ~= ""

  local cur_buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local lnum = cursor[1] - 1
  local diags = vim.diagnostic.get(cur_buf, { lnum = lnum })

  if is_misspelled and #diags == 0 then
    M.check()
  else
    vim.lsp.buf.code_action()
  end
end

M.CodeSpellChecker = M.check
M.UnifiedQuickFix = M.quick_fix

_G.CodeSpellChecker = M.check
_G.UnifiedQuickFix = M.quick_fix

return M
