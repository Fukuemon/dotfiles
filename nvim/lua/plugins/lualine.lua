-- Lualine: ステータスライン

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "ntk148v/vim-horizon" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "horizon",
      },
    })
  end,
}

