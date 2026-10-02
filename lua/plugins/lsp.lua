return {
  { "williamboman/mason.nvim", opts = {
    ui = { icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" } },
  } },
  { "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "clangd", "jdtls", "vimls", "marksman" },
        automatic_enable = false,
      })
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local servers = {
        clangd = "cpp", jdtls = "java", marksman = "markdown",
        lua_ls = "lua", vimls = "vim", racket_langserver = "racket",
      }
      for server, language in pairs(servers) do
        local settings = require("languages.lsp." .. language)
        vim.lsp.config(server, vim.tbl_deep_extend("force", { capabilities = capabilities }, settings))
        vim.lsp.enable(server)
      end
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
}
