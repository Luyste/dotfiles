vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function load(module)
    local ok, err = pcall(require, module)
    if not ok then
        vim.notify("Failed to load " .. module .. ":\n" .. err, vim.log.levels.ERROR)
    end
end


load("config.options")
load("config.keymaps")
load("config.font")
load("config.statusline")
load("config.diagnostics")
load("config.theme")

load("plugins.tree")
load("plugins.picker")
load("plugins.multicursor")
load("plugins.completion")
load("plugins.format")
load("plugins.blame")
load("plugins.codediff")
load("plugins.lsp")
load("plugins.switchyard")

if vim.g.neovide then
    load("config.neovide")
end
