vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add({
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/nvim-tree/nvim-tree.lua",
})

-- custom keymap overrides

local function on_attach(bufnr)
	local api = require("nvim-tree.api")

	api.config.mappings.default_on_attach(bufnr)

	local function map(key, fn, desc)
		vim.keymap.set("n", key, fn, {
			buffer = bufnr,
			silent = true,
			nowait = true,
			desc = "nvim-tree: " .. desc,
		})
	end

	map("%", api.fs.create, "New file")
	map("D", api.fs.remove, "Delete")
	map("d", function()
		local node = api.tree.get_node_under_cursor()
		local base = vim.fn.getcwd()
		if node then
			base = node.type == "directory" and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
		end

		vim.ui.input({ prompt = "New directory: " }, function(name)
			if not name or name == "" then
				return
			end
			vim.fn.mkdir(base .. "/" .. name, "p")
			api.tree.reload()
		end)
	end, "New directory")

	map("<S-r>", function()
		local node = api.tree.get_node_under_cursor()
		if node and node.type == "file" then
			api.fs.rename()
		else
			api.node.open.edit()
		end
	end, "Rename file / toggle directory")

	map("l", function()
		local node = api.tree.get_node_under_cursor()
		if not node then
			return
		end
		if node.type == "directory" then
			if not node.open then
				api.node.open.edit()
			end
		end
	end, "Open")

	-- h : close directory, or jump to parent and close it
	map("h", function()
		local node = api.tree.get_node_under_cursor()
		if node and node.type == "directory" and node.open then
			api.node.open.edit()
		else
			api.node.navigate.parent_close()
		end
	end, "Close")

	-- Open in a split. Lowercase keeps the cursor in the tree,
	-- uppercase moves it to the new split.
	local function split(open_fn, stay_in_tree)
		return function()
			local node = api.tree.get_node_under_cursor()
			if not node or node.type ~= "file" then
				return
			end
			open_fn(node, { focus = stay_in_tree })
		end
	end

	map("m", split(api.node.open.horizontal, true), "Horizontal split (stay)")
	map("M", split(api.node.open.horizontal, false), "Horizontal split (go)")
	map("n", split(api.node.open.vertical, true), "Vertical split (stay)")
	map("N", split(api.node.open.vertical, false), "Vertical  split (go)")
end

require("nvim-tree").setup({
	on_attach = on_attach,
	view = { width = 32 },
	update_focused_file = { enable = true },
})

vim.keymap.set("n", "<D-e>", "<cmd>NvimTreeToggle<cr>", { desc = "File tree" })
