local M = {}
local themes = {
  { "kanagawa-wave", "dark" }, { "kanagawa-dragon", "dark" },
  { "onedark", "light" }, { "solarized8_flat", "light" },
}
local index = 1
function M.toggle()
  index = index % #themes + 1
  local theme = themes[index]
  vim.o.background = theme[2]
  local ok, err = pcall(vim.cmd.colorscheme, theme[1])
  vim.notify(ok and ("Switched to: " .. theme[1] .. " (" .. theme[2] .. ")")
    or ("Could not load colorscheme: " .. tostring(err)), ok and vim.log.levels.INFO or vim.log.levels.ERROR)
end
function M.setup()
  vim.keymap.set("n", "<F5>", M.toggle, { desc = "Toggle colorscheme and background" })
end
return M
