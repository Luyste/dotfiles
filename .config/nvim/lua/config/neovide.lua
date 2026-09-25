local map = vim.keymap.set

map("v", "<D-c>", '"+y', { desc = "Copy" })
map("v", "<D-x>", '"+d', { desc = "Cut" })

map("n", "<D-v>", '"+p', { desc = "Paste" })
map("v", "<D-v>", '"+P', { desc = "Paste over selection" })
map("i", "<D-v>", '<C-r><C-o>+', { desc = "Paste" })
map("c", "<D-v>", "<C-r>+", { desc = "Paste" })


map("n", "<D-a>", "ggGV", { desc = "Select all" })
map("n", "<D-s>", "<cmd>write<cr>", { desc = "Save" })

map("n", "<D-q>", "<cmd>confirm qall<cr>", { desc = "Quit" })
