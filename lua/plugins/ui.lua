return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    opts = {
      sort = { sorter = "case_sensitive" },
      view = { width = 30 },
      renderer = { group_empty = true },
      filters = { dotfiles = true },
    },
    keys = { { "<F2>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" } },
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        offsets = { {
          filetype = "NvimTree", text = "File Explorer",
          highlight = "Directory", text_align = "left",
        } },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        icons_enabled = true, theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = {}, winbar = {} },
        ignore_focus = {}, always_divide_middle = true, always_show_tabline = true,
        globalstatus = false, refresh = { statusline = 1000, tabline = 1000, winbar = 1000 },
      },
      sections = {
        lualine_a = { "mode" }, lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" }, lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" }, lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {}, lualine_b = {}, lualine_c = { "filename" },
        lualine_x = { "location" }, lualine_y = {}, lualine_z = {},
      },
      tabline = {}, winbar = {}, inactive_winbar = {}, extensions = {},
    },
  },
  {
    "wsdjeg/scrollbar.nvim",
    main = "scrollbar",
    opts = {
      max_size = 10, min_size = 5, width = 1, right_offset = 1,
      excluded_filetypes = {
        "startify", "git-commit", "leaderf", "NvimTree", "tagbar", "defx", "neo-tree", "qf",
      },
      shape = { head = "▲", body = "█", tail = "▼" },
      highlight = { head = "Normal", body = "Normal", tail = "Normal" },
    },
  },
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    lazy = true,
    keys = {
      { "<F3>", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP results (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<CR>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix List (Trouble)" },
    },
  },
}
