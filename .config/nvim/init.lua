vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")

require("plugins.tree")
require("plugins.picker")
require("plugins.multicursor")
require("plugins.completion")

if vim.g.neovide then
  require("config.neovide")
end

