vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim", name = "vague" },
})

local vague = require("vague")

-- vague's stock palette, read before setup() changes it. setup() merges onto
-- the previous call, so every variant starts from this full set.
local defaults = vague.get_palette()

-- Variants: color overrides on top of the defaults. vague is dark-only, so the
-- light ones swap the whole palette for darker accents that read on a light bg.
local light = {
	bg = "#f2f1ee",
	inactiveBg = "#e8e7e3",
	fg = "#3a3a40",
	floatBorder = "#8a8a8a",
	line = "#e6e5e0",
	comment = "#8e8ea2",
	builtin = "#4a7a74",
	func = "#a05555",
	string = "#9a6630",
	number = "#a4661c",
	property = "#50506a",
	constant = "#5e5e96",
	parameter = "#7f5a82",
	visual = "#d4d8dc",
	error = "#b83a58",
	warning = "#a8721f",
	hint = "#4a64b8",
	operator = "#5a6a80",
	keyword = "#3f6a8c",
	type = "#4f747e",
	search = "#c5d4e6",
	plus = "#4f7a35",
	delta = "#a8721f",
}

local variants = {
	dark = {
		bg = "#252528", -- default #141415, lighter
		inactiveBg = "#2b2b32", -- keep it just above bg
		line = "#33333d", -- cursor line, keep it above bg
		visual = "#40454a", -- selection, keep it above line
	},
	["dark-deep"] = {
		bg = "#1a1a1c",
		inactiveBg = "#212127",
		line = "#2a2a32",
		visual = "#383c40",
	},
	light = light,
	["light-dim"] = vim.tbl_extend("force", light, {
		bg = "#e4e3df",
		inactiveBg = "#dad9d4",
		line = "#d8d7d1",
		visual = "#c6cbd0",
	}),
}
local order = { "dark", "dark-deep", "light", "light-dim" }

-- The chosen variant is saved to a file so it survives restarts
local variant_file = vim.fn.stdpath("data") .. "/theme_variant"

local function apply(name)
	local is_light = name:match("^light") ~= nil
	vim.o.background = is_light and "light" or "dark"
	vague.setup({
		colors = vim.tbl_extend("force", defaults, variants[name]),
		on_highlights = function(hl)
			-- nvim-tree hardcodes a blue for folder icons; follow the theme instead
			hl.NvimTreeFolderIcon = { link = "Directory" }
			-- vague hardcodes dark diff backgrounds
			if is_light then
				hl.DiffAdd = { bg = "#dce8d2" }
				hl.DiffChange = { bg = "#efe3cf" }
				hl.DiffDelete = { bg = "#f0d6dc" }
				hl.DiffText = { bg = "#e3cba5" }
			end
		end,
	})
	-- vague's highlight modules read the colors once, when first required.
	-- Unload them so :colorscheme rebuilds them from the new palette.
	for mod in pairs(package.loaded) do
		if mod:match("^vague%.groups") or mod == "vague.highlights" or mod == "vague.terminal" then
			package.loaded[mod] = nil
		end
	end
	vim.cmd.colorscheme("vague")
	vim.g.theme_variant = name
end

local function load_variant()
	local f = io.open(variant_file, "r")
	if not f then
		return nil
	end
	local name = vim.trim(f:read("*a"))
	f:close()
	return variants[name] and name or nil
end

local function save_variant(name)
	local f = io.open(variant_file, "w")
	if f then
		f:write(name)
		f:close()
	end
end

apply(load_variant() or "dark")

vim.keymap.set("n", "<D-t>", function()
	vim.ui.select(order, {
		prompt = "Theme variant",
		format_item = function(name)
			return name == vim.g.theme_variant and name .. " (current)" or name
		end,
	}, function(name)
		if name then
			apply(name)
			save_variant(name)
		end
	end)
end, { desc = "Theme: pick variant" })
