local group = vim.api.nvim_create_augroup("MarkdownEditing", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "markdown",
  callback = function(event)
    local options = vim.bo[event.buf]
    options.textwidth = 80
    vim.wo.wrap = true
    vim.wo.linebreak = true
    vim.wo.spell = true
    local opts = { buffer = event.buf, silent = true, desc = "Export Markdown to PDF" }
    vim.keymap.set("n", "<F9>", "<cmd>Md2Pdf<CR>", opts)
    vim.keymap.set("n", "<leader>mp", "<cmd>Md2Pdf<CR>", opts)
  end,
})
