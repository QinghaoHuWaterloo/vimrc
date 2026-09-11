require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "clangd",
    "jdtls",
    "vimls",
    "texlab",
    "marksman",
  },
  automatic_enable = false,
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local jdtls_cache = vim.fn.stdpath("cache") .. "/jdtls"
local jdtls_workspace = jdtls_cache .. "/workspace"
local jdtls_config = jdtls_cache .. "/config"
vim.fn.mkdir(jdtls_workspace, "p")
vim.fn.mkdir(jdtls_config, "p")

local function jdtls_root_dir(arg)
  local fname = arg
  if type(arg) == "number" then
    fname = vim.api.nvim_buf_get_name(arg)
  end

  if type(fname) ~= "string" or fname == "" then
    return vim.loop.cwd()
  end

  local root = vim.fs.root(fname, {
    ".project",
    ".classpath",
    "gradlew",
    "mvnw",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
    ".git",
  })

  if root then
    return root
  end

  local standalone_root = vim.fs.joinpath(
    jdtls_cache,
    "standalone",
    vim.fn.sha256(vim.fs.dirname(fname))
  )
  vim.fn.mkdir(standalone_root, "p")
  return standalone_root
end

vim.lsp.config("clangd", {
  capabilities = capabilities,
  cmd = { "clangd", "--header-insertion=never", "--background-index", "--clang-tidy=false" },
})
vim.lsp.enable("clangd")

vim.lsp.config("jdtls", {
  capabilities = capabilities,
  filetypes = { "java" },
  single_file_support = true,
  root_dir = jdtls_root_dir,
  cmd = function(dispatchers, config)
    local root_dir = config.root_dir or vim.loop.cwd()
    local project_name = vim.fn.sha256(root_dir)
    local workspace_dir = vim.fs.joinpath(jdtls_workspace, project_name)
    vim.fn.mkdir(workspace_dir, "p")

    return vim.lsp.rpc.start({
      vim.fn.stdpath("data") .. "/mason/bin/jdtls",
      "-configuration",
      jdtls_config,
      "-data",
      workspace_dir,
    }, dispatchers, {
      cwd = config.cmd_cwd,
      env = config.cmd_env,
      detached = config.detached,
    })
  end,
})
vim.lsp.enable("jdtls")

vim.lsp.config("texlab", {
  capabilities = capabilities,
  settings = {
    texlab = {
      build = {
        executable = "latexmk",
        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
        onSave = true,
        forwardSearchAfter = true,
      },
      forwardSearch = {
        executable = "zathura",
        args = { "--synctex-forward", "%l:1:%f", "%p" },
      },
    },
  },
})
vim.lsp.enable("texlab")

vim.lsp.config("marksman", {
  capabilities = capabilities,
})
vim.lsp.enable("marksman")

-- lua_ls and vimls: minimal setup, just wire in cmp capabilities
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  settings = {
    Lua = {
      -- Suppress "undefined global vim" warnings in Neovim config
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
    },
  },
})
vim.lsp.enable("lua_ls")

vim.lsp.config("vimls", { capabilities = capabilities })
vim.lsp.enable("vimls")


local function racket_root_dir(bufnr, on_dir)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname == "" then
    on_dir(vim.uv.cwd())
    return
  end

  local root = vim.fs.root(fname, { "raco.pkg", "info.rkt", ".git" }) or vim.fs.dirname(fname)
  on_dir(root)
end

vim.lsp.config("racket_langserver", {
  capabilities = capabilities,
  cmd = { "racket", "-l", "racket-langserver" },
  filetypes = { "racket" },
  root_dir = racket_root_dir,
})
vim.lsp.enable("racket_langserver")

-- ---------------------------------------------------------------------------
-- LSP tooling health check
-- ---------------------------------------------------------------------------
-- Reports missing language servers / external tools with an actionable fix.
-- Two categories:
--   * Mason-managed servers live in <data>/mason/bin (NOT the system PATH),
--     so we check for the Mason binary and suggest :MasonInstall.
--   * External tools (installed outside Mason) are checked on PATH.
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"

-- Mason-managed: { mason binary name, :MasonInstall package name }
local mason_tools = {
  { "lua-language-server", "lua-language-server" },
  { "clangd", "clangd" },
  { "jdtls", "jdtls" },
  { "vim-language-server", "vim-language-server" },
  { "texlab", "texlab" },
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
  { "latexmk", "latexmk", "install a TeX distribution (e.g. MacTeX / TeX Live)" },
  { "zathura", "zathura", "install zathura for LaTeX forward search" },
}

local function racket_langserver_missing()
  if vim.fn.executable("racket") ~= 1 then
    return true -- can't check without racket; racket itself is reported separately
  end
  local out = vim.fn.system({ "raco", "pkg", "show", "racket-langserver" })
  return vim.v.shell_error ~= 0 or out:match("not currently installed") ~= nil
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
