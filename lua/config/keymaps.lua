--
--
-- [[ NAVIGATION ]]
--
--
vim.keymap.set("n", "<leader>nb", vim.cmd.Ex)

--
--
-- [[ EDITOR ]]
--
--
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Grab and move-swap selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Grab and move-swap selection up" })

--
--
-- [[ PLUGINS ]]
--
--

-- [ trouble ]
vim.keymap.set("n", "<leader>td", "<cmd>Trouble diagnostics toggle<cr>", { desc = "toggle diagnostics" })
vim.keymap.set(
	"n",
	"<leader>tr",
	"<cmd>Trouble lsp toggle focus=false win.position=bottom<cr>",
	{ desc = "toggle references" }
)
vim.keymap.set(
	"n",
	"<leader>ts",
	"<cmd>Trouble symbols toggle win.position=right win.size=50<cr>",
	{ desc = "toggle symbols" }
)
vim.keymap.set("n", "<leader>tD", "<cmd>Trouble lsp_declarations toggle <cr>", { desc = "toggle symbols" })

-- [ harpoon ]
local harpoon = require("harpoon")
harpoon:setup({
	settings = {
		save_on_toggle = true,
	},
})

vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end, { desc = "add to harpoon" })

vim.keymap.set("n", "<C-e>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "toggle harpoon menu" })

vim.keymap.set("n", "<leader>1", function()
	harpoon:list():select(1)
end, { desc = "goto harpoon 1" })

vim.keymap.set("n", "<leader>2", function()
	harpoon:list():select(1)
end, { desc = "goto harpoon 2" })

vim.keymap.set("n", "<leader>3", function()
	harpoon:list():select(1)
end, { desc = "goto harpoon 3" })
vim.keymap.set("n", "<leader>4", function()
	harpoon:list():select(1)
end, { desc = "goto harpoon 4" })

-- [ mini files ]
local mini = require("mini.files")
local minifiles_toggle = function(...)
	if not mini.close() then
		mini.open(...)
	end
end

vim.keymap.set("n", "<C-m>", function()
	minifiles_toggle(nil, false)
end, { desc = "open mini.files cur dir" })
vim.keymap.set("n", "<C-k>", function()
	minifiles_toggle(mini.get_latest_path())
end, { desc = "open mini.files cur dir" })

-- [ mini pick ]
local pick = require("mini.pick")

local search_files = function(...)
	pick.builtin.files(...)
end
local grep_files = function(...)
	pick.builtin.grep_live(...)
end

vim.keymap.set("n", "<leader>sf", function()
	search_files()
end, { desc = "search files cur dir" })
vim.keymap.set("n", "<leader>sg", function()
	grep_files()
end, { desc = "grep string cur dir" })
