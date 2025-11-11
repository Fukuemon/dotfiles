-- LSP設定ファイル
-- Ref: https://zenn.dev/ras96/articles/4d9d9493d29c06

-- blink.cmpのLSP capabilitiesを取得
local capabilities = vim.lsp.protocol.make_client_capabilities()
if pcall(require, "blink.cmp") then
  capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
end

-- 共通設定
local on_attach = function(client, bufnr)
  -- キーマッピング
  local opts = { noremap = true, silent = true, buffer = bufnr }

  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
  vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, opts)

  -- 保存時に自動フォーマット
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspFormat", { clear = false }),
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 1000 })
      end,
    })
  end

  -- インライン補完の設定
  if client.supports_method("textDocument/inlineCompletion") then
    vim.lsp.inline_completion.enable(true, { bufnr = bufnr })
    vim.keymap.set("i", "<Tab>", function()
      if not vim.lsp.inline_completion.get() then
        return "<Tab>"
      end
      -- close the completion popup if it's open
      if vim.fn.pumvisible() == 1 then
        return "<C-e>"
      end
    end, {
      expr = true,
      buffer = bufnr,
      desc = "Accept the current inline completion",
    })
  end
end

-- Go
vim.lsp.config("gopls", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- TypeScript/JavaScript
vim.lsp.config("ts_ls", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Python
vim.lsp.config("pyright", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- HTML
vim.lsp.config("html", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- CSS
vim.lsp.config("cssls", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Emmet (HTML/CSS)
vim.lsp.config("emmet_ls", {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact" },
})

-- Rust
vim.lsp.config("rust_analyzer", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- C
vim.lsp.config("clangd", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- YAML
vim.lsp.config("yamlls", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- JSON
vim.lsp.config("jsonls", {
  on_attach = on_attach,
  capabilities = capabilities,
})

