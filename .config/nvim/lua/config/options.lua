local o = vim.opt

o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.scrolloff = 16
o.mouse = "a"
o.smoothscroll = true

o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2

o.ignorecase = true
o.smartcase = true

o.splitright = true
o.splitbelow = true
o.undofile = true
o.swapfile = false

vim.schedule(function()
	o.clipboard = "unnamedplus"
end)
