# Neovim setup

Personal Lua configuration for C/C++, Java, CS135 Racket work, LaTeX, and Markdown.
See [HANDOFF.md](HANDOFF.md) for maintenance details and regression tests.

## Setup

Use Neovim 0.11 or newer with the native `vim.lsp.config` / `vim.lsp.enable` APIs,
subject to installed plugin requirements. This configuration was tested locally
with Neovim 0.12.5. Place it at `~/.config/nvim`, install Git, and start `nvim`.
The bootstrap downloads lazy.nvim if absent. Initial plugin and server installs
require network access. A true-color terminal and Nerd Font support the UI.

Use `:Lazy` to inspect plugins, `:Lazy restore` to restore recorded revisions,
and `:Lazy update` only when deliberately updating them. Use `:Mason`,
`:LspToolCheck`, and `:checkhealth` to inspect dependencies and providers.

| Workflow | Dependencies |
| --- | --- |
| C/C++ | `gcc`, `g++`; Mason-managed `clangd` |
| Java | `java`, `javac`, a JDK compatible with the installed JDT LS |
| Python execution | `python3`; no Python LSP configured |
| Racket | `racket`, `raco`; `raco pkg install racket-langserver` |
| LaTeX in VS Code | LaTeX Workshop, VSCode Neovim, existing TeX distribution |
| Markdown PDF | `~/bin/md2pdf`; current external script uses Pandoc and XeLaTeX |
| Competitive-programming checks | External `judge` command |
| External terminal helper | Foot and Bash; no keybinding assigned |
| Clipboard | System clipboard provider; inspect `:checkhealth` |

Mason requests `lua_ls`, `clangd`, `jdtls`, `vimls` and `marksman`.
Racket's server is installed outside Mason. Missing optional workflow tools
produce a startup report, and `:LspToolCheck` refreshes the full status.

## Module layout

```text
init.lua                 Startup orchestration
lua/config/              Options, generic keys, autocmds, lazy bootstrap, paths
lua/plugins/             Imported lazy.nvim specs grouped by feature
lua/features/            Run/build, templates, themes, PDF export, tool checks
lua/languages/           Racket/Markdown editing and language-specific LSP tables
lua/snippets/            Local LuaSnip definitions
lua/optional/            Archived inactive configs; never automatically imported
```

Each plugin module returns lazy.nvim specs with its dependencies and configuration.
Only `lua/plugins/` is automatically imported. General editor keys live in
`config/keymaps.lua`; plugin keys live in specs; workflow keys live in their
feature module; language keys are buffer-local.

Change personal paths in `lua/config/paths.lua`: the PDF converter, template
directory/prompt, external terminal, shell, and judge command. The external PDF
script and template collection are not included in this repository.

Kanagawa is the startup theme. nvim-tree, bufferline, lualine, indentation guides,
and a scrollbar provide the UI. Completion uses nvim-cmp with LSP, LuaSnip, path,
and buffer sources. Racket disables completion and autopairs but retains snippets.

Defaults: relative/absolute numbers, four-column literal tabs, no wrapping,
smart-case search, system clipboard, splits below/right. Backup and swap files
are disabled. Syntax folds begin open; views are saved/restored per buffer window.

## Keybindings

