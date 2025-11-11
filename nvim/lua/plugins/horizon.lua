-- カラースキーム: vim-horizon

return {
  "ntk148v/vim-horizon",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd("colorscheme horizon")
    vim.api.nvim_set_hl(0, "Normal", { bg = "#2e2e2e", fg = "#ffffff" })
    vim.api.nvim_set_hl(0, "Cursor", { fg = "black", bg = "white" })
    vim.api.nvim_set_hl(0, "lCursor", { fg = "white", bg = "black" })
    vim.api.nvim_set_hl(0, "Visual", { bg = "#44475a", fg = "NONE" })
    vim.opt.guicursor = "n-v-c:block-Cursor/lCursor"
  end,
}

