# Neovim maintenance handoff

Updated 2026-10-01 after module migration. See [README.md](README.md) for setup,
keybindings, dependencies, and test instructions.

## Architecture

`init.lua` orchestrates editor defaults, grouped plugin specs, workflow registration,
and language editing behavior. `config/lazy.lua` bootstraps lazy.nvim and imports
only `plugins`. Most plugins still load at startup; Trouble retains command/key
loading. Plugin declarations and setup callbacks are now colocated.

| Layer | Owns |
| --- | --- |
| `config` | Editor options, generic mappings, view autocmds, personal paths, bootstrap |
| `plugins` | LSP, completion, editing, UI, themes, terminal specs and plugin keys |
| `features` | Compilation/execution, templates, theme cycling, PDF, tool reports |
| `languages` | Filetype-local editing behavior and per-language LSP configuration |
| `snippets` | Existing Racket snippet definitions |
| `optional` | Previously inactive configurations; excluded from automatic import |

Dependencies make Mason precede mason-lspconfig, nvim-lspconfig precede server
registration, and completion precede autopairs integration. LuaSnip owns both
snippet loaders. OneDark setup precedes Kanagawa, which applies the startup theme.
The plugin set and lockfile revisions are retained.

## Changes and preserved interfaces

- nvim-tree has one setup; `F3` is defined only by Trouble's spec.
- Java root detection now calls the native LSP `on_dir` callback. Project roots
  retain the original marker order; standalone roots remain directory-hashed.
- Java workspace/config data remains under `stdpath("cache")/jdtls`.
- Run tasks quote shell arguments or use argv, and run from source directories
  without issuing global `:cd`. Only `F10` retains global directory changes.
- Personal tool paths moved to `config/paths.lua`; the PDF converter defaults to
  `~/bin/md2pdf`. Its existing script requires Pandoc and XeLaTeX.
- Missing executable, unnamed-file, write-failure, converter-failure, and cancelled
  template cases are handled before launching a task.
- Racket package detection is cached for startup reporting and refreshed by
  `:LspToolCheck`; opening Racket files no longer repeats its warning/check.
- Racket's working-tree indentation and completion edits were migrated, including
  two-space indentation, Tab snippet navigation, and disabled completion/pairing.
- Commands remain `:LspToolCheck`, `:Md2Pdf`, and `:FTermToggle`. Legacy global
  `R`, `M`, `Modd`, `Mode`, `Check`, and `insert_template` delegate to feature modules.
- Markdown `F9` remains a buffer-local override. Leader and all existing mapped
  actions are retained. No new plugin functionality was enabled.

The installed FTerm version has no `cwd` option. Floating tasks use a quoted
`cd <directory> && <command>` inside their subprocess shell. Do not pass an
unsupported cwd setting or concatenate unescaped filenames. Racket leader tasks
still use the persistent FTerm session; function-key tasks use scratch terminals.

## Remaining constraints

Workflows remain single-file oriented. Java package-aware execution and project
build integration are not added. External Foot execution requires a suitable
Linux desktop; PDF export and LaTeX forward search depend on external tools.
PDF export remains synchronous. Backup/swap defaults are unchanged.

Gitsigns and terminal.nvim remain declared without newly added setup. The old
Treesitter setup remains archived, so its parser/highlight/rainbow configuration
is not applied. Do not import `optional` wholesale: it contains old theme and
plugin settings that require compatibility checks before activation.

## Validation and continuation

Run `python3 tests/run.py`. The runner copies the configuration and installed
plugins into temporary XDG directories; no source lockfile or installed plugin
checkout is modified. The startup prelude disables Mason registry refresh;
servers are verified as enabled, then disabled before language-buffer checks.
Tests require GCC and Bash and have a 60-second process timeout.

Coverage includes:

- Lua syntax, startup errors, expected plugin set/loading, startup theme, commands,
  generic mappings, diagnostics, and completion capabilities for seven servers.
- Java project and standalone callbacks, Racket indentation and all five snippet
  expansions, Tab/Shift-Tab navigation, and Markdown PDF key precedence.
- Real C compilation and FTerm execution from directories/files with special
  characters, checking that the editor's global directory stays unchanged.
- Missing tools, unnamed buffers, PDF argument handling/failure, template
  cancellation, and theme cycling.

Standalone-root testing explicitly simulates absent project markers because the
managed environment can contain a `.git` marker in `/tmp`. Tests do not launch
Foot, actual language servers, TeX builds, or interactive GUI checks. For those,
validate the relevant workflow on a machine with its dependencies installed.

Before further work, inspect `git status` and the full diff: this migration is
uncommitted, and Racket/completion changes already existed before it. Preserve
those behaviors. Keep version upgrades separate, add tests for behavior changes,
and update both Markdown documents when changing module ownership or bindings.


## TeX implementation handoff (2026-10-01)

