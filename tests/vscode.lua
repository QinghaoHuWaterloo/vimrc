local ok, err = xpcall(function()
  assert(vim.g.vscode)
  for _, name in ipairs({ "config.lazy", "cmp", "luasnip", "features.runner", "features.themes", "features.toolcheck", "languages.tex", "languages.racket" }) do
    assert(not package.loaded[name], "Standalone module leaked into VS Code: " .. name)
  end
  assert(vim.api.nvim_get_commands({}).TexBuild == nil)
  assert(not package.loaded["cmp"] and not package.loaded["luasnip"])
  assert(vim.fn.maparg("dd", "n") == '"_dd')
  for key, command in pairs({ H = "workbench.action.previousEditor", L = "workbench.action.nextEditor", x = "workbench.action.closeActiveEditor", gd = "editor.action.revealDefinition" }) do
    vim.fn.maparg(key, "n", false, true).callback()
    assert(_G.vscode_calls[#_G.vscode_calls] == command)
  end
  print("PASS: VSCode Neovim isolated startup, native actions, no plugins/LSP/insert mappings")
end, debug.traceback)
if not ok then io.stderr:write(err .. "\n"); vim.cmd("cquit 1") else vim.cmd("qa!") end
