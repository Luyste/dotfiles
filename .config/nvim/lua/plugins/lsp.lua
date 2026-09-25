vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

-- Settings for specific servers (everything else uses lspconfig defaults)
vim.lsp.config("gopls", {
	settings = {
		gopls = {
			staticcheck = true, -- extra Go linting
			analyses = { unusedparams = true },
		},
	},
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } }, -- stop "undefined global vim" warnings
			workspace = {
				library = { vim.env.VIMRUNTIME }, -- completion for vim.* APIs
				checkThirdParty = false,
			},
		},
	},
})

vim.lsp.enable({
	"ts_ls",
	"eslint",
	"html",
	"cssls",
	"jsonls",
	"gopls",
	"marksman",
	"dockerls",
	"yamlls",
	"taplo",
	"lua_ls",
	"tsp_server",
})

-- Extra LSP keymaps (only active in buffers with a server attached)
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local map = function(keys, fn, desc)
			vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
		end
		map("gd", vim.lsp.buf.definition, "Go to definition")
		map("gD", vim.lsp.buf.declaration, "Go to declaration")
		map("gy", vim.lsp.buf.type_definition, "Go to type definition")
		map("gi", vim.lsp.buf.implementation, "Go to type definition")
	end,
})
