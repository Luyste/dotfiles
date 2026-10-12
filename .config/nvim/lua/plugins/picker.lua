vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })

local fzf = require("fzf-lua")

fzf.setup({
    "hide",
    defaults = { formatter = "path.filename_first" },
})

fzf.register_ui_select()

local map = vim.keymap.set

-- Files; a prefix switches: $ buffers, @ symbols (file), # symbols (project)
map("n", "<D-f>", fzf.global, { desc = "Find: files, $ buffers, @ symbols" })
map("n", "<D-g>", fzf.live_grep, { desc = "Grep project" })
-- Open buffers first, then recent files (also outside the repo, survives restarts)
map("n", "<D-b>", function()
    fzf.oldfiles({ include_current_session = true, cwd_only = false })
end, { desc = "Buffers + recent files" })
map("n", "<D-CR>", fzf.resume, { desc = "Resume last search" })
map("n", "<D-G>", fzf.grep_cword, { desc = "Grep word under cursor" })
