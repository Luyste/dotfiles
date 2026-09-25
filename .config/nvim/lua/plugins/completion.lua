vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
})

require("blink.cmp").setup({
  keymap = { preset = "enter",
    ["<Tab>"] = { "accept", "snippet_forward", "fallback" },
  },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
  },
  signature = { enabled = true },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    providers = {
      buffer = {
        opts = {
          -- only suggest words from the file you're editing
          get_bufnrs = function() return { vim.api.nvim_get_current_buf() } end,
        },
      },
    },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
