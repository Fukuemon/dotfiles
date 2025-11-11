-- Mason LSP Config: MasonでインストールしたLSPを自動設定

return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = { "williamboman/mason.nvim" },
  config = function()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "gopls",
        "ts_ls",
        "pyright",
        "html",
        "cssls",
        "emmet_ls",
        "rust_analyzer",
        "clangd",
        "yamlls",
        "jsonls",
      },
    })
  end,
}

