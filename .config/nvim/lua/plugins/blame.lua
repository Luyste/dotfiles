vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

local gs = require("gitsigns")

gs.setup({
	current_line_blame = true, -- inline blame on by default
	current_line_blame_opts = {
		delay = 500, -- ms before it appears
	},
	current_line_blame_formatter = " <author>, <author_time:%R> · <summary>",
})

local map = vim.keymap.set
map("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Toggle inline blame" })
map("n", "<leader>gl", function()
	gs.blame_line({ full = true })
end, { desc = "Blame popup for line" })
map("n", "<leader>gB", gs.blame, { desc = "Blame whole file" })
