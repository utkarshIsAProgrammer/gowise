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
}

function M.setup()
  local ok, lspconfig = pcall(require, "lspconfig")
  if not ok then return end

  -- Capabilities integration with blink.cmp
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_blink, blink = pcall(require, "blink.cmp")
  if ok_blink then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  for server, config in pairs(M.servers) do
    config.capabilities = capabilities
    lspconfig[server].setup(config)
  end
end

return M
