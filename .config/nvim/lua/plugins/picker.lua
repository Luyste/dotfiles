vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })

local fzf = require("fzf-lua")

fzf.setup({
	"hide",
})

local map = vim.keymap.set

map("n", "<D-f>", fzf.files, { desc = "Find files" })
map("n", "<D-g>", fzf.live_grep, { desc = "Grep project" })
map("n", "<D-b>", fzf.buffers, { desc = "Open buffers" })
map("n", "<D-CR>", fzf.resume, { desc = "Resume last search" })
map("n", "<D-S>", fzf.lsp_document_symbols, { desc = "Symbols in file" })
