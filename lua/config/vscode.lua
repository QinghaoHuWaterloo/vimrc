-- VS Code owns UI, insert completion, snippets and language servers.
local M = {}
function M.setup()
  vim.opt.ignorecase, vim.opt.smartcase = true, true
  vim.opt.backup, vim.opt.swapfile = false, false
  vim.opt.clipboard:append("unnamedplus")
  local function action(command)
    return function() require("vscode").action(command) end
  end
  local map = vim.keymap.set
  for key, command in pairs({
    H = "workbench.action.previousEditor", L = "workbench.action.nextEditor",
    x = "workbench.action.closeActiveEditor", U = "undo",
    ["<C-a>"] = "editor.action.selectAll",
    ["<F2>"] = "workbench.action.toggleSidebarVisibility",
    ["<F3>"] = "workbench.actions.view.problems",
    ["<F5>"] = "workbench.action.selectTheme",
    ["<F10>"] = "workbench.action.terminal.toggleTerminal",
    gd = "editor.action.revealDefinition", gr = "editor.action.goToReferences",
    K = "editor.action.showHover", ["<leader>rn"] = "editor.action.rename",
    ["<leader>ca"] = "editor.action.quickFix",
  }) do map("n", key, action(command), { silent = true, desc = "VS Code: " .. command }) end
  map("n", "<F6>", ":set hlsearch<CR>:/")
  map("n", "<Backspace>", "<cmd>nohlsearch<cr>")
  for _, key in ipairs({ "D", "dd", "dw" }) do map("n", key, '"_' .. key) end
  map("n", "<F7>", function()
    require("vscode").action("workbench.action.quickOpen", { args = { require("config.paths").templates } })
  end)
  map("n", "<F8>", function() require("features.templates").insert() end)
end
return M
