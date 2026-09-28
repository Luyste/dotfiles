vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim", name = "vague" },
})

require("vague").setup({
	colors = {
		bg = "#252528", -- default #141415, lighter
		inactiveBg = "#2b2b32", -- default #1c1c24, keep it just above bg
		line = "#33333d", -- cursor line, default #252530, keep it above bg
		visual = "#40454a", -- selection, default #333738, keep it above line
	},
	-- nvim-tree hardcodes a blue for folder icons; follow the theme instead
	on_highlights = function(hl)
		hl.NvimTreeFolderIcon = { link = "Directory" }
	end,
})

vim.cmd.colorscheme("vague")
