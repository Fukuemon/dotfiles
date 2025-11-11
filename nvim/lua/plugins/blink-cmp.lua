-- blink.cmp: 補完プラグイン

return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = { "rafamadriz/friendly-snippets" },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    keymap = { preset = "default" },
    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      nerd_font_variant = "mono",
    },
    -- (Default) Only show the documentation popup when manually triggered
    completion = { documentation = { auto_show = false } },
    -- Default list of enabled providers
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    -- Rust fuzzy matcher for typo resistance and significantly better performance
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}

