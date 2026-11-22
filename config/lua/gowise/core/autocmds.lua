-- Gowise Core Autocommands
local api = vim.api

local gowise_group = api.nvim_create_augroup("GowiseCore", { clear = true })

-- 1. Smart Directory Creation on Save
-- If you run: gowise some/new/folder/file.go and save, automatically creates parent folders
api.nvim_create_autocmd("BufWritePre", {
  group = gowise_group,
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    local dir = vim.fn.fnamemodify(file, ":p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- 2. Restore Cursor Position on File Open
api.nvim_create_autocmd("BufReadPost", {
  group = gowise_group,
  callback = function(args)
    local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) <= vim.fn.line("$")
    local not_commit = vim.b[args.buf].filetype ~= "gitcommit"
    if valid_line and not_commit then
      vim.cmd([[normal! g`"]])
    end
  end,
})

-- 3. Highlight on Copy (Yank Feedback)
api.nvim_create_autocmd("TextYankPost", {
  group = gowise_group,
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})

-- 4. Clean Terminal Experience
-- When entering terminal drawer, disable line numbers and start insert mode immediately
api.nvim_create_autocmd("TermOpen", {
  group = gowise_group,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.cursorline = false
    vim.cmd("startinsert")
  end,
})

-- 5. Auto Format on Save (Handled cleanly by conform.nvim or LSP fallback)
api.nvim_create_autocmd("BufWritePre", {
  group = gowise_group,
  callback = function(args)
    if vim.g.gowise_format_on_save ~= false then
      local ok, conform = pcall(require, "conform")
      if ok and conform then
        conform.format({ bufnr = args.buf, timeout_ms = 1500, lsp_format = "fallback" })
      else
        local clients = vim.lsp.get_clients({ bufnr = args.buf })
        for _, client in ipairs(clients) do
          if client:supports_method("textDocument/formatting") then
            vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 1000 })
            break
          end
        end
      end
    end
  end,
})

-- 6. Auto-resize splits when window is resized
api.nvim_create_autocmd("VimResized", {
  group = gowise_group,
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})
