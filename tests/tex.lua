return function(root, edit)
  local tex, ls, cmp = require("languages.tex"), require("luasnip"), require("cmp")
  local cwd, path = vim.fn.getcwd(), vim.env.PATH
  edit(root .. "/snippet.tex")
  assert(vim.b.tex_mode and vim.bo.shiftwidth == 2 and vim.bo.softtabstop == 2 and vim.bo.expandtab)
  assert(vim.wo.wrap and vim.wo.spell and vim.wo.linebreak)
  assert(vim.bo.indentexpr == "VimtexIndentExpr()")
  local source = vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/snippets/latex-workshop/source.json"), "\n"))
  local loaded = {}
  for _, snippet in ipairs(ls.get_snippets("tex")) do
    if snippet.priority == 2000 then loaded[snippet.trigger] = snippet end
  end
  local count, definitions = 0, 0
  local seen = {}
  local function expand(snippet, selected)
    ls.unlink_current()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    local expanded = ls.snip_expand(snippet, { expand_params = { env_override = selected and { TM_SELECTED_TEXT = vim.deepcopy(selected) } or {} }, jump_into_func = function(snip) return snip.insert_nodes[0] end })
    local text = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local nodes = {}
    for position, node in pairs(expanded.insert_nodes) do nodes[position] = node.pos end
    return text, nodes
  end
  for name, definition in pairs(source) do
    if definition.prefix then
      definitions = definitions + 1
      for _, trigger in ipairs({ definition.prefix, definition.prefix:upper(), definition.prefix:lower() }) do
        if not seen[trigger] then
          seen[trigger], count = true, count + 1
          local snippet = assert(loaded[trigger], "Missing Workshop alias: " .. trigger)
          for _, selected in ipairs({ {}, { "selected text" }, { "line one", "line two" } }) do
            local expected, placeholders = expand(ls.parser.parse_snippet("expected", definition.body), selected)
            local actual, positions = expand(snippet, selected)
            assert(vim.deep_equal(expected, actual), "Expansion mismatch: " .. name .. "/" .. trigger .. " expected=" .. vim.inspect(expected) .. " actual=" .. vim.inspect(actual))
            assert(vim.deep_equal(placeholders, positions), "Placeholder mismatch: " .. trigger)
          end
        end
      end
    end
  end
  assert(definitions == 51 and count == 99)
  ls.unlink_current()
  -- An exact trigger must win even when the completion popup is visible.
  local visible, abort, next_item = cmp.visible, cmp.abort, cmp.select_next_item
  local aborted, advanced = false, false
  cmp.visible = function() return true end
  cmp.abort = function() aborted = true end
  cmp.select_next_item = function() advanced = true end
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "bfi " })
  vim.api.nvim_win_set_cursor(0, { 1, 3 })
  tex.tab(function() error("Exact snippet fell back") end)
  assert(aborted and not advanced and vim.fn.getline(1):find("\\begin{figure}", 1, true))
  tex.tab(function() error("Navigation fell back") end)
  assert(ls.locally_jumpable(-1))
  tex.backtab(function() error("Backward navigation fell back") end)
  ls.unlink_current()
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "ordinary " })
  vim.api.nvim_win_set_cursor(0, { 1, 8 })
  tex.tab(function() error("Completion fell back") end)
  assert(advanced)
  cmp.visible, cmp.abort, cmp.select_next_item = visible, abort, next_item
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "before selected after" })
  tex.wrap("align*", 1, 1, 7, 15)
  assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), { "before ", "\\begin{align*}", "  selected", "\\end{align*} after" }))
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "xt", false)
  -- Exercise the actual visual mappings and LuaSnip selection storage.
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "selected" })
  vim.cmd("normal! gg0v$")
  local keys = vim.api.nvim_replace_termcodes("<Tab><Esc>", true, false, true)
  vim.api.nvim_feedkeys(keys, "xt", false)
  local selected_text, _ = expand(loaded.fbf, nil)
  assert(table.concat(selected_text, "\n"):find("selected", 1, true), "Visual Tab lost selection")
  ls.unlink_current()
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "wrapped" })
  vim.cmd("normal! gg0v$")
  local input = vim.ui.input
  vim.ui.input = function(_, callback) callback("equation*") end
  vim.fn.maparg("<leader>tw", "x", false, true).callback()
  vim.ui.input = input
  assert(vim.fn.getline(2) == "\\begin{equation*}" and vim.fn.getline(3) == "  wrapped")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "\\begin{itemize}", "\\item test", "\\end{itemize}" })
  vim.cmd("normal! gg=G")
  assert(vim.fn.indent(2) == 2, "VimTeX indentation failed: " .. vim.inspect(vim.api.nvim_buf_get_lines(0, 0, -1, false)))
  for _, ft in ipairs({ "c", "cpp", "racket", "java", "markdown" }) do
    edit(root .. "/switch-" .. ft .. ".tex")
    local sources = cmp.get_config().sources
    for _, item in ipairs(sources) do assert(item.name ~= "buffer") end
    edit(root .. "/switch." .. ({ c = "c", cpp = "cpp", racket = "rkt", java = "java", markdown = "md" })[ft])
    assert(not vim.b.tex_mode)
    assert(vim.wo.spell == (ft == "markdown"))
    assert(vim.wo.wrap == (ft == "markdown"))
    assert(vim.fn.maparg("<leader>tb", "n") == "")
    if ft == "racket" then assert(cmp.get_config().enabled == false)
    elseif ft ~= "markdown" then assert(vim.bo.shiftwidth == 4) end
  end
  local weird = root .. "/tex ' $ ` space"
  vim.fn.mkdir(weird, "p")
  vim.fn.writefile({ "% !TeX program = xelatex", "\\documentclass{article}" }, weird .. "/main.tex")
  vim.fn.writefile({ "% !TeX root = main.tex" }, weird .. "/child.tex")
  assert(tex.main(weird .. "/child.tex") == weird .. "/main.tex")
  edit(weird .. "/child.tex")
  local project = assert(tex.context())
  assert(project.main == weird .. "/main.tex")
  assert(vim.tbl_contains(tex.arguments(project), "-xelatex"))
  assert(tex.arguments(project)[#tex.arguments(project)] == "main.tex")
  vim.cmd("TexEngine pdflatex")
  assert(vim.tbl_contains(tex.arguments(project), "-pdf"))
  project.engine = nil
  vim.fn.writefile({}, weird .. "/.latexmkrc")
  vim.fn.writefile({}, weird .. "/main.tex")
  assert(not vim.tbl_contains(tex.arguments(project), "-lualatex"))
  project.out_dir = "output ' $"
  assert(vim.tbl_contains(tex.arguments(project), "-outdir=output ' $"))
  -- Fake child launch validates coalescing/argv/env/failures and viewer isolation.
  local system, executable, notify = vim.system, vim.fn.executable, vim.notify
  local callbacks, launches, notices = {}, {}, {}
  vim.fn.executable = function() return 1 end
  vim.notify = function(message) notices[#notices + 1] = message end
  vim.system = function(args, opts, callback)
    assert(args[1] ~= "zathura", "Automatic viewer launch")
    assert(opts.cwd == weird and opts.env.PATH == tex.environment().PATH)
    launches[#launches + 1], callbacks[#callbacks + 1] = args, callback
    return {}
  end
  tex.start(project); tex.start(project); tex.start(project)
  assert(#launches == 1 and project.pending)
  callbacks[1]({ code = 0, stdout = "ok", stderr = "" })
  vim.wait(1000, function() return #launches == 2 end)
  assert(#launches == 2 and not project.pending)
  callbacks[2]({ code = 7, stdout = "", stderr = "failure" })
  vim.wait(1000, function() return not project.running end)
  assert(project.status == 7 and notices[#notices]:find("Build failed", 1, true))
  vim.system, vim.fn.executable, vim.notify = system, executable, notify
  assert(vim.fn.getcwd() == cwd and vim.env.PATH == path)
  assert(vim.lsp.config.texlab.settings.texlab.build.onSave == false)
  assert(vim.lsp.config.texlab.settings.texlab.build.forwardSearchAfter == false)
  print("PASS: 51 Workshop definitions, 99 aliases, selections, placeholders, TeX isolation and build scheduling")
end
