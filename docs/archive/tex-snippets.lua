-- LaTeX Workshop 10.18.0; original bodies and MIT license in snippets/latex-workshop.
local ls = require("luasnip")
local source = vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/snippets/latex-workshop/source.json"), "\n"))
local snippets, seen = {}, {}
for name, definition in pairs(source) do
  if definition.prefix then
    for _, trigger in ipairs({ definition.prefix, definition.prefix:lower(), definition.prefix:upper() }) do
      if not seen[trigger] then
        seen[trigger] = true
        snippets[#snippets + 1] = ls.parser.parse_snippet({
          trig = trigger, name = name, dscr = definition.description,
          priority = 2000, wordTrig = trigger:match("^%w") ~= nil,
        }, definition.body)
      end
    end
  end
end
return snippets
