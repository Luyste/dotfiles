local map = vim.keymap.set

map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Zoom: saved to a file so it survives restarts
local scale_file = vim.fn.stdpath("data") .. "/neovide_scale"

local function load_scale()
	local f = io.open(scale_file, "r")
	if not f then
		return nil
	end
	local value = tonumber(f:read("*a"))
	f:close()
	return value
end

local function set_scale(value)
	value = math.max(0.5, math.min(value, 3.0)) -- keep it between 50% and 300%
	vim.g.neovide_scale_factor = value
	local f = io.open(scale_file, "w")
	if f then
		f:write(tostring(value))
		f:close()
	end
end

vim.g.neovide_scale_factor = load_scale() or 1.0

map("n", "<D-=>", function()
	set_scale(vim.g.neovide_scale_factor * 1.1)
end, { desc = "Zoom in" })
map("n", "<D-->", function()
	set_scale(vim.g.neovide_scale_factor / 1.1)
end, { desc = "Zoom out" })
map("n", "<D-0>", function()
	set_scale(1.0)
end, { desc = "Reset zoom" })
