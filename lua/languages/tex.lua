local M = { projects = {} }
local paths = require("config.paths")
local engines = { lualatex = "-lualatex", xelatex = "-xelatex", pdflatex = "-pdf" }
local function fail(message) vim.notify("tex-mode: " .. message, vim.log.levels.ERROR) end
local function read(path)
  if vim.fn.filereadable(path) == 1 then return vim.fn.readfile(path) end
  return {}
end
function M.main(path)
  path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
  local seen = {}
  while not seen[path] do
    seen[path] = true
    local target
    for _, line in ipairs(read(path)) do
      target = line:match("^%s*%%%s*!%s*[Tt][Ee][Xx]%s+root%s*=%s*(.-)%s*$")
      if target then break end
    end
    if not target then return path end
    path = vim.fs.normalize(vim.fn.fnamemodify(target:sub(1, 1) == "/" and target or vim.fs.dirname(path) .. "/" .. target, ":p"))
  end
  error("Cyclic % !TeX root directive")
end
function M.context()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then fail("Save the document first"); return end
  local ok, main = pcall(M.main, path)
  if not ok then fail(main); return end
  -- VimTeX also resolves projects without explicit root directives.
  if main == path and vim.b.vimtex and vim.b.vimtex.tex then main = vim.b.vimtex.tex end
  local project = M.projects[main]
  if not project then
    project = { main = main, cwd = vim.fs.dirname(main), log = {} }
    M.projects[main] = project
  end
  return project
end
function M.environment()
  return {
    PATH = paths.miktex_bin .. ":" .. (vim.env.PATH or ""),
    TEXINPUTS = paths.tex_styles .. "//:" .. (vim.env.TEXINPUTS or ""),
  }
