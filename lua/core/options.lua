local opt = vim.opt

-- 行号
opt.relativenumber = true
opt.number = true

-- 缩进
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = false
opt.autoindent = true

-- 防止包裹
opt.wrap = false

-- 光标行
-- opt.cursorline = true

-- 启用鼠标
opt.mouse:append("a")

-- 系统剪贴板
opt.clipboard:append("unnamedplus")

-- 默认新窗口右和下
opt.splitright = true
opt.splitbelow = true

-- 搜索
opt.ignorecase = true
opt.smartcase = true

-- 外观
opt.termguicolors = true
opt.signcolumn = "number"
--file
opt.backup = false
opt.swapfile = false
-- opt.compatible is always false in Neovim; no need to set it
opt.encoding = 'utf-8'
-- Allow backspace over autoindent, line breaks, and start of insert
opt.backspace = { 'indent', 'eol', 'start' }

-- fold setting
vim.o.foldenable = true        -- Keep folds enabled
vim.o.foldmethod = "syntax"    -- Or "syntax" / "indent" based on your preference
vim.o.foldlevel = 99           -- Open all folds by default
vim.o.viewoptions = "folds" -- Save folds and cursor position

-- Auto-save folds on exit
vim.api.nvim_create_autocmd({"BufWinLeave"}, {
  pattern = {"*"},
  command = "silent! mkview"
})

-- Auto-restore folds when opening files
vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  pattern = {"*"},
  command = "silent! loadview"
})
