local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"

-- Mason-managed: { mason binary name, :MasonInstall package name }
local mason_tools = {
  { "lua-language-server", "lua-language-server" },
  { "clangd", "clangd" },
  { "jdtls", "jdtls" },
  { "vim-language-server", "vim-language-server" },
  { "marksman", "marksman" },
}

-- External tools not managed by Mason: { display name, PATH executable, fix hint }
local external_tools = {
  { "racket", "racket", "install Racket (https://racket-lang.org)" },
  {
    "racket-langserver",
    nil, -- special-cased below via `raco pkg show`
    "raco pkg install racket-langserver",
  },
}

local racket_missing_cache
local function racket_langserver_missing()
  if racket_missing_cache ~= nil then return racket_missing_cache end
  if vim.fn.executable("racket") ~= 1 or vim.fn.executable("raco") ~= 1 then
    return true -- can't check without racket; racket itself is reported separately
  end
  local out = vim.fn.system({ "raco", "pkg", "show", "racket-langserver" })
  racket_missing_cache = vim.v.shell_error ~= 0 or out:match("not currently installed") ~= nil
  return racket_missing_cache
end

-- Returns a list of { name, fix } for everything that is missing.
local function collect_missing()
  local missing = {}

  for _, t in ipairs(mason_tools) do
    local bin, pkg = t[1], t[2]
    if vim.fn.executable(mason_bin .. bin) ~= 1 and vim.fn.executable(bin) ~= 1 then
      table.insert(missing, { name = bin, fix = ":MasonInstall " .. pkg })
    end
  end

  for _, t in ipairs(external_tools) do
    local name, exe, fix = t[1], t[2], t[3]
    local is_missing
    if name == "racket-langserver" then
      is_missing = racket_langserver_missing()
    else
      is_missing = vim.fn.executable(exe) ~= 1
    end
    if is_missing then
      table.insert(missing, { name = name, fix = fix })
    end
  end

  return missing
end

-- :LspToolCheck — full report of every tool (present + missing).
vim.api.nvim_create_user_command("LspToolCheck", function()
  racket_missing_cache = nil
  local lines = { "LSP tooling status:", "" }

  local function report(list, resolver)
    for _, t in ipairs(list) do
      local name = t[1]
      local ok = resolver(t)
      table.insert(lines, string.format("  %s %s", ok and "✓" or "✗", name))
    end
  end

  table.insert(lines, "Mason-managed:")
  report(mason_tools, function(t)
    return vim.fn.executable(mason_bin .. t[1]) == 1 or vim.fn.executable(t[1]) == 1
  end)

  table.insert(lines, "")
  table.insert(lines, "External:")
  report(external_tools, function(t)
    if t[1] == "racket-langserver" then
      return not racket_langserver_missing()
    end
    return vim.fn.executable(t[2]) == 1
  end)

  local missing = collect_missing()
  if #missing > 0 then
    table.insert(lines, "")
    table.insert(lines, "Fixes:")
    for _, m in ipairs(missing) do
      table.insert(lines, string.format("  %s -> %s", m.name, m.fix))
    end
  end

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "LSP tooling" })
end, { desc = "Report status of LSP servers and external tools" })

-- Warn once, shortly after startup, only about what is actually missing.
vim.defer_fn(function()
  local missing = collect_missing()
  if #missing == 0 then
    return
  end
  local lines = { "Missing LSP tools (run :LspToolCheck for details):" }
  for _, m in ipairs(missing) do
    table.insert(lines, string.format("  %s -> %s", m.name, m.fix))
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.WARN, { title = "LSP tooling" })
end, 1000)
