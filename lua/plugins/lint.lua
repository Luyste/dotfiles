local config = function()
	local lint = require("lint")

	lint.linters_by_ft = {
		markdown = { "markdownlint" },
		fish = { "fish" },
		-- css = { "stylelint" },
		javascript = { "eslint_d" },
		json = { "jsonlint" },
		-- less = { "stylelint" },
		lua = { "luacheck" },
		-- ruby = { "standardrb" },
		-- sass = { "stylelint" },
		-- scss = { "stylelint" },
		typescript = { "eslint_d" },
		-- vue = { "eslint_d" },
		yaml = { "yamllint" },
	}
end

return {
	"mfussenegger/nvim-lint",
	enabled = true,
	event = {
		"BufReadPre",
	},
	config = config,
}