end
function M.arguments(project)
  local args = { paths.tex_latexmk, "-synctex=1", "-interaction=nonstopmode", "-file-line-error", "-recorder" }
  local engine = project.engine
  for _, line in ipairs(read(project.main)) do
    local directive = line:match("^%s*%%%s*!%s*[Tt][Ee][Xx]%s+[Pp][Rr][Oo][Gg][Rr][Aa][Mm]%s*=%s*(.-)%s*$")
    if not engine and directive then engine = directive:lower() end
  end
  local rc = vim.fn.filereadable(project.cwd .. "/.latexmkrc") == 1
    or vim.fn.filereadable(project.cwd .. "/latexmkrc") == 1
  if engine or not rc then
    engine = engine or "lualatex"
    if not engines[engine] then error("Unsupported engine: " .. engine) end
    args[#args + 1] = engines[engine]
  end
  -- Keep latexmkrc engine command overrides; the child PATH selects MiKTeX only.
  local out = project.out_dir or vim.b.tex_output_directory or vim.env.VIMTEX_OUTPUT_DIRECTORY
  if out and out ~= "" then args[#args + 1] = "-outdir=" .. out end
  args[#args + 1] = vim.fs.basename(project.main)
  return args
end
function M.start(project)
  if project.running then project.pending = true; return end
  if vim.fn.executable(paths.miktex_bin .. "/lualatex") ~= 1
    or vim.fn.executable(paths.miktex) ~= 1 then
    fail("Private MiKTeX missing at " .. paths.miktex_bin .. "; see scripts/install-miktex.sh")
    return
  end
  if vim.fn.executable(paths.tex_latexmk) ~= 1 then fail("latexmk is missing"); return end
  local ok, args = pcall(M.arguments, project)
  if not ok then fail(args); return end
  project.running, project.pending = true, false
  local launched, job = pcall(vim.system, args, { cwd = project.cwd, env = M.environment(), text = true }, function(result)
    vim.schedule(function()
      project.running = false
      project.log = vim.split((result.stdout or "") .. (result.stderr or ""), "\n", { plain = true })
      project.status = result.code
      local output = (result.stdout or "") .. (result.stderr or "")
      local pdf = output:match("All targets %((.-%.pdf)%)") or output:match('Output written on "?([^"\n]-%.pdf)')
      if pdf then
        local candidate = pdf:sub(1, 1) == "/" and pdf or project.cwd .. "/" .. pdf
        if vim.fn.filereadable(candidate) == 1 then project.pdf = candidate end
      end
      if result.code ~= 0 then fail("Build failed (" .. result.code .. "): " .. project.main .. "; :TexLog") end
      if project.pending then M.start(project) end
    end)
  end)
  if launched then project.job = job
  else project.running = false; fail("Could not start latexmk: " .. tostring(job)) end
end
function M.build(save)
  local project = M.context()
  if not project then return end
  if save and vim.bo.modified then
    local ok, err = pcall(vim.cmd, "write")
    if not ok then fail(err) end
    return -- BufWritePost submits exactly one build
  end
  M.start(project)
end
function M.tab(fallback)
  local ls, cmp = require("luasnip"), require("cmp")
  if ls.expandable() then cmp.abort(); ls.expand()
  elseif ls.locally_jumpable(1) then ls.jump(1)
  elseif cmp.visible() then cmp.select_next_item()
  else fallback() end
end
function M.backtab(fallback)
  local ls, cmp = require("luasnip"), require("cmp")
  if ls.locally_jumpable(-1) then ls.jump(-1)
  elseif cmp.visible() then cmp.select_prev_item()
  else fallback() end
end
function M.wrap(environment, first, last, start_col, end_col)
  if not environment:match("^[%w*@_-]+$") then fail("Invalid environment name"); return end
  start_col = start_col or 0
  end_col = end_col or #vim.fn.getline(last)
  local selected = vim.api.nvim_buf_get_text(0, first - 1, start_col, last - 1, end_col, {})
  local result = { "", "\\begin{" .. environment .. "}" }
  for _, line in ipairs(selected) do result[#result + 1] = "  " .. line end
  result[#result + 1] = "\\end{" .. environment .. "}"
  vim.api.nvim_buf_set_text(0, first - 1, start_col, last - 1, end_col, result)
end
function M.activate(buf)
  local bo = vim.bo[buf]
  bo.expandtab, bo.shiftwidth, bo.softtabstop, bo.textwidth = true, 2, 2, 80
  bo.formatoptions = bo.formatoptions:gsub("a", "")
  bo.indentexpr = "VimtexIndentExpr()"
  vim.b[buf].tex_mode = true
  vim.wo.wrap, vim.wo.linebreak, vim.wo.spell = true, true, true
  require("luasnip").filetype_extend("plaintex", { "tex" })
  local cmp = require("cmp")
  local completion = require("languages.tex_completion")
  completion.setup()
  cmp.setup.buffer({
    sources = cmp.config.sources({
      { name = "tex_commands", priority = 1000 },
      { name = "nvim_lsp", entry_filter = completion.lsp_filter },
      { name = "luasnip" }, { name = "path" },
    }),
    performance = { debounce = 15, throttle = 15, fetching_timeout = 50, max_view_entries = 60 },
    completion = { autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged } },
    mapping = {
      ["<Tab>"] = cmp.mapping(M.tab, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(M.backtab, { "i", "s" }),
      ["<C-Space>"] = cmp.mapping.complete(),
    },
  })
  local opts = { buffer = buf, silent = true }
  for key, command in pairs({ ["<F9>"] = "TexBuild", ["<leader>tb"] = "TexBuild", ["<leader>te"] = "TexEngine", ["<leader>tl"] = "TexLog", ["<leader>ts"] = "TexSync" }) do
    vim.keymap.set("n", key, "<cmd>" .. command .. "<cr>", opts)
  end
  -- LuaSnip's selection storage is local to TeX buffers.
  vim.keymap.set("x", "<Tab>", require("luasnip.util.select").cut_keys, opts)
  vim.keymap.set("x", "<leader>tw", function()
    local buffer = vim.api.nvim_get_current_buf()
    local first, last = vim.fn.line("v"), vim.fn.line(".")
    local start_col, end_col = vim.fn.col("v") - 1, vim.fn.col(".") - 1
    local mode = vim.fn.mode()
    if first > last or (first == last and start_col > end_col) then
      first, last, start_col, end_col = last, first, end_col, start_col
    end
    if mode == "V" then start_col, end_col = 0, #vim.fn.getline(last)
    else
      local char = vim.fn.getline(last):sub(end_col + 1):match("^[%z\1-\127\194-\244][\128-\191]*") or ""
      end_col = end_col + #char
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
    vim.ui.input({ prompt = "Environment: " }, function(name)
      if name and name ~= "" and vim.api.nvim_buf_is_valid(buffer) then
        vim.api.nvim_buf_call(buffer, function() M.wrap(name, first, last, start_col, end_col) end)
      end
    end)
  end, opts)
end
function M.setup()
  local group = vim.api.nvim_create_augroup("TexMode", { clear = true })
  vim.api.nvim_create_autocmd("FileType", { group = group, pattern = { "tex", "plaintex" }, callback = function(e) M.activate(e.buf) end })
  -- Window options must be restored when switching to other language buffers.
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, { group = group, callback = function(e)
    local prose = vim.b[e.buf].tex_mode or vim.bo[e.buf].filetype == "markdown"
    vim.wo.wrap, vim.wo.linebreak, vim.wo.spell = prose or false, prose or false, prose or false
  end })
  vim.api.nvim_create_autocmd("BufWritePost", { group = group, pattern = "*.tex", callback = function(e)
    if vim.b[e.buf].tex_mode then vim.api.nvim_buf_call(e.buf, function() M.build(false) end) end
  end })
  vim.api.nvim_create_user_command("TexMode", function() vim.bo.filetype = "tex"; M.activate(0) end, {})
  vim.api.nvim_create_user_command("TexBuild", function() M.build(true) end, {})
  vim.api.nvim_create_user_command("TexEngine", function(opts)
    local project = M.context(); if not project then return end
    local function set(engine) if engine then project.engine = engine end end
    if opts.args ~= "" then
      if not engines[opts.args] then fail("Choose lualatex, xelatex, or pdflatex"); return end
      set(opts.args)
    else vim.ui.select({ "lualatex", "xelatex", "pdflatex" }, { prompt = "TeX engine" }, set) end
  end, { nargs = "?", complete = function() return { "lualatex", "xelatex", "pdflatex" } end })
  vim.api.nvim_create_user_command("TexLog", function()
    local project = M.context(); if not project then return end
    vim.cmd("botright new")
    vim.bo.buftype, vim.bo.bufhidden, vim.bo.swapfile = "nofile", "wipe", false
    vim.api.nvim_buf_set_lines(0, 0, -1, false, project.log)
    vim.bo.modifiable = false
  end, {})
  vim.api.nvim_create_user_command("TexSync", function()
    local project = M.context(); if not project then return end
    local out = project.out_dir or vim.b.tex_output_directory or vim.env.VIMTEX_OUTPUT_DIRECTORY or project.cwd
    if not vim.startswith(out, "/") then out = project.cwd .. "/" .. out end
    local pdf = project.pdf or out .. "/" .. vim.fn.fnamemodify(project.main, ":t:r") .. ".pdf"
    if vim.fn.filereadable(pdf) ~= 1 then fail("PDF missing: " .. pdf); return end
    vim.system({ "zathura", "--synctex-forward", vim.fn.line(".") .. ":1:" .. vim.api.nvim_buf_get_name(0), pdf }, { detach = true })
  end, {})
end
return M