Leader is the default backslash (`\`); no custom leader is set. Keys are
normal-mode unless indicated.

| Key | Action |
| --- | --- |
| `F2` | Toggle file explorer; dotfiles hidden |
| `F3` | Toggle Trouble diagnostics |
| `F5` | Cycle wave → dragon → OneDark → Solarized flat |
| `F6` | Enable highlighting and begin a search |
| `F7` / `F8` | Open template directory / prompt to insert a template |
| `F9` | Save and compile/run/test in a 30-line split; Markdown exports PDF |
| `F10` | Change global directory to the file directory and toggle FTerm |
| `F11` | Save and run C/C++, Java, or Racket in a floating terminal |
| `F12` | Save and run `judge ./<stem>`; Racket uses `raco test` |
| `H` / `L` | Previous / next buffer |
| `x` | Delete buffer; overrides character deletion |
| `U` | Undo |
| `Ctrl-a` | Select buffer |
| `Backspace` | Clear search highlighting |
| `D`, `dd`, `dw` | Delete into black-hole register, preserving yanks |
| Terminal `Esc` | Leave terminal input mode |
| `<leader>xX` | Trouble current-buffer diagnostics |
| `<leader>cs` / `<leader>cl` | Trouble symbols / LSP results |
| `<leader>xL` / `<leader>xQ` | Trouble location / quickfix list |

In insert/select mode, Tab advances completion or expands/advances snippets;
Shift-Tab goes backward. Enter confirms completion, including the default item.
Ctrl-e aborts; Ctrl-b/Ctrl-f scroll documentation. Autopairs fast wrap uses Alt-e.

`F9` compiles C with GCC/C17 and C++ with G++/`-O2 -std=c++2b -DLOCAL`, retaining
existing warning flags. It compiles Java with `javac`, runs Python with `python3`,
tests Racket with `raco test`, or opens a shell for other filetypes. C/C++ and Java
need compilation before `F11`. These are single-file workflows, not project builds.
Tasks execute from the source directory without changing Neovim's global directory;
`F10` intentionally retains its directory-changing behavior.

### Racket

`.rkt`/`.rktl` buffers use two spaces, semicolon comments, and custom indentation
for trailing opening and matching closing delimiters, with Lisp indentation as
fallback. Buffer-local Tab/Shift-Tab navigate snippets without completion popups.

| Key / trigger | Action |
| --- | --- |
| `<leader>rr` / `<leader>rt` | Save and run / test in FTerm |
| `<leader>rf` | Reindent buffer |
| `bsl` | `#lang htdp/bsl` |
| `def` | Function definition |
| `check` | `check-expect` |
| `cond` | Conditional form |
| `struct` | `define-struct` |

### Markdown and LaTeX

Markdown enables wrapping, line breaks, spellchecking, and 80-column text width.
`F9`, `<leader>mp`, or `:Md2Pdf` saves and exports a same-stem PDF beside the source
through the configured converter. Marksman provides Markdown LSP support.

### LaTeX in VS Code + VSCode Neovim

C/C++, Racket and Java continue using standalone Neovim with their existing
settings and runners. VS Code is used for LaTeX. The installed
`asvetliakov.vscode-neovim` extension uses the `vim.g.vscode` branch at the top
of `init.lua`; this loads only `config/vscode.lua`. Lazy, UI plugins, nvim-cmp,
LuaSnip, Mason and Neovim LSPs stay out of the embedded process. VS Code and
LaTeX Workshop own insert completion, snippets, compilation and PDF viewing.

VS Code's user settings now point to `/usr/bin/nvim` and this `init.lua`.
LaTeX-only automatic suggestions are enabled with a 10 ms trigger delay;
Tab/snippet navigation and Ctrl-Space use VS Code. Normal-mode H/L switch
VS Code tabs, x closes the tab, U undoes, and black-hole delete mappings remain.
F2 toggles the sidebar, F3 opens Problems, F5 selects a VS Code theme, F10 toggles
the terminal. `gd`, `gr`, `K`, leader-rn and leader-ca use native VS Code actions.

For LaTeX editors, F9 saves/builds via LaTeX Workshop, F11 opens the PDF viewer,
and Ctrl-Alt-j performs forward SyncTeX. Other language keybindings and settings
in VS Code were preserved. The effective settings/keybinding additions are
recorded under `vscode/`; user JSON backups are beside the original files with
`.before-vscode-neovim-<timestamp>` suffixes. Reload VS Code's window after changes.
If you prefer native VS Code editing, disable the VSCode Neovim extension;
LaTeX Workshop and the LaTeX keybindings work independently.

The earlier standalone `tex-mode` is inactive: no VimTeX spec, Texlab server,
TeX command registration or custom TeX completion is loaded. Its code, imported
MIT snippets, and tests remain available as reference; the local snippet loader
file moved to `docs/archive/tex-snippets.lua`. Previous usage notes are in
`docs/archive/tex-mode.md`. TeX distributions and their package trees are retained.

## Maintenance and tests

### Neovide and terminals (2026-10-02)

Neovide 0.14.1 uses `~/.config/neovide/config.toml` for launch settings and
`lua/config/neovide.lua` for runtime settings. The GUI uses the installed
DejaVu Sans Mono for Powerline at 9 pt, matching Foot, with Noto Sans Mono CJK SC
as Chinese fallback.
It renders on demand, caps active rendering at 60 FPS with vsync disabled,
keeps short cursor/scroll animations, and disables blur, shadows, particles
and cursor blinking. The 5 FPS unfocused setting may be ignored on Wayland.
Font size can be changed in the `guifont` line; linespace stays zero for joined
terminal box-drawing characters. GUI settings do not affect terminal Neovim
or the VS Code branch. These settings target less rendering work; they do
not reduce language-server memory or guarantee a particular GPU/CPU saving.

| GUI key | Action |
| --- | --- |
| `Ctrl-Shift-c` in Visual mode | Copy selection to system clipboard |
| `Ctrl-Shift-v` | Paste, including terminal input; command line uses clipboard register |
| `Ctrl-s` in Normal/Insert mode | Save file |
| `Ctrl-+` / `Ctrl-=` / `Ctrl--` | Zoom in / out |
| `Ctrl-0` | Reset zoom |

Chinese IME is enabled in Insert, Replace, command-line and terminal input
modes, and disabled in Normal mode. Desktop IME behavior still depends on
the Wayland compositor and input-method integration.

`lua/config/terminal.lua` applies to standalone Neovim in both terminal and
GUI: terminals keep 5,000 scrollback lines, hide line numbers/fold/sign columns,
and preserve file-window options when switching back. In terminal input,
`Ctrl-w h/j/k/l` switches windows and `F10` invokes the existing terminal
toggle. `Esc` still leaves input mode; shell `Ctrl-c`, `Ctrl-d` and `Ctrl-l`
remain available. Statusline periodic refresh is 1 second; normal event-driven
updates remain enabled. Restart Neovide to load launch changes.

Settings follow the [Neovide 0.14.1 documentation](https://github.com/neovide/neovide/blob/0.14.1/website/docs/configuration.md).
Before-change copies of init.lua, UI specs and documentation are stored under
`~/.local/state/nvim/config-backups/before-neovide-20261002-083122/`.

Add a plugin spec to the appropriate `lua/plugins/` module; no new `init.lua`
require is needed. Add language-specific LSP tables under `lua/languages/lsp/`
and register them in the LSP spec. Archived configs remain inactive until explicitly
integrated. Noice, Telescope, Dashboard, and the archived Treesitter setup are
not enabled by this refactor; Treesitter itself remains installed as before.

Inline diagnostic virtual text is disabled. Inspect diagnostics with `F3` or
`:lua vim.diagnostic.open_float()`. Server troubleshooting: `:LspToolCheck`,
`:checkhealth vim.lsp`, `:messages`.

Run regression tests from this directory:

```sh
python3 tests/run.py
```

Tests require Python 3, Neovim, Bash, GCC, G++, and the installed plugins. They copy
plugins into a temporary directory, isolate Neovim's data/cache/state, disable
Mason registry refresh, and check startup, language behavior, command handling,
and real C/C++ compile/run, language isolation and the embedded VS Code branch. No plugins or servers are installed or updated.
For a non-default plugin location, set `NVIM_TEST_PLUGIN_ROOT` to that directory.
