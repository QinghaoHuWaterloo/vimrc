local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s({ trig = "bsl", name = "CS135 Beginning Student Language" }, {
    t("#lang htdp/bsl"),
    t({ "", "" }),
    i(0),
  }),
  s({ trig = "def", name = "Define a function" }, {
    t("(define ("),
    i(1, "function-name"),
    t(" "),
    i(2, "argument"),
    t({ ")", "  " }),
    i(0),
    t(")"),
  }),
  s({ trig = "check", name = "check-expect" }, {
    t("(check-expect ("),
    i(1, "function-name"),
    t(" "),
    i(2, "input"),
    t(") "),
    i(0, "expected"),
    t(")"),
  }),
  s({ trig = "cond", name = "cond" }, {
    t({ "(cond", "  [" }),
    i(1, "condition"),
    t(" "),
    i(0, "result"),
    t({ "]", ")" }),
  }),
  s({ trig = "struct", name = "define-struct" }, {
    t("(define-struct "),
    i(1, "name"),
    t(" ["),
    i(0, "field"),
    t("])"),
  }),
}
