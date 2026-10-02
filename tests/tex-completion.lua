return function(root, edit)
  local completion = require("languages.tex_completion")
  local cmp, ls = require("cmp"), require("luasnip")
  edit(root .. "/completion.tex")
  assert(cmp.get_config().performance.debounce == 15)
  assert(cmp.get_config().performance.fetching_timeout == 50)
  local source = completion.source()
  local function request(line)
    local result
    source:complete({ context = { cursor_before_line = line } }, function(response) result = response end)
    return assert(result, "Local command source must return synchronously").items
  end
  local section
  for _, item in ipairs(request("text \\sec")) do
    if item.label == "\\section{}" then section = item end
  end
  assert(section and section.insertText == "\\section{${1}}")
  assert(section.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet)
  assert(#request("\\ref{existing") == 0 and #request("plain prose") == 0)
  assert(#request("\\\\") == 0)
  assert(#request("\\") > 0)
  assert(not completion.lsp_filter({ get_completion_item = function() return { label = "section", textEdit = { newText = "section" } } end }, { cursor_before_line = "\\sec" }))
  assert(completion.lsp_filter({ get_completion_item = function() return { label = "customcommand" } end }, { cursor_before_line = "\\cus" }))
  assert(completion.lsp_filter({ get_completion_item = function() return { label = "section", insertText = "section{${1}}" } end }, { cursor_before_line = "\\sec" }))
  assert(completion.lsp_filter({ get_completion_item = function() return { label = "section" } end }, { cursor_before_line = "\\ref{sec" }))
  local start = vim.uv.hrtime()
  for _ = 1, 1000 do request("\\sec") end
  local average_ms = (vim.uv.hrtime() - start) / 1e6 / 1000
  assert(average_ms < 5, "Local command lookup is too slow")

  edit(root .. "/completion-isolation.cpp")
  assert(cmp.get_config().performance.debounce == 60)
  for _, entry in ipairs(cmp.get_config().sources) do assert(entry.name ~= "tex_commands") end
  print(string.format("PASS: command snippet bodies/filters, TeX-only latency settings; local lookup %.3f ms", average_ms))
end