`languages/tex.lua` owns TeX activation, local completion, commands, main-file
resolution, job scheduling and explicit sync. `plugins/tex.lua` adds only VimTeX,
pinned at `16a5609d17a436db7f48046d91747fd6a9d75c74`; all previous lock revisions
are retained. This revision requires Neovim 0.12.4+. VimTeX's compiler, viewer and
default mappings are disabled so the project scheduler is the sole automatic
builder and Zathura has no startup/save hooks. Texlab auto-build and auto-search
are disabled; its child environment selects private MiKTeX and the custom styles.

`snippets/latex-workshop/source.json` is the unmodified installed 10.18.0 source,
with its original MIT license. `lua/snippets/tex.lua` parses the original bodies
and deduplicates casing aliases at priority 2000. See its inventory and the README
for VS Code mapping, migration, preview and troubleshooting. Generic snippets
remain available, but Workshop definitions win exact-trigger conflicts.

Validation performed: the baseline suite passed before edits. The extended
`python3 tests/run.py` passes all 51 original definitions / 99 unique aliases,
empty/single-line/multiline selection expansion and placeholder comparison,
exact snippet priority with a visible completion popup, forward/backward snippet
navigation, ordinary completion, visual wrapping, TeX language-switch isolation,
root resolution, compiler directives, rc engine precedence, output override argv,
special-character paths, simulated build coalescing/failure reporting, and absence
of automatic viewer launches. Existing startup, Markdown, Racket indentation and
snippets, Java roots/dispatch/workspaces, and actual C/C++ compile/run pass.

Real MiKTeX validation now passes after correcting the Fedora management-tool
paths: `/usr/bin/miktex`, `/usr/bin/initexmf` and `/usr/bin/miktexsetup` are RPM
executables, while private engine links live in `~/.local/lib/miktex/bin`.
The installer is rerunnable, skips the RPM install when already installed,
explicitly disables PATH modification, and archives earlier matching generated
links/utilities from `~/bin`. This prevents MiKTeX from shadowing TeX Live in
other workflows. The private package tree remains under `~/.miktex/texmfs`.

`python3 tests/miktex.py` passes identity checks, custom-style lookup, minimal
builds with all three engines, multi-file, AMS math, bibliography, and
qhbase/qhnotes/qhhomework builds. All produce nonempty PDF and SyncTeX files;
bibliography produces a nonempty bbl. Special-character project directories and
spaced output directories are covered. Latexmk rejects some special characters
in full input paths, so builds pass the basename and run with the project cwd.
`NVIM_TEST_REAL_TEX=1 python3 tests/run.py` also passes the real Neovim
`:TexBuild` save/autocmd/job path plus all language regressions, checking MiKTeX,
PDF/SyncTeX, unchanged editor cwd/PATH and no viewer launch.

The initially auto-selected quantum5 CTAN mirror timed out. The user-private
repository was switched to Waterloo via `/usr/bin/mpm --set-repository`;
`MIKTEX_REPOSITORY` allows selecting a mirror when rerunning the installer.
The first qhnotes build needed an explicit `miktex packages install xkeyval`;
subsequent qhnotes/qhhomework builds passed. TeX Live remains installed and shell
engine lookup selects `/usr/bin/lualatex` and `/usr/bin/xelatex` again.
Desktop manual launch, focus behavior, forward search and optional inverse search
remain manual checks because no interactive desktop was available.

Earlier architecture/constraint statements describe the migration baseline;
TeX is now project-oriented and asynchronous. No changes were made to the
existing C/C++, Racket, Java or Markdown feature modules. Window prose options
are restored on buffer entry so switching away from TeX does not leak wrapping
or spellchecking. Visual environment wrapping supports character/line selections;
block selections use their contiguous bounding region. Runtime rc files execute
through latexmk; an absolute TeX Live command in a project rc deliberately
supersedes the child PATH and must be migrated by its owner.


## TeX command completion follow-up

`languages/tex_completion.lua` registers a TeX-only local nvim-cmp source using
Workshop 10.18.0 `commands.json`, stored with the existing MIT attribution. Unlike
Texlab's bare command-name items, these command templates include argument
placeholders. Local `\section{${1}}` completion takes priority; bare duplicate LSP
commands are filtered only while completing a command name. Project-specific
commands, server snippets, citation/reference arguments and paths remain available.
The 51 original triggered snippets and their aliases are unchanged.

TeX-local performance settings reduce cmp debounce from 60 to 15 ms, throttle
from 30 to 15 ms and initial source waiting from 500 to 50 ms. Local command
lookups return synchronously; later LSP results can still update the menu.
`tests/tex-completion.lua` checks command bodies, filters, context boundaries,
synchronous response and timing isolation. `tests/tex-popup.py` drives a separate
isolated headless Neovim through its built-in remote client: actual typing opens
the menu, Enter confirms `\section{}`, the cursor is inside the argument, and
Tab exits after a title is entered. This passed in approximately 57 ms from
input to observed popup including RPC/polling overhead; no VS Code benchmark was
performed. The original language suite also passes.
