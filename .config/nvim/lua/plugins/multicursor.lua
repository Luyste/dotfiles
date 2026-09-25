vim.pack.add({
  { src = "https://github.com/jake-stewart/multicursor.nvim", version = "1.0" },
})

local mc = require("multicursor-nvim")
mc.setup()

local map = vim.keymap.set

-- Ctrl+Shift+J/K: add a cursor on the line below/above
map({ "n", "x" }, "<C-S-j>", function() mc.lineAddCursor(1) end, { desc = "Add cursor below" })
map({ "n", "x" }, "<C-S-k>", function() mc.lineAddCursor(-1) end, { desc = "Add cursor above" })

-- These only apply while you have multiple cursors
mc.addKeymapLayer(function(layerSet)
  -- Esc collapses back to a single cursor
  layerSet("n", "<Esc>", function()
    if not mc.cursorsEnabled() then
      mc.enableCursors()
    else
      mc.clearCursors()
    end
  end)
end)
