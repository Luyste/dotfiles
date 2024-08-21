local config = function()
	require("lsp_signature").setup()
end

return {
	"ray-x/lsp_signature.nvim",
	event = "VeryLazy",
	opts = {},
	config = config,
}
