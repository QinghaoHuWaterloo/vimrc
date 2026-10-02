-- Network-free startup: use copied plugins but disable registry refresh/install jobs.
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/mason.nvim")
require("mason-registry").refresh = function(callback)
  vim.schedule(function() callback(false, {}) end)
end
vim.opt.lines = 40
vim.opt.columns = 120

_G.startup_errors = {}
local notify = vim.notify
vim.notify = function(message, level, options)
  if level == vim.log.levels.ERROR then startup_errors[#startup_errors + 1] = message end
  return notify(message, level, options)
end
