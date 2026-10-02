local M = {}
local paths = require("config.paths")
function M.insert()
  local path = vim.fn.input("Template Path: ", paths.template_prompt, "file")
  if path == "" then return end
  path = vim.fn.expand(path)
  if vim.fn.filereadable(path) == 0 then
    vim.notify("Cannot open template: " .. path, vim.log.levels.WARN)
    return
  end
  vim.api.nvim_put(vim.fn.readfile(path), "b", true, true)
  vim.cmd("1")
end
function M.setup()
  _G.insert_template = M.insert
  vim.keymap.set("n", "<F7>", function()
    if vim.fn.isdirectory(paths.templates) == 0 then
      vim.notify("Template directory not found: " .. paths.templates, vim.log.levels.WARN)
      return
    end
    vim.cmd.edit(vim.fn.fnameescape(paths.templates))
  end, { desc = "Open template directory" })
  vim.keymap.set("n", "<F8>", M.insert, { desc = "Insert template", silent = true })
end
return M
