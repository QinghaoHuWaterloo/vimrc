-- Warn once if the racket-langserver package is missing.
-- On a fresh machine (e.g. macOS), install it with:  raco pkg install racket-langserver
-- Without it, `racket -l racket-langserver` exits 1 and the LSP won't start.
local racket_langserver_checked = false
local function check_racket_langserver()
  if racket_langserver_checked then
    return
  end
  racket_langserver_checked = true

  if vim.fn.executable("racket") ~= 1 then
    vim.notify(
      "Racket not found on PATH. Install Racket to enable the LSP.",
      vim.log.levels.WARN,
      { title = "Racket LSP" }
    )
    return
  end

  -- `raco pkg show` exits non-zero / prints "not currently installed"
  -- when the package is absent.
  local out = vim.fn.system({ "raco", "pkg", "show", "racket-langserver" })
  if vim.v.shell_error ~= 0 or out:match("not currently installed") then
    vim.notify(
      "racket-langserver package is missing. Run:  raco pkg install racket-langserver",
      vim.log.levels.WARN,
      { title = "Racket LSP" }
    )
  end
end

local group = vim.api.nvim_create_augroup("RacketCS135", { clear = true })

vim.filetype.add({ extension = { rkt = "racket", rktl = "racket" } })

local function run_file(test)
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("Save your Racket file before running it", vim.log.levels.WARN)
    return
  end
  vim.cmd("write")
  local command = test and "raco test " or "racket "
  require("FTerm").run(command .. vim.fn.shellescape(path))
end

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "racket",
  callback = function(event)
    check_racket_langserver()
    local options = vim.bo[event.buf]
    -- CS135/DrRacket convention: two-space indentation and semicolon comments.
    options.tabstop = 2
    options.softtabstop = 2
    options.shiftwidth = 2
    options.expandtab = true
    options.commentstring = "; %s"

    vim.keymap.set("n", "<leader>rr", function() run_file(false) end, {
      buffer = event.buf,
      desc = "Racket: run in FTerm",
    })
    vim.keymap.set("n", "<leader>rt", function() run_file(true) end, {
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
