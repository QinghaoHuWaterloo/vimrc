# Neovim maintenance handoff

Current scope (2026-10-01): standalone Neovim remains the C/C++, Racket, Java
and Markdown editor. VS Code + VSCode Neovim is configured for LaTeX only.
See README.md for bindings, installation and checks.

Neovide settings added 2026-10-02 for the installed 0.14.1: launch settings in
`~/.config/neovide/config.toml`, guarded runtime/font/clipboard/zoom/IME settings
in `lua/config/neovide.lua`. Rendering is on demand, active FPS is capped at 60
with vsync disabled, and costly decorative effects are off. Normal/Insert IME
transitions were checked in a real Wayland GUI. GUI settings stay out of terminal
Neovim and the VS Code branch. `config/terminal.lua` caps scrollback at 5000,
sets terminal window options without overwriting file-buffer options, and adds
terminal-input F10/window-navigation mappings. Existing runner commands remain.
Lualine periodic refresh increased from 100 ms to 1000 ms, retaining event updates.
GUI font now matches Foot: DejaVu Sans Mono for Powerline, 9 pt, with the
existing Noto Sans Mono CJK SC fallback retained.
Original files are backed up under
`~/.local/state/nvim/config-backups/before-neovide-20261002-083122/`.

`init.lua` checks `vim.g.vscode` before loading any standalone modules. The
embedded branch loads `config/vscode.lua`, with native VS Code navigation/actions
and common editing mappings. It does not load lazy.nvim, UI, terminal plugins,
completion, snippets or language servers. VS Code owns insertion and LaTeX
Workshop owns completion/build/PDF workflows. Its installed extension ID is
`asvetliakov.vscode-neovim` (not `vscode-neovim.vscode-neovim`).

The original standalone runner, C/C++ flags, Racket module and snippets, Java
roots/workspaces/dispatch and Markdown behavior remain. The briefly prepared
VS Code C/C++/Java/Racket migration was withdrawn after scope clarification;
Java/Magic Racket extensions installed during that work were uninstalled. No
VS Code tasks were added. Existing clangd and other VS Code settings remain.

TeX mode is disabled: VimTeX spec returns an empty table, its added lock entry
was removed, Texlab was removed from standalone LSP registration/tool reporting,
and `languages.tex.setup()` is not called. The local TeX snippet loader is
archived outside the loader directory. TeX modules/data/tests remain as reference;
previous documentation is under docs/archive. No TeX distributions were removed.

Only VS Code Neovim paths/affinity and LaTeX-specific suggestion/keybinding
settings were added to VS Code user JSON. Original effective settings were
preserved; timestamped backups are alongside those JSON files. Repository copies
of the additions are under vscode/. F9/F11/SyncTeX bindings apply only to LaTeX.

`python3 tests/run.py` validates standalone startup and all existing language
workflows, including real C/C++ compile/run. It also starts a separate isolated
Neovim with g:vscode=1 and a mocked VS Code action API, checking no standalone
modules leak and native action mappings dispatch correctly. A real VS Code
window still needs reload and manual testing of extension/insert/snippet/PDF
integration; headless mocks do not verify desktop integration.

The earlier uncommitted module migration remains intact. Preserve it and avoid
resetting the working tree. Standalone plugin revisions other than the newly
added and now disabled VimTeX remain unchanged.
