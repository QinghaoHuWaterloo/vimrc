if vim.g.vscode then
  require("config.vscode").setup()
  return
end

require("config.options")
require("config.autocmds")
require("config.lazy")
require("config.keymaps")
require("config.terminal")
require("config.neovide")
require("features.runner").setup()
require("features.templates").setup()
require("features.themes").setup()
require("features.markdown").setup()
require("features.toolcheck")
require("languages.racket")
require("languages.markdown")
