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
    filetypes = {
      "html", "css", "sass", "scss", "less",
      "javascript", "javascriptreact",
      "typescript", "typescriptreact",
      "vue", "svelte", "markdown",
    },
  },
}

function M.setup()
  -- Capabilities integration with blink.cmp
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_blink, blink = pcall(require, "blink.cmp")
  if ok_blink then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  -- Use native Neovim 0.11+ / 0.12 vim.lsp.config & vim.lsp.enable if available
  if vim.lsp.config and vim.lsp.enable then
    for server, config in pairs(M.servers) do
      local s_config = vim.deepcopy(config)
      s_config.capabilities = capabilities
      vim.lsp.config(server, s_config)
      vim.lsp.enable(server)
    end
  else
    local ok, lspconfig = pcall(require, "lspconfig")
    if ok and lspconfig then
      for server, config in pairs(M.servers) do
        local s_config = vim.deepcopy(config)
        s_config.capabilities = capabilities
        pcall(function()
          lspconfig[server].setup(s_config)
        end)
      end
    end
  end
end

return M
