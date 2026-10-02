local M = {}
local paths = require("config.paths")
local function warn(message)
  vim.notify(message, vim.log.levels.WARN, { title = "Run file" })
end

-- Capture the source buffer before opening a terminal; write failures stop execution.
function M.context()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" or vim.bo.buftype ~= "" then
    warn("Save a source file before running it")
    return
  end
  local ok, err = pcall(vim.cmd.write)
  if not ok then warn(tostring(err)); return end
  return { path = path, cwd = vim.fs.dirname(path), name = vim.fs.basename(path),
    stem = vim.fn.fnamemodify(path, ":t:r"), ft = vim.bo.filetype }
end

-- FTerm does not expose cwd in this installed version. Quote every shell argument.
function M.shell_command(args, cwd, timed)
  local quoted = {}
  for _, arg in ipairs(args) do quoted[#quoted + 1] = vim.fn.shellescape(arg) end
  return "cd " .. vim.fn.shellescape(cwd) .. " && "
    .. (timed and "time " or "") .. table.concat(quoted, " ")
end

local function available(args)
  if vim.fn.executable(args[1]) == 1 then return true end
  warn("Executable not found: " .. args[1])
  return false
end
local function c_family(ft) return ft == "c" or ft == "cpp" or ft == "cc" end

function M.compile_args(ctx)
  if ctx.ft == "c" then
    return { "gcc", ctx.name, "-o", ctx.stem, "-std=c17", "-Wall", "-Wextra",
      "-Wshadow", "-Wformat=2", "-Wconversion", "-pedantic" }, true
  elseif c_family(ctx.ft) then
    return { "g++", "-O2", "-std=c++2b", "-Wall", "-Wextra", "-Wfatal-errors",
      "-Wshadow", "-Wformat=2", "-Wfloat-equal", "-DLOCAL", "-Wconversion",
      "-Winvalid-pch", ctx.name, "-o", ctx.stem }, true
  elseif ctx.ft == "java" then return { "javac", ctx.name }
  elseif ctx.ft == "python" then return { "python3", ctx.name }
  elseif ctx.ft == "racket" then return { "raco", "test", ctx.name }
  end
  return { vim.o.shell }
end

function M.run_args(ctx)
  if c_family(ctx.ft) then return { vim.fs.joinpath(ctx.cwd, ctx.stem) }, true
  elseif ctx.ft == "java" then return { "java", ctx.stem }
  elseif ctx.ft == "racket" then return { "racket", ctx.name }
  end
end

function M.compile()
  local ctx = M.context()
  if not ctx then return end
  local args, timed = M.compile_args(ctx)
  if not available(args) or (timed and not available({ paths.shell })) then return end
  vim.cmd.split()
  vim.cmd.resize(30)
  vim.cmd.enew()
  local command = timed and { paths.shell, "-c", M.shell_command(args, ctx.cwd, true) } or args
  local job = vim.fn.jobstart(command, { term = true, cwd = ctx.cwd,
    on_exit = function(_, code)
      if code ~= 0 then vim.schedule(function() warn("Command exited with status " .. code) end) end
    end,
  })
  if job <= 0 then warn("Could not start command") end
end

function M.run(timed)
  local ctx = M.context()
  if not ctx then return end
  local args, default_timed = M.run_args(ctx)
  if not args then warn("Unsupported filetype: " .. ctx.ft); return end
  if not available(args) or not available({ paths.shell }) then return end
  if timed == nil then timed = default_timed end
  require("FTerm").scratch({ cmd = { paths.shell, "-c", M.shell_command(args, ctx.cwd, timed) },
    on_exit = function(_, code)
      if code ~= 0 then vim.schedule(function() warn("Command exited with status " .. code) end) end
    end,
  })
end

function M.check()
  local ctx = M.context()
  if not ctx then return end
  local args = ctx.ft == "racket" and { "raco", "test", ctx.name }
    or { paths.judge, "./" .. ctx.stem }
  if not available(args) or not available({ paths.shell }) then return end
  require("FTerm").scratch({ cmd = { paths.shell, "-c", M.shell_command(args, ctx.cwd) },
    on_exit = function(_, code)
      if code ~= 0 then vim.schedule(function() warn("Command exited with status " .. code) end) end
    end,
  })
end

function M.racket(test)
  local ctx = M.context()
  if not ctx then return end
  local args = test and { "raco", "test", ctx.name } or { "racket", ctx.name }
  if not available(args) then return end
  require("FTerm").run(M.shell_command(args, ctx.cwd))
end

function M.external()
  local ctx = M.context()
  if not ctx then return end
  local args, timed = M.run_args(ctx)
  if not args then warn("Unsupported filetype: " .. ctx.ft); return end
  if not available(args) or not available({ paths.terminal }) or not available({ paths.shell }) then return end
  local script = M.shell_command(args, ctx.cwd, timed)
    .. "; read -n 1 -s -r -p 'Press any key to exit...'"
  local job = vim.fn.jobstart({ paths.terminal, "-e", paths.shell, "-c", script }, { detach = true })
  if job <= 0 then warn("Could not start external terminal") end
end

function M.setup()
  vim.keymap.set("n", "<F9>", M.compile, { desc = "Compile or run in split" })
  vim.keymap.set("n", "<F11>", function() M.run() end, { desc = "Run in floating terminal" })
  vim.keymap.set("n", "<F12>", M.check, { desc = "Judge or test file" })
  vim.keymap.set("n", "<F10>", function()
    local path = vim.api.nvim_buf_get_name(0)
    if path ~= "" then vim.cmd.cd(vim.fn.fnameescape(vim.fs.dirname(path))) end
    require("FTerm").toggle()
  end, { desc = "Toggle terminal in file directory" })
  -- Compatibility for existing :lua calls; maps use module functions directly.
  _G.R = M.compile
  _G.M = function() M.run() end
  _G.Modd = function() M.run(false) end
  _G.Mode = M.external
  _G.Check = M.check
end
return M
