### LaTeX (`tex-mode`)

LaTeX buffers activate automatically; `:TexMode` activates an existing buffer.
VimTeX provides indentation and project discovery, Texlab provides commands,
environments, citations and references, and LuaSnip provides snippets. TeX uses
two-space soft tabs, prose wrapping and spellchecking. Completion automatically
suggests local Workshop commands, LSP items, snippets and paths, with no buffer-word source.
Common command completion preserves argument fields: type `\sec`, choose
`\section{}`, and Enter places the cursor inside `{}`. Tab leaves the field.
The local command table works before Texlab finishes indexing. TeX-only cmp
debounce/throttle are 15 ms and the initial source-wait budget is 50 ms; other
languages retain their original completion timing. No format-on-paste
hook is installed. These settings and mappings are local to TeX buffers.

| Command / key | Action |
| --- | --- |
| `:TexBuild`, `F9`, `<leader>tb` | Save and submit an asynchronous project build |
| `:TexEngine [lualatex\|xelatex\|pdflatex]`, `<leader>te` | Choose a project engine for this session |
| `:TexLog`, `<leader>tl` | Show output from the latest completed build |
| `:TexSync`, `<leader>ts` | Explicit forward search with Zathura |
| Insert/select Tab | Exact snippet expansion, then snippet jump, then completion selection |
| Shift-Tab / Ctrl-Space | Previous snippet field or completion item / request completion |
| Visual Tab | Cut and store selection for the next snippet |
| Visual `<leader>tw` | Wrap selection in a prompted environment |

The imported [snippet inventory](snippets/latex-workshop/README.md) has 51 original
triggers and 99 distinct aliases. Alphabetic triggers accept uppercase and lowercase,
including `BSEQ/bseq`, `BSAL/bsal`, `BSGA/bsga`, `FBF/fbf`, and `MBB/mbb`; `__`, `**`,
and `...` stay unchanged. Original bodies, placeholders, selection variables,
MIT license, and source attribution are stored in this repository. Workshop
snippets have priority over conflicting friendly-snippets definitions. VS Code
is not required at runtime.

Install MiKTeX in a local terminal (sudo requires your password):

```sh
./scripts/install-miktex.sh
python3 tests/miktex.py
NVIM_TEST_REAL_TEX=1 python3 tests/run.py
```

The script follows the [official Fedora 44 instructions](https://miktex.org/download),
installs the distribution package and finishes a private user TeX tree. The
management tools (`miktex`, `initexmf`, `miktexsetup`) stay in `/usr/bin`;
TeX engine and package-lookup links are created in `~/.local/lib/miktex/bin`,
which is used only in TeX child processes. Earlier matching MiKTeX links in
`~/bin` are archived under `~/.local/lib/miktex/previous-bin-links`. It enables
missing-package installation. Keep TeX Live installed: the external Markdown
converter and other workflows may still depend on it. Change `miktex_bin`,
`tex_latexmk`, and `tex_styles` in `lua/config/paths.lua` if needed. Only compiler
and Texlab child processes receive the MiKTeX PATH and custom-style TEXINPUTS;
global PATH, shell settings and Neovim working directory stay unchanged.
The custom style tree `~/references/template/sty` remains searchable.

Builds run once per main file, coalescing saves during a running build into one
subsequent build. `% !TeX root = main.tex` resolves included files; VimTeX project
discovery handles buffers without that directive. Default builds use LuaLaTeX
with SyncTeX, nonstop interaction and file-line errors. `% !TeX program = xelatex`
or `pdflatex` chooses an engine; `:TexEngine` takes priority. A local `.latexmkrc`
or `latexmkrc` retains its engine choice when no explicit engine is selected.
Project rc files are evaluated by latexmk. Their custom engine commands must
use MiKTeX or resolve through the child PATH. Set `b:tex_output_directory` or
`VIMTEX_OUTPUT_DIRECTORY` for an explicit output directory; otherwise rc-file
output settings apply. Texlab automatic builds and forward search are disabled.

Open the PDF yourself, for example `zathura /path/to/main.pdf`. Entry and save
never launch or focus the viewer; `:TexSync` is the explicit viewer action.
For optional inverse search, start Neovim with `nvim --listen /tmp/nvim-tex.sock`
and manually launch Zathura with:

```sh
zathura --synctex-editor-command="nvim --server /tmp/nvim-tex.sock --remote-silent +%{line} %{input}" /path/to/main.pdf
```

Use Zathura’s inverse-search gesture to return to the source. Desktop focus and
bidirectional synchronization need an interactive session to verify.

The [recorded VS Code TeX settings](snippets/latex-workshop/vscode-settings.json)
map as follows:

| VS Code setting | Neovim behavior |
| --- | --- |
| `autoBuild.run = onSave` | TeX-local BufWritePost, serialized latexmk builds |
| latexmk LuaLaTeX tool with SyncTeX/error flags | Default build argv; alternative engines via `:TexEngine` |
| `tabCompletion = onlySnippets` | Exact TeX snippet expansion before popup selection |
| LaTeX word suggestions off | TeX completion omits cmp-buffer |
| LaTeX format-on-paste off | No TeX formatting paste hook; Texlab formatting disabled |
| Package directories | Child TEXINPUTS includes the custom style tree |
| Package extras | Texlab indexes packages actually used by the document |
| Global trigger suggestions off | TeX intentionally enables automatic suggestions as requested |
| Recently used by prefix | nvim-cmp uses its standard sorting; no exact VS Code ranking emulation |

Troubleshooting: `:TexLog` shows compiler failures; `:LspToolCheck` and `:checkhealth
vim.lsp` diagnose Texlab. A private-MiKTeX error requires installation or a corrected
`miktex_bin`; the build will not silently switch to TeX Live. Check
`~/.local/lib/miktex/bin/kpsewhich qhbase.sty` with the child TEXINPUTS when styles are missing.
Package downloads need network access. If the selected CTAN mirror times out,
rerun the installer with `MIKTEX_REPOSITORY=https://mirror.csclub.uwaterloo.ca/CTAN/systems/win32/miktex/tm/packages/`. For a missing forward-search PDF, build
first and check the output-directory setting and SyncTeX file. A successful build
records the PDF path reported by latexmk, including rc output overrides.
