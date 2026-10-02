return {
  { "numToStr/Comment.nvim", opts = {} },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  {
    "windwp/nvim-autopairs",
    dependencies = { "hrsh7th/nvim-cmp" },
    opts = {
      disable_filetype = { "TelescopePrompt", "spectre_panel", "snacks_picker_input", "racket" },
      check_ts = true,
      ts_config = { lua = { "string", "source" }, javascript = { "string", "template_string" } },
      fast_wrap = {
        map = "<M-e>", chars = { "{", "[", "(", '"', "'" },
        pattern = [=[[%'%"%)%>%]%)%}%,]]=],
        end_key = "$", keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true, highlight = "Search", highlight_grey = "Comment",
      },
    },
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)
      require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done({
        map_char = { tex = "" }, filetypes = { racket = false },
      }))
    end,
  },
  { "lewis6991/gitsigns.nvim" },
  { "christoomey/vim-tmux-navigator" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
}
