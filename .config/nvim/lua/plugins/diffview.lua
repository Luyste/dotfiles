vim.pack.add({ "https://github.com/sindrets/diffview.nvim" })

local diff = require("diffview")

local close = { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } }

diff.setup({
	keymaps = {
		view = { close },
		file_panel = { close },
		file_history_panel = { close },
	},
})
