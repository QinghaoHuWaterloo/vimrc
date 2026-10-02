local jdtls_cache = vim.fn.stdpath("cache") .. "/jdtls"
local jdtls_workspace = jdtls_cache .. "/workspace"
local jdtls_config = jdtls_cache .. "/config"
vim.fn.mkdir(jdtls_workspace, "p")
vim.fn.mkdir(jdtls_config, "p")

local function jdtls_root_dir(arg, on_dir)
  local fname = arg
  if type(arg) == "number" then
    fname = vim.api.nvim_buf_get_name(arg)
  end

  if type(fname) ~= "string" or fname == "" then
    on_dir(vim.uv.cwd())
    return
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
    on_dir(root)
    return
  end

  local standalone_root = vim.fs.joinpath(
    jdtls_cache,
    "standalone",
    vim.fn.sha256(vim.fs.dirname(fname))
  )
  vim.fn.mkdir(standalone_root, "p")
  on_dir(standalone_root)
end

return {
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
}
