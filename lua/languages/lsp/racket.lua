local function racket_root_dir(bufnr, on_dir)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname == "" then
    on_dir(vim.uv.cwd())
    return
  end

  local root = vim.fs.root(fname, { "raco.pkg", "info.rkt", ".git" }) or vim.fs.dirname(fname)
  on_dir(root)
end

return {
  cmd = { "racket", "-l", "racket-langserver" },
  filetypes = { "racket" },
  root_dir = racket_root_dir,
}
