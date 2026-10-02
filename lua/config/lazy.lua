local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Could not bootstrap lazy.nvim: " .. output)
  end
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup({ { import = "plugins" } }, {
  defaults = { lazy = false },
  checker = { enabled = false },
})
