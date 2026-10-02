local group = vim.api.nvim_create_augroup("RacketCS135", { clear = true })

local Racket = {}

function Racket.indent()
  local previous = vim.fn.prevnonblank(vim.v.lnum - 1)
  local line = vim.fn.getline(previous)
  local current = vim.fn.getline(vim.v.lnum)
  local closing = current:match("^%s*([%)%]%}])")
  if closing then
    local opening = { [")"] = "(", ["]"] = "\\[", ["}"] = "{" }
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.fn.cursor(vim.v.lnum, #current:match("^%s*") + 1)
    local match = vim.fn.searchpairpos(opening[closing], "", closing == "]" and "\\]" or closing,
      "bnW", 'synIDattr(synID(line("."), col("."), 1), "name") =~? "string\\|comment"')
    vim.api.nvim_win_set_cursor(0, cursor)
    if match[1] > 0 then
      return vim.fn.indent(match[1])
    end
  end
  if line:match("[%(%[%{]%s*$") and not closing then
    local column = #line:gsub("%s+$", "")
    local syntax = vim.fn.synIDattr(vim.fn.synID(previous, column, 1), "name"):lower()
    if not syntax:match("string") and not syntax:match("comment") then
      return vim.fn.indent(previous) + vim.bo.shiftwidth
    end
  end
  return vim.fn.lispindent(vim.v.lnum)
end

vim.filetype.add({ extension = { rkt = "racket", rktl = "racket" } })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "racket",
  callback = function(event)
    local options = vim.bo[event.buf]
    -- CS135/DrRacket convention: two-space indentation and semicolon comments.
    options.tabstop = 2
    options.softtabstop = 2
    options.shiftwidth = 2
    options.expandtab = true
    options.commentstring = "; %s"
    -- After a trailing opener, indent one step from the start of its line.
    options.lisp = false
    options.indentexpr = "v:lua.require'languages.racket'.indent()"
    options.indentkeys = "o,O,0),0],0}"

    vim.keymap.set({ "i", "s" }, "<Tab>", function()
      local snippets = require("luasnip")
      if snippets.expand_or_jumpable() then
        snippets.expand_or_jump()
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
      end
    end, { buffer = event.buf, desc = "Racket: expand or advance snippet" })
    vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
      local snippets = require("luasnip")
      if snippets.jumpable(-1) then
        snippets.jump(-1)
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true), "n", false)
      end
    end, { buffer = event.buf, desc = "Racket: previous snippet field" })

    vim.keymap.set("n", "<leader>rr", function() require("features.runner").racket(false) end, {
      buffer = event.buf,
      desc = "Racket: run in FTerm",
    })
    vim.keymap.set("n", "<leader>rt", function() require("features.runner").racket(true) end, {
      buffer = event.buf,
      desc = "Racket: run raco test",
    })
    vim.keymap.set("n", "<leader>rf", function()
      vim.cmd("normal! gg=G")
    end, {
      buffer = event.buf,
      desc = "Racket: reindent buffer",
    })
  end,
})

return Racket
