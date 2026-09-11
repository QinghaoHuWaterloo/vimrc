require'nvim-treesitter.configs'.setup {
  -- 添加不同语言
  ensure_installed = { "vim", "help", "bash", "c", "cpp", "javascript", "json", "lua", "python", "typescript", "tsx", "java", "css", "rust", "markdown", "markdown_inline", "racket" }, -- one of "all" or a list of languages

  highlight = { enable = true },
  indent = { enable = true },

  -- 不同括号颜色区分
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  }
}


-- Custom local cpp parser override removed: the local path ~/projects/tree-sitter-cpp
-- doesn't exist and was overriding the built-in treesitter cpp parser, breaking highlighting.
-- Uncomment and adjust if you have a local tree-sitter-cpp checkout to test:
-- local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
-- parser_config.cpp = {
--   install_info = { url = "~/projects/tree-sitter-cpp", files = {"src/parser.c", "src/scanner.cc"} },
-- }
