local git = {}

-- Ask git for the repo, branch and worktree (runs in the background)
local function refresh_git()
	vim.system({
		"git",
		"rev-parse",
		"--path-format=absolute",
		"--show-toplevel",
		"--git-dir",
		"--git-common-dir",
		"--abbrev-ref",
		"HEAD",
	}, { text = true, cwd = vim.fn.getcwd() }, function(res)
		vim.schedule(function()
			if res.code ~= 0 then
				git = {}
			else
				local top, gitdir, common, branch = unpack(vim.split(vim.trim(res.stdout), "\n"))
				local repo = vim.fn.fnamemodify(common, ":t") == ".git" and vim.fn.fnamemodify(common, ":h:t")
					or (vim.fn.fnamemodify(common, ":t"):gsub("%.git$", ""))
				git = {
					repo = repo,
					branch = branch,
					-- a linked worktree has its own git dir, separate from the shared one
					worktree = gitdir ~= common and vim.fn.fnamemodify(top, ":t") or nil,
				}
			end
			vim.cmd("redrawstatus!")
		end)
	end)
end

-- Diagnostic colors on the statusline background
local function set_highlights()
	local bg = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false }).bg
	for group, source in pairs({
		StlError = "DiagnosticError",
		StlWarn = "DiagnosticWarn",
		StlInfo = "DiagnosticInfo",
		StlHint = "DiagnosticHint",
	}) do
		local fg = vim.api.nvim_get_hl(0, { name = source, link = false }).fg
		vim.api.nvim_set_hl(0, group, { fg = fg, bg = bg })
	end
end

local sev = vim.diagnostic.severity
local diag_parts = {
	{ sev.ERROR, "StlError", "✘" },
	{ sev.WARN, "StlWarn", "▲" },
	{ sev.INFO, "StlInfo", "●" },
	{ sev.HINT, "StlHint", "»" },
}

function _G.Statusline()
	local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid)

	-- File tree: repo, branch, worktree
	if vim.bo[buf].filetype == "NvimTree" then
		if not git.repo then
			return " "
		end
		local s = " \u{f401} " .. git.repo .. "  \u{e725} " .. git.branch
		if git.worktree then
			s = s .. "  \u{f1bb} " .. git.worktree
		end
		return s
	end

	-- Normal buffers: filename, modified flag, diagnostics, position
	local name = vim.api.nvim_buf_get_name(buf)
	name = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")
	local s = " " .. name:gsub("%%", "%%%%")
	if vim.bo[buf].modified then
		s = s .. " ●"
	end

	s = s .. "%=" -- everything after this is right-aligned

	local counts = vim.diagnostic.count(buf)
	for _, d in ipairs(diag_parts) do
		local n = counts[d[1]]
		if n and n > 0 then
			s = s .. ("%%#%s#%s %d "):format(d[2], d[3], n)
		end
	end

	return s .. "%* %l:%c "
end

vim.o.statusline = "%!v:lua.Statusline()"

set_highlights()
refresh_git()

vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })
vim.api.nvim_create_autocmd({ "DirChanged", "FocusGained", "BufWritePost" }, {
	callback = refresh_git,
})
vim.api.nvim_create_autocmd("DiagnosticChanged", {
	callback = function()
		vim.cmd("redrawstatus!")
	end,
})
