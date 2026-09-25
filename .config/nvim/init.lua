vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.font")
require("config.statusline")
require("config.diagnostics")
require("config.theme")

require("plugins.tree")
require("plugins.picker")
require("plugins.multicursor")
require("plugins.completion")
require("plugins.format")
require("plugins.blame")
require("plugins.lsp")

if vim.g.neovide then
	require("config.neovide")
end
