vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	{ src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
})

local harpoon = require("harpoon")
harpoon:setup()

local map = vim.keymap.set

map("n", "<leader>a", function()
	harpoon:list():add()
end, { desc = "Harpoon: add file" })

-- Edit the list in the menu: dd removes, move lines to reorder, :w or q saves
map("n", "<leader>h", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon: menu" })

for i = 1, 6 do
	map("n", "<D-" .. i .. ">", function()
		harpoon:list():select(i)
	end, { desc = "Harpoon: file " .. i })
end
