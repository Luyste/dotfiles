vim.pack.add({
	"https://github.com/rachartier/tiny-inline-diagnostic.nvim",
	"https://github.com/folke/trouble.nvim",
})

require("tiny-inline-diagnostic").setup()
require("trouble").setup()

-- Backspace: toggle a list of all diagnostics (bottom split, like the quickfix list)
vim.keymap.set("n", "<BS>", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle diagnostics list" })
