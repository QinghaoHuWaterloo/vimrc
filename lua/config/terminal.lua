-- Bound memory retained by each terminal without changing run/build commands.
local group = vim.api.nvim_create_augroup("TerminalExperience", { clear = true })
local terminal_options = {
  number = false, relativenumber = false, signcolumn = "no",
  foldcolumn = "0", foldenable = false,
}

-- Neovim stores window options per buffer; leave file-buffer options alone.
local function update_window()
  local win = vim.api.nvim_get_current_win()
  if vim.bo.buftype == "terminal" then
    vim.bo.scrollback = 5000
    for option, value in pairs(terminal_options) do
      vim.wo[win][option] = value
    end
  end
end
vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter", "BufWinEnter", "WinEnter" }, {
  group = group, callback = update_window,
})

-- Keep Ctrl-C/Ctrl-D/Ctrl-L available to the shell. Esc already leaves input.
for _, direction in ipairs({ "h", "j", "k", "l" }) do
  vim.keymap.set("t", "<C-w>" .. direction, "<C-\\><C-n><C-w>" .. direction,
    { desc = "Switch window from terminal" })
end
vim.keymap.set("t", "<F10>", "<C-\\><C-n><F10>", {
  remap = true, desc = "Toggle terminal from terminal input",
})
