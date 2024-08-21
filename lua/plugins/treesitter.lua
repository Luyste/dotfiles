return {
	'nvim-treesitter/nvim-treesitter',
	opts = {
		ensure_installed = { "lua", "vim", "vimdoc", "javascript", "typescript", "typespec" },
		sync_install = false,
		auto_install = true,
		highlight = {
			enable = true,
		},
	}
}
