vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

local prettier = { "prettierd", "prettier", stop_after_first = true }

require("conform").setup({
  formatters_by_ft = {
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    html = prettier,
    css = prettier,
    json = prettier,
    jsonc = prettier,
    yaml = prettier,
    markdown = prettier,
    go = { "goimports", "gofmt", stop_after_first = true },
    toml = { "taplo" },
    lua = { "stylua" },
    typespec = { "typespec" },
  },
  format_on_save = {
    timeout_ms = 1000,
    lsp_format = "fallback",
  },
})

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format" })
