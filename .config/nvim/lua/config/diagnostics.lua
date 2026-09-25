vim.diagnostic.config({
	virtual_text = { spacing = 2, prefix = "\u{25cf}" }, -- inline messages
	severity_sort = true,
	update_in_insert = false,
	float = { source = true },
})

-- Backspace: toggle a list of all diagnostics
vim.keymap.set("n", "<BS>", function()
	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			vim.cmd.cclose()
			return
		end
	end
	vim.diagnostic.setqflist()
end, { desc = "Toggle diagnostics list" })
