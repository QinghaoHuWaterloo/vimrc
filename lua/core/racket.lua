local group = vim.api.nvim_create_augroup("RacketCS135", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "racket",
  callback = function(event)
    local options = vim.bo[event.buf]
    -- CS135/DrRacket convention: two-space indentation and semicolon comments.
    options.tabstop = 2
    options.softtabstop = 2
    options.shiftwidth = 2
    options.expandtab = true
    options.commentstring = "; %s"

    vim.keymap.set("n", "<leader>rr", M, {
      buffer = event.buf,
      desc = "Racket: run in FTerm",
    })
    vim.keymap.set("n", "<leader>rt", Check, {
      buffer = event.buf,
      desc = "Racket: run raco test",
    })
    vim.keymap.set("n", "<leader>rf", function()
      vim.cmd("normal! gg=G")
    end, {
      buffer = event.buf,
      desc = "Racket: reindent buffer",
    })
  end,
})
