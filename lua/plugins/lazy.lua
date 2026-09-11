local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- LSP and completion
  {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig'
  },
  {
	"rebelot/kanagawa.nvim"
  },
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'saadparwaiz1/cmp_luasnip' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-buffer' },
  {
    'L3MON4D3/LuaSnip',
    dependencies = { 'rafamadriz/friendly-snippets' },
  },

  {
    'numToStr/FTerm.nvim'
  },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  -- Additional plugins
  {
    'folke/trouble.nvim',
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = 'Trouble',
    keys = {
      { '<F3>', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
      { '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols (Trouble)' },
      { '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'LSP Definitions / references / ... (Trouble)' },
      { '<leader>xL', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List (Trouble)' },
      { '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List (Trouble)' },
    },
  },
  { 'numToStr/Comment.nvim' },
  { 'windwp/nvim-autopairs' },
  { 'lewis6991/gitsigns.nvim' },
  { 'lukas-reineke/indent-blankline.nvim' },
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' }
	},
	{
	  "nvim-tree/nvim-tree.lua",
	  version = "*",
	  lazy = false,
	  dependencies = {
		"nvim-tree/nvim-web-devicons",
	  },
	  config = function()
		require("nvim-tree").setup {}
	  end,
	},
	{'christoomey/vim-tmux-navigator'},
	--colorscheme
	{'Mofiqul/vscode.nvim'},
	{'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},
	{'navarasu/onedark.nvim'},
	-- lazy.nvim
	-- {
	--   "folke/noice.nvim",
	--   event = "VeryLazy",
	--   opts = {
	-- 	-- add any options here
	--   },
	--   dependencies = {
	-- 	-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
	-- 	"MunifTanjim/nui.nvim",
	-- 	-- OPTIONAL:
	-- 	--   `nvim-notify` is only needed, if you want to use the notification view.
	-- 	--   If not available, we use `mini` as the fallback
	-- 	-- "rcarriga/nvim-notify",
	-- 	}
	-- },
	{ 'nyoom-engineering/oxocarbon.nvim'},
	-- {'shaunsingh/solarized.nvim'},
	{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
	{"lifepillar/vim-solarized8"},
	{"wsdjeg/terminal.nvim"},
	{"wsdjeg/scrollbar.nvim"},
})
