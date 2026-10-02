_G.vscode_calls = {}
package.preload.vscode = function()
  return { action = function(command) _G.vscode_calls[#_G.vscode_calls + 1] = command end }
end
