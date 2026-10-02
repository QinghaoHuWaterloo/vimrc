return function(root, edit)
  local runner = require("features.runner")
  local cwd = vim.fn.getcwd()
  edit(root .. "/real.cpp")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { '#include <iostream>', 'int main() { std::cout << "cpp-ok"; }' })
  vim.cmd.write()
  local args = runner.compile_args({ ft = "cpp", name = "real.cpp", stem = "real" })
  for _, flag in ipairs({ "-O2", "-std=c++2b", "-DLOCAL", "-Wall", "-Wconversion" }) do assert(vim.tbl_contains(args, flag)) end
  local result = vim.system(args, { cwd = root, text = true }):wait()
  assert(result.code == 0, result.stderr)
  assert(vim.system({ root .. "/real" }, { cwd = root, text = true }):wait().stdout == "cpp-ok")
  local java = require("languages.lsp.java")
  local start, captured = vim.lsp.rpc.start, nil
  vim.lsp.rpc.start = function(command, dispatchers, options)
    captured = { command = command, options = options, dispatchers = dispatchers }
    return {}
  end
  local dispatchers = {}
  java.cmd(dispatchers, { root_dir = root, cmd_cwd = root, cmd_env = { TEST = "yes" }, detached = true })
  vim.lsp.rpc.start = start
  assert(captured.dispatchers == dispatchers and captured.options.cwd == root)
  assert(captured.command[1] == vim.fn.stdpath("data") .. "/mason/bin/jdtls")
  assert(captured.command[3] == vim.fn.stdpath("cache") .. "/jdtls/config")
  assert(captured.command[5] == vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. vim.fn.sha256(root))
  assert(vim.deep_equal(runner.compile_args({ ft = "java", name = "Main.java" }), { "javac", "Main.java" }))
  assert(vim.deep_equal(runner.run_args({ ft = "java", stem = "Main" }), { "java", "Main" }))
  edit(root .. "/regression.rkt")
  assert(require("cmp").get_config().enabled == false)
  assert(vim.tbl_contains(require("nvim-autopairs").config.disable_filetype, "racket"))
  for _, key in ipairs({ "<leader>rr", "<leader>rt", "<leader>rf", "<Tab>", "<S-Tab>" }) do
    local mode = key:find("Tab", 1, true) and "i" or "n"
    assert(vim.fn.maparg(key, mode, false, true).buffer == 1)
  end
  assert(vim.deep_equal(runner.compile_args({ ft = "racket", name = "test.rkt" }), { "raco", "test", "test.rkt" }))
  assert(vim.deep_equal(runner.run_args({ ft = "racket", name = "test.rkt" }), { "racket", "test.rkt" }))
  assert(vim.fn.getcwd() == cwd)
  print("PASS: real C++ compile/run, Java dispatch/workspaces, Racket run/test keys")
end
