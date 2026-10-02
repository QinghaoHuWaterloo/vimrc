local paths = require("config.paths")
return {
  cmd_env = {
    PATH = paths.miktex_bin .. ":" .. (vim.env.PATH or ""),
    TEXINPUTS = paths.tex_styles .. "//:" .. (vim.env.TEXINPUTS or ""),
  },
  settings = {
    texlab = {
      build = { onSave = false, forwardSearchAfter = false },
      chktex = { onEdit = false, onOpenAndSave = false },
      latexFormatter = "none",
      bibtexFormatter = "none",
    },
  },
}
