local mason_opts = {
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
    border = "rounded",
  },
}

local ensure_installed = {
  "bashls",
  "cssls",
  "docker_compose_language_service",
  "dockerls",
  "emmet_ls",
  "html",
  "jsonls",
  "lua_ls",
  "tailwindcss",
  "tsserver",
  "tsp-server"
}

local config = function()
  local lspconfig = require("lspconfig")
  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  local mason = require("mason")
  local mason_lspconfig = require("mason-lspconfig")

  require("lspconfig.ui.windows").default_options.border = "rounded"

  vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Lsp Actions",
    callback = function(event)
      local opts = { buffer = event.buf }

      -- TODO: Add descriptions for keymaps
      vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
      vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
      vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
      vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
      vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
      vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
      vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
      vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
      vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
      vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)

      vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", opts)
      vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", opts)
      vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", opts)
    end,
  })

  -- Setup Mason
  mason.setup(mason_opts)
  mason_lspconfig.setup({ ensure_installed })

  -- TSPEC
  lspconfig.tsp_server.setup({
    cmd = { "tsp-server", "--stdio" },
    filetypes = { "typespec" },
    root_dir = lspconfig.util.root_pattern("tspconfig.yaml", ".git")
  })

  -- Lua (formatting by Stylua via conform)
  lspconfig.lua_ls.setup({
    capabilities = capabilities,
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim", "describe", "it", "before_each", "after_each" },
        },
      },
    },
  })

  -- JSON (formatting by Prettier via conform)
  lspconfig.jsonls.setup({
    capabilities = capabilities,
  })

  -- CSS
  lspconfig.cssls.setup({
    capabilities = capabilities,
  })

  -- HTML
  lspconfig.html.setup({
    capabilities = capabilities,
  })

  -- JavaScript / TypeScript (formatting by Prettier via conform)
  lspconfig.tsserver.setup({
    capabilities = capabilities,
  })

  -- Emmet
  lspconfig.emmet_ls.setup({
    capabilities = capabilities,
    -- add eruby as filetype
  })

  -- Markdown
  lspconfig.marksman.setup({
    capabilities = capabilities,
  })

  -- Bash
  lspconfig.bashls.setup({
    capabilities = capabilities,
  })

  -- Ansible
  lspconfig.ansiblels.setup({
    capabilities = capabilities,
  })

  -- YaML
  lspconfig.yamlls.setup({
    capabilities = capabilities,
  })

  local cmp = require("cmp")
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")

  cmp.setup({
    sources = {
      { name = "nvim_lsp" },
    },
    mapping = cmp.mapping.preset.insert({
      -- Enter key confirms completion item
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      -- Ctrl + space triggers completion menu
      ["<C-Space>"] = cmp.mapping.complete(),
    }),
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
  })

  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end

return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    lazy = false,
    config = config,
  },
}
