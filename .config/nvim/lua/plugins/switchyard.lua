local map = vim.keymap.set
local dev = vim.fn.expand("~/personal/projects/switchyard.nvim")

if vim.uv.fs_stat(dev) then
	vim.opt.rtp:prepend(dev)
else
	vim.pack.add({ "https://github.com/Luyste/switchyard.nvim" })
end

require("switchyard").setup({})

vim.api.nvim_create_autocmd("User", {
	pattern = "SwitchyardSwitched",
	callback = function()
		require("nvim-tree.api").tree.open()
		vim.cmd.wincmd("p")
	end,
})

local function sy(fn)
	return function()
		require("switchyard")[fn]()
	end
end

map({ "n", "t" }, "<D-Y>", sy("open_yard"), { desc = "Switchyard: open the yard" })
map({ "n", "t" }, "<D-j>", sy("toggle_view"), { desc = "Switchyard: toggle agent view" })
map({ "n", "t" }, "<D-J>", sy("focus_view"), { desc = "Switchyard: jump between viewer and editor" })
map("n", "<D-O>", sy("open_external"), { desc = "Switchyard: agent in external terminal" })
map({ "n", "t" }, "<D-H>", sy("link_here"), { desc = "Switchyard: link an agent in this worktree" })
map({ "n", "t" }, "<D-F>", sy("follow_edits"), { desc = "Switchyard: follow the agent's edits" })
map({ "n", "x" }, "<D-l>", sy("prompt"), { desc = "Switchyard: prompt builder (+ selection)" })
map("n", "<D-L>", sy("prompt_line"), { desc = "Switchyard: prompt with this line + diagnostics" })
map({ "n", "x" }, "<D-D>", sy("dispatch"), { desc = "Switchyard: dispatch a task to a new worktree" })
