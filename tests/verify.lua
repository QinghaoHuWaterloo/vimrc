local function verify()
  local root = assert(vim.env.NVIM_TEST_ROOT)
  assert(#startup_errors == 0, table.concat(startup_errors, "\n"))
  for _, file in ipairs(vim.fn.glob(vim.fn.stdpath("config") .. "/lua/**/*.lua", false, true)) do
    assert(loadfile(file), "Invalid Lua: " .. file)
  end
  local lazy = require("lazy.core.config")
  assert(#lazy.spec.notifs == 0, vim.inspect(lazy.spec.notifs))
  local lock = vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/lazy-lock.json"), "\n"))
  for name in pairs(lock) do assert(lazy.plugins[name], "Missing plugin: " .. name) end
  for name, plugin in pairs(lazy.plugins) do
    assert(lock[name], "Unexpected plugin: " .. name)
    if name ~= "trouble.nvim" then assert(plugin._.loaded, "Not loaded: " .. name) end
  end
  assert(not lazy.plugins["trouble.nvim"]._.loaded, "Trouble should retain lazy loading")
  assert(vim.g.colors_name == "kanagawa", "Startup theme changed: " .. tostring(vim.g.colors_name))
  assert(vim.diagnostic.config().virtual_text == false)
  for _, command in ipairs({ "LspToolCheck", "Md2Pdf", "FTermToggle" }) do
    assert(vim.api.nvim_get_commands({})[command], "Missing command: " .. command)
  end
  for _, key in ipairs({ "<F2>", "<F3>", "<F5>", "<F6>", "<F7>", "<F8>", "<F9>", "<F10>", "<F11>", "<F12>", "H", "L", "x", "U" }) do
    assert(vim.fn.maparg(key, "n") ~= "", "Missing map: " .. key)
  end
  for _, server in ipairs({ "clangd", "jdtls", "marksman", "lua_ls", "vimls", "racket_langserver" }) do
    assert(vim.lsp.is_enabled(server), "Server not enabled: " .. server)
    assert(vim.lsp.config[server].capabilities.textDocument.completion.completionItem.snippetSupport)
    -- Behavioral checks don't need actual servers or trigger installation.
    vim.lsp.enable(server, false)
  end
  local function edit(path)
    vim.cmd("enew!")
    vim.api.nvim_buf_set_name(0, path)
    vim.cmd.filetype("detect")
  end
  dofile(root .. "/tests/language-regressions.lua")(root, edit)
  local java = require("languages.lsp.java")
  vim.fn.mkdir(root .. "/project", "p")
  vim.fn.writefile({}, root .. "/project/pom.xml")
  edit(root .. "/project/Main.java")
  local project_root
  java.root_dir(0, function(dir) project_root = dir end)
  assert(project_root == root .. "/project")
  vim.fn.mkdir(root .. "/standalone", "p")
  edit(root .. "/standalone/One.java")
  -- The managed environment may place a .git marker in /tmp itself.
  local find_root = vim.fs.root
  vim.fs.root = function() return nil end
  local standalone
  java.root_dir(0, function(dir) standalone = dir end)
  edit(root .. "/standalone/Two.java")
  java.root_dir(0, function(dir) assert(dir == standalone) end)
  assert(standalone:find("/jdtls/standalone/", 1, true), "Unexpected standalone root: " .. standalone .. " buffer: " .. vim.api.nvim_buf_get_name(0))

  vim.fs.root = find_root

  edit(root .. "/lesson.rkt")
  assert(vim.bo.filetype == "racket")
  assert(vim.bo.shiftwidth == 2 and vim.bo.expandtab and vim.bo.softtabstop == 2)
  assert(vim.bo.indentexpr == "v:lua.require'languages.racket'.indent()")
  assert(require("cmp").get_config().enabled == false)
  assert(vim.fn.maparg("<Tab>", "i", false, true).buffer == 1)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "(define (foo x)", "(cond", "[else", "x", "]", ")", ")" })
  vim.cmd("normal! gg=G")
  assert(vim.fn.indent(4) == vim.fn.indent(3) + 2)
  assert(vim.fn.indent(5) == vim.fn.indent(3))
  assert(vim.fn.indent(6) == vim.fn.indent(2))
  assert(vim.fn.indent(7) == vim.fn.indent(1))
  local ls = require("luasnip")
  local triggers = {}
  for _, snippet in ipairs(ls.get_snippets("racket")) do triggers[snippet.trigger] = snippet end
  for _, trigger in ipairs({ "bsl", "def", "check", "cond", "struct" }) do
    assert(triggers[trigger], "Snippet missing: " .. trigger)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    ls.snip_expand(triggers[trigger])
    assert(vim.fn.getline(1) ~= "", "Snippet didn't expand: " .. trigger)
    if trigger == "def" then
      assert(ls.jumpable(1))
      vim.fn.maparg("<Tab>", "i", false, true).callback()
      assert(ls.jumpable(-1))
      vim.fn.maparg("<S-Tab>", "i", false, true).callback()
      assert(ls.jumpable(1))
    end
    ls.unlink_current()
  end

  edit(root .. "/document.md")
  assert(vim.wo.wrap and vim.wo.linebreak and vim.wo.spell and vim.bo.textwidth == 80)
  assert(vim.fn.maparg("<F9>", "n", false, true).buffer == 1)
  assert(vim.fn.maparg("<F9>", "n") == "<Cmd>Md2Pdf<CR>" or vim.fn.maparg("<F9>", "n") == "<cmd>Md2Pdf<CR>")
  local runner = require("features.runner")
  local cwd = vim.fn.getcwd()
  local weird = root .. "/space ' quote $dollar `tick`"
  vim.fn.mkdir(weird, "p")
  local args = { "printf", "%s", "a ' b $HOME `uname`" }
  local out = vim.fn.system({ "bash", "-c", runner.shell_command(args, weird) })
  assert(vim.v.shell_error == 0 and out == args[3], out)
  assert(vim.fn.getcwd() == cwd)

  local notices = {}
  local notify = vim.notify
  vim.notify = function(message) notices[#notices + 1] = message end
  vim.cmd("enew!")
  assert(runner.context() == nil)
  assert(#notices == 1)
  edit(weird .. "/hello ' world.c")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "int main(void) { return 0; }" })
  local context = assert(runner.context())
  assert(context.cwd == weird)
  local gcc, timed = runner.compile_args(context)
  assert(gcc[2] == "hello ' world.c" and timed)
  -- Execute the real compile/run path, including working directory and spaced names.
  assert(vim.fn.executable("gcc") == 1, "gcc is required for the runner regression test")
  local jobstart = vim.fn.jobstart
  local compile_job
  vim.fn.jobstart = function(command, options)
    compile_job = jobstart(command, options)
    return compile_job
  end
  runner.compile()
  vim.fn.jobstart = jobstart
  assert(compile_job and compile_job > 0)
  assert(vim.fn.jobwait({ compile_job }, 10000)[1] == 0, "C compile failed")
  assert(vim.fn.getcwd() == cwd)
  assert(vim.fn.executable(weird .. "/hello ' world") == 1)
  vim.fn.system({ weird .. "/hello ' world" })
  assert(vim.v.shell_error == 0)
  vim.cmd("close!")
  assert(vim.api.nvim_buf_get_name(0) == context.path)
  local termopen = vim.fn.termopen
  local run_job
  vim.fn.termopen = function(command, options)
    run_job = termopen(command, options)
    return run_job
  end
  runner.run(false)
  vim.fn.termopen = termopen
  assert(run_job and run_job > 0)
  assert(vim.fn.jobwait({ run_job }, 10000)[1] == 0, "Floating C run failed")
  assert(vim.fn.getcwd() == cwd)
  vim.cmd("close!")
  assert(vim.api.nvim_buf_get_name(0) == context.path)
  local recorded
  local fterm = require("FTerm")
  local scratch = fterm.scratch
  fterm.scratch = function(options) recorded = options.cmd end
  local paths = require("config.paths")
  paths.judge = "printf"
  runner.check()
  assert(recorded[1] == "bash")
  assert(vim.fn.getcwd() == cwd)
  paths.judge = root .. "/missing-judge"
  local count = #notices
  runner.check()
  assert(#notices == count + 1)
  fterm.scratch = scratch

  -- PDF converter argv and failure reporting without a real TeX build.
  edit(weird .. "/notes ' draft.md")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# Test" })
  local converter = root .. "/fake converter"
  vim.fn.writefile({ "#!/bin/sh", 'printf "%s\\n%s\\n" "$1" "$2" > "$NVIM_TEST_ROOT/pdf-args"', "exit 7" }, converter)
  vim.fn.setfperm(converter, "rwx------")
  paths.md2pdf = converter
  require("features.markdown").export()
  local pdf_args = vim.fn.readfile(root .. "/pdf-args")
  assert(pdf_args[1] == weird .. "/notes ' draft.md")
  assert(pdf_args[2] == weird .. "/notes ' draft.pdf")
  assert(notices[#notices]:find("md2pdf failed", 1, true))
  local input = vim.fn.input
  vim.fn.input = function() return "" end
  require("features.templates").insert()
  vim.fn.input = input
  assert(#startup_errors == 0, table.concat(startup_errors, "\n"))
  vim.notify = notify

  -- Cycle all themes, returning to the initial wave variant.
  for _, name in ipairs({ "kanagawa-dragon", "onedark", "solarized8_flat", "kanagawa-wave" }) do
    require("features.themes").toggle()
    assert(vim.g.colors_name == name or (name:find("kanagawa", 1, true) and vim.g.colors_name == "kanagawa"))
  end
  assert(not package.loaded["optional.treesitter"] and not package.loaded["optional.noice"])
  print("PASS: startup, plugin set, LSP roots, language settings, snippets, paths, commands and themes")
end
local ok, err = xpcall(verify, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end
