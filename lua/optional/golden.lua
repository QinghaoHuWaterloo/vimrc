local kanagawa_colors = {
  normal = {
    a = { fg = '#282c34', bg = '#d4af37' },  -- Gold color
    b = { fg = '#abb2bf', bg = '#282c34' },
    c = { fg = '#abb2bf', bg = '#282c34' },
  },
  insert = {
    a = { fg = '#282c34', bg = '#d4af37' },  -- Gold color
    b = { fg = '#abb2bf', bg = '#282c34' },
    c = { fg = '#abb2bf', bg = '#282c34' },
  },
  visual = {
    a = { fg = '#282c34', bg = '#d4af37' },  -- Gold color
    b = { fg = '#abb2bf', bg = '#282c34' },
    c = { fg = '#abb2bf', bg = '#282c34' },
  },
  replace = {
    a = { fg = '#282c34', bg = '#d4af37' },  -- Gold color
    b = { fg = '#abb2bf', bg = '#282c34' },
    c = { fg = '#abb2bf', bg = '#282c34' },
  },
  command = {
    a = { fg = '#282c34', bg = '#d4af37' },  -- Gold color
    b = { fg = '#abb2bf', bg = '#282c34' },
    c = { fg = '#abb2bf', bg = '#282c34' },
  },
  inactive = {
    a = { fg = '#abb2bf', bg = '#282c34' },
    b = { fg = '#abb2bf', bg = '#282c34' },
    c = { fg = '#abb2bf', bg = '#282c34' },
  },
}

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = kanagawa_colors,
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}



