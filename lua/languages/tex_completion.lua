-- Immediate command completions from LaTeX Workshop 10.18.0 (MIT).
-- Texlab remains responsible for project-specific commands, references and citations.
local M = {}
local items, known, registered
local function load()
  if items then return end
  items, known = {}, {}
  local definitions = vim.json.decode(table.concat(vim.fn.readfile(
    vim.fn.stdpath("config") .. "/snippets/latex-workshop/commands.json"), "\n"))
  for label, definition in pairs(definitions) do
    local body = definition.snippet or label
    local command = body:match("^([%a@]+%*?)")
    if command then
      known[command] = true
      items[#items + 1] = {
        label = "\\" .. label,
        filterText = "\\" .. command,
        insertText = "\\" .. body,
        insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
        kind = vim.lsp.protocol.CompletionItemKind.Snippet,
        detail = definition.detail or "LaTeX Workshop command",
        documentation = definition.documentation,
        -- Prefer the basic mandatory-argument variant over optional/starred forms.
        sortText = command:gsub("%*$", "") .. (label:find("[", 1, true) and "2" or command:sub(-1) == "*" and "1" or "0") .. label,
      }
    end
  end
  table.sort(items, function(a, b) return a.sortText < b.sortText end)
end
function M.command_context(line)
  local start, command = line:match("()\\([%a@]*%*?)$")
  if not start or line:sub(start - 1, start - 1) == "\\" then return end
  return command
end
function M.lsp_filter(entry, context)
  load()
  if M.command_context(context.cursor_before_line) == nil then return true end
  local item = entry:get_completion_item()
  local text = item.textEdit and item.textEdit.newText or item.insertText or item.label
  -- Suppress bare duplicate command names, retaining real server snippets/edits.
  local command = text:match("^\\?([%a@]+%*?)$")
  return not (command and known[command])
end
function M.source()
  load()
  return {
    is_available = function() return vim.b.tex_mode == true end,
    get_keyword_pattern = function() return [[\\[a-zA-Z@]*\*\?]] end,
    get_trigger_characters = function() return { "\\" } end,
    complete = function(_, params, callback)
      local prefix = M.command_context(params.context.cursor_before_line)
      if prefix == nil then callback({ items = {}, isIncomplete = false }); return end
      local matches = {}
      for _, item in ipairs(items) do
        if item.filterText:sub(2, #prefix + 1) == prefix then matches[#matches + 1] = item end
      end
      callback({ items = matches, isIncomplete = true })
    end,
  }
end
function M.setup()
  if registered then return end
  require("cmp").register_source("tex_commands", M.source())
  registered = true
end
return M
