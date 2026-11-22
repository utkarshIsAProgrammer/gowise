-- Gowise Polyglot LSP Servers Setup
-- Native Neovim 0.12 LSP configuration with Mason auto-installer

local M = {}

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
    root_dir = function(fname)
      return vim.fs.root(fname, { ".git", "package.json", "index.html" })
        or vim.fs.dirname(fname)
        or vim.fn.getcwd()
    end,
  },
}

function M.setup()
  -- Capabilities integration with blink.cmp
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_blink, blink = pcall(require, "blink.cmp")
  if ok_blink then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  local ok_lspconfig, lspconfig = pcall(require, "lspconfig")

  for server, user_config in pairs(M.servers) do
    local s_config = vim.deepcopy(user_config)
    s_config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, s_config.capabilities or {})

    if not s_config.root_dir then
      s_config.root_dir = function(fname)
        return vim.fs.root(fname, { ".git", "package.json", "go.mod", "Cargo.toml", "index.html" })
          or vim.fs.dirname(fname)
          or vim.fn.getcwd()
      end
    end

    if ok_lspconfig and lspconfig and lspconfig[server] then
      pcall(function()
        lspconfig[server].setup(s_config)
      end)
    elseif vim.lsp.config and vim.lsp.enable then
      vim.lsp.config(server, s_config)
      vim.lsp.enable(server)
    end
  end
end

return M
