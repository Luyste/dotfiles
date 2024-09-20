local config = function()
  require("indentmini").setup({
    only_current = true
  })
end


return {
  'nvimdev/indentmini.nvim',
  config = config
}
