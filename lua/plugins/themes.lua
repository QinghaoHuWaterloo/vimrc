return {
  {
    "navarasu/onedark.nvim",
    opts = {
      style = "warm", transparent = false, term_colors = true,
      ending_tildes = false, cmp_itemkind_reverse = false,
      toggle_style_key = nil,
      toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" },
      code_style = {
        comments = "italic", keywords = "none", functions = "none",
        strings = "none", variables = "none",
      },
      lualine = { transparent = false },
      colors = {}, highlights = {},
      diagnostics = { darker = true, undercurl = true, background = true },
    },
  },
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    dependencies = { "navarasu/onedark.nvim" },
    opts = {
      compile = false, undercurl = true,
      commentStyle = { italic = false }, keywordStyle = { italic = false },
      functionStyle = {}, statementStyle = { bold = false }, typeStyle = {},
      transparent = false, dimInactive = false, terminalColors = true,
      colors = { palette = {}, theme = { wave = {}, lotus = {}, dragon = {}, all = {} } },
      overrides = function() return {} end,
      theme = "wave", background = { dark = "wave", light = "lotus" },
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)
      vim.cmd.colorscheme("kanagawa")
    end,
  },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "Mofiqul/vscode.nvim" },
  { "nyoom-engineering/oxocarbon.nvim" },
  { "lifepillar/vim-solarized8" },
}
