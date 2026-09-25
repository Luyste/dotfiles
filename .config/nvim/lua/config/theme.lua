vim.pack.add({
	{ src = "https://github.com/mawkler/onedark.nvim", name = "onedark" },
})

-- Example config in Lua
require("onedark").setup({
	function_style = "italic",
	sidebars = { "qf", "vista_kind", "terminal", "packer" },

	-- Change the "hint" color to the "orange0" color, and make the "error" color bright red
	colors = { hint = "orange0", error = "#ff0000" },

	-- Overwrite the highlight groups
	overrides = function(c)
		return {
			htmlTag = { fg = c.red0, bg = "#282c34", sp = c.hint, style = "underline" },
			DiagnosticHint = { link = "LspDiagnosticsDefaultHint" },
			-- this will remove the highlight groups
			TSField = {},
		}
	end,
})

vim.cmd.colorscheme("onedark")
