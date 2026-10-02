return {
  settings = {
    Lua = {
      -- Suppress "undefined global vim" warnings in Neovim config
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
    },
  },
}
