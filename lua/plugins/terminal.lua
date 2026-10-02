return {
  { "numToStr/FTerm.nvim", config = function()
    vim.api.nvim_create_user_command("FTermToggle", require("FTerm").toggle, { bang = true })
  end },
  { "wsdjeg/terminal.nvim" },
}
