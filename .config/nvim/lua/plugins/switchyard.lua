local map = vim.keymap.set
local dev = vim.fn.expand("~/personal/projects/switchyard.nvim")

if vim.uv.fs_stat(dev) then
	vim.opt.rtp:prepend(dev)
	vim.cmd.runtime("plugin/switchyard.lua") -- plugin/ files only load by themselves at startup
else
	vim.pack.add({ "https://github.com/Luyste/switchyard.nvim" })
end

require("switchyard").setup({
	viewer = {
		layout = "float", -- the agent floats on the right instead of a split
		bar = true, -- viewer closed: `● agent  working|idle` bottom right, click to open
	},
})

vim.api.nvim_create_autocmd("User", {
	pattern = "SwitchyardSwitched",
	callback = function()
		vim.schedule(function()
			require("nvim-tree.api").tree.open()
			vim.cmd.wincmd("p")
		end)
	end,
})

local function sy(fn)
	return function()
		require("switchyard")[fn]()
	end
end

-- The yard: 1 worktrees, 2 agents (Tab switches)
map({ "n", "t" }, "<D-y>", sy("open_yard"), { desc = "Switchyard: the yard" })
map({ "n", "t" }, "<D-j>", sy("toggle_view"), { desc = "Switchyard: toggle agent view" })
map({ "n", "t" }, "<D-J>", sy("focus_view"), { desc = "Switchyard: jump between viewer and editor" })
map("n", "<D-O>", sy("open_external"), { desc = "Switchyard: agent in external terminal" })
map({ "n", "t" }, "<D-H>", sy("link_here"), { desc = "Switchyard: link an agent in this worktree" })
map({ "n", "x" }, "<D-l>", sy("prompt"), { desc = "Switchyard: prompt builder (+ selection)" })
map({ "n", "x" }, "<D-L>", sy("prompt_line"), { desc = "Switchyard: prompt with this line/selection + diagnostics" })
map({ "n", "x" }, "<D-D>", sy("dispatch"), { desc = "Switchyard: dispatch a task to a new worktree" })
