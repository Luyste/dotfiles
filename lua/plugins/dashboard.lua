local config = function()
	require("dashboard").setup({
		theme = "doom",
		config = {
			header = { ":>" }, --your header
			footer = { " bye " }, --your footer
		},
	})
end

return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	config = config,
	dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
