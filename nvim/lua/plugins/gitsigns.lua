-- Gitsigns: git gutter

return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup({
      on_attach = function(bufnr)
        vim.keymap.set("n", "<leader>hn", require("gitsigns").next_hunk, { buffer = bufnr })
        vim.keymap.set("n", "<leader>hp", require("gitsigns").prev_hunk, { buffer = bufnr })
      end,
    })
  end,
}

