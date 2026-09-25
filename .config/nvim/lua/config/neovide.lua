local map = vim.keymap.set

map("v", "<D-c>", '"+y', { desc = "Copy" })
map("v", "<D-x>", '"+d', { desc = "Cut" })

map("n", "<D-v>", '"+p', { desc = "Paste" })
map("v", "<D-v>", '"+P', { desc = "Paste over selection" })
map("i", "<D-v>", "<C-r><C-o>+", { desc = "Paste" })
map("c", "<D-v>", "<C-r>+", { desc = "Paste" })

map("n", "<D-a>", "ggGV", { desc = "Select all" })
map("n", "<D-s>", "<cmd>write!<cr>", { desc = "Save" })

map("n", "<D-q>", "<cmd>confirm qall<cr>", { desc = "Quit" })
map("n", "<D-w>", function()
	local buf = vim.api.nvim_get_current_buf()

	-- Ask before throwing away unsaved changes
	if vim.bo[buf].modified then
		local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
		local choice = vim.fn.confirm(
			("Save changes to %s?"):format(name ~= "" and name or "[No Name]"),
			"&Save\n&Discard\n&Cancel"
		)
		if choice == 1 then
			vim.cmd.write()
		elseif choice ~= 2 then
			return -- Cancel or Esc
		end
	end

	-- Show another buffer in this window before deleting
	local alt = vim.fn.bufnr("#")
	if alt > 0 and alt ~= buf and vim.bo[alt].buflisted then
		vim.cmd.buffer(alt)
	else
		vim.cmd.bprevious()
	end
	if vim.api.nvim_get_current_buf() == buf then
		vim.cmd.enew() -- this was the last file: leave an empty buffer
	end

	vim.cmd.bdelete({ args = { tostring(buf) }, bang = true })
end, { desc = "Close buffer" })
