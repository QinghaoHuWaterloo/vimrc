local M = {}
function M.export()
  if vim.bo.filetype ~= "markdown" then
    vim.notify("Md2Pdf only works for markdown buffers", vim.log.levels.WARN)
    return
  end
  local ctx = require("features.runner").context()
  if not ctx then return end
  local converter = require("config.paths").md2pdf
  if vim.fn.executable(converter) ~= 1 then
    vim.notify("PDF converter not found: " .. converter, vim.log.levels.WARN)
    return
  end
  local output = vim.fn.fnamemodify(ctx.path, ":r") .. ".pdf"
  local result = vim.fn.system({ converter, ctx.path, output })
  if vim.v.shell_error == 0 then
    vim.notify("PDF created: " .. output, vim.log.levels.INFO)
  else
    vim.notify("md2pdf failed:\n" .. result, vim.log.levels.ERROR)
  end
end
function M.setup()
  vim.api.nvim_create_user_command("Md2Pdf", M.export, {})
end
return M
