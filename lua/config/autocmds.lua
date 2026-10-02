local group = vim.api.nvim_create_augroup("EditorViews", { clear = true })
-- Auto-save folds on exit
vim.api.nvim_create_autocmd({"BufWinLeave"}, {
  group = group,
  pattern = {"*"},
  command = "silent! mkview"
})

-- Auto-restore folds when opening files
vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  group = group,
  pattern = {"*"},
  command = "silent! loadview"
})
