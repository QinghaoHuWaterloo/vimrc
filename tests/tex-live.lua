return function(root, edit)
  if vim.env.NVIM_TEST_REAL_TEX ~= "1" then return end
  local tex = require("languages.tex")
  local directory = root .. "/real tex ' $ ` project"
  vim.fn.mkdir(directory, "p")
  edit(directory .. "/main.tex")
  vim.b.tex_output_directory = "output space"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, {
    "\\documentclass{article}", "\\begin{document}", "Real tex-mode build.", "\\end{document}",
  })
  local cwd, path = vim.fn.getcwd(), vim.env.PATH
  local system = vim.system
  local calls = 0
  vim.system = function(args, opts, callback)
    assert(args[1] ~= "zathura", "Real build launched a viewer")
    calls = calls + 1
    return system(args, opts, callback)
  end
  -- This writes the document and exercises BufWritePost and the asynchronous job.
  vim.cmd("TexBuild")
  local project = assert(tex.context())
  assert(vim.wait(30000, function() return project.status ~= nil and not project.running end), "Real TeX build timed out")
  vim.system = system
  assert(project.status == 0, table.concat(project.log, "\n"))
  assert(calls == 1, "Expected one real compiler invocation")
  local output = directory .. "/output space/main"
  assert(vim.fn.getfsize(output .. ".pdf") > 0)
  assert(vim.fn.getfsize(output .. ".synctex.gz") > 0)
  assert(table.concat(project.log, "\n"):find("MiKTeX", 1, true))
  assert(vim.fn.getcwd() == cwd and vim.env.PATH == path)
  print("PASS: real tex-mode save/build with MiKTeX, PDF, SyncTeX, special paths, no viewer")
end
