-- Gowise Polyglot LSP Servers Setup
-- Native Neovim 0.12 LSP configuration with Mason auto-installer

local M = {}

local function make_root_dir_fn(custom_markers)
  local markers = custom_markers or { ".git", "package.json", "go.mod", "Cargo.toml", "index.html" }
  return function(bufnr, on_dir)
    local fname = type(bufnr) == "number" and vim.api.nvim_buf_get_name(bufnr) or bufnr or ""
    local root = nil
    if fname ~= "" then
      root = vim.fs.root(fname, markers) or vim.fs.dirname(fname)
    end
    root = root or vim.fn.getcwd()
    if type(on_dir) == "function" then
      on_dir(root)
    end
    return root
  end
end

M.servers = {
  gopls = {
    settings = {
      gopls = {
        analyses = { unusedparams = true, shadow = true },
        staticcheck = true,
        completeUnimported = true,
        usePlaceholders = true,
      },
    },
  },
  ts_ls = {},
  pyright = {},
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = { command = "clippy" },
      },
    },
  },
  clangd = {},
  bashls = {},
  jsonls = {},
  html = {},
  cssls = {},
  emmet_language_server = {
    cmd = { "emmet-language-server", "--stdio" },
    filetypes = {
      "html", "css", "sass", "scss", "less",
      "javascript", "javascriptreact",
      "typescript", "typescriptreact",
      "vue", "svelte", "markdown",
    },
    root_markers = { ".git", "package.json", "index.html" },
    root_dir = make_root_dir_fn({ ".git", "package.json", "index.html" }),
  },
}

function M.setup()
  -- Capabilities integration with blink.cmp
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_blink, blink = pcall(require, "blink.cmp")
  if ok_blink then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  local is_native_lsp = (vim.lsp.config ~= nil and vim.lsp.enable ~= nil)

  for server, user_config in pairs(M.servers) do
    local s_config = vim.deepcopy(user_config)
    s_config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, s_config.capabilities or {})
    s_config.flags = vim.tbl_deep_extend("force", { debounce_text_changes = 150 }, s_config.flags or {})

    if not s_config.root_dir and not s_config.root_markers then
      s_config.root_markers = { ".git", "package.json", "go.mod", "Cargo.toml", "index.html" }
      s_config.root_dir = make_root_dir_fn()
    end

    if is_native_lsp then
      vim.lsp.config(server, s_config)
      vim.lsp.enable(server)
    else
      local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
      if ok_lspconfig and lspconfig and lspconfig[server] then
        pcall(function()
          lspconfig[server].setup(s_config)
        end)
      end
    end
  end
end

return M
