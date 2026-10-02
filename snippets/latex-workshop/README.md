# LaTeX Workshop snippets

Imported without body edits from the installed `james-yu.latex-workshop-10.18.0/data/latex-snippet.json`.
Upstream: https://github.com/James-Yu/LaTeX-Workshop/tree/v10.18.0 . Original MIT license: [LICENSE](LICENSE).

`source.json` is the triggered-snippet runtime source.
`commands.json` is also imported byte-for-byte from Workshop 10.18.0 data and
provides local command completion templates (such as `\section{${1}}`) through
`lua/languages/tex_completion.lua`, independently of the trigger aliases. `lua/snippets/tex.lua` parses it with LuaSnip, gives it priority 2000, and deduplicates original/uppercase/lowercase triggers. There are 51 triggered definitions, 99 unique aliases, and one triggerless wrapper.

Visual Tab stores selected text for the next snippet. Visual `<leader>tw` prompts for an environment and implements `wrapEnv`; character and line selections are supported. Block selections are treated as a contiguous region.

| Definition | Original | Aliases |
| --- | --- | --- |
| item | `item` | `ITEM`, `item` |
| subscript | `__` | `__` |
| superscript | `**` | `**` |
| etc | `...` | `...` |
| equation | `BEQ` | `BEQ`, `beq` |
| equation* | `BSEQ` | `BSEQ`, `bseq` |
| align | `BAL` | `BAL`, `bal` |
| align* | `BSAL` | `BSAL`, `bsal` |
| gather | `BGA` | `BGA`, `bga` |
| gather* | `BSGA` | `BSGA`, `bsga` |
| multline | `BMU` | `BMU`, `bmu` |
| multline* | `BSMU` | `BSMU`, `bsmu` |
| itemize | `BIT` | `BIT`, `bit` |
| enumerate | `BEN` | `BEN`, `ben` |
| split | `BSPL` | `BSPL`, `bspl` |
| cases | `BCAS` | `BCAS`, `bcas` |
| frame | `BFR` | `BFR`, `bfr` |
| figure | `BFI` | `BFI`, `bfi` |
| table (caption after tabular) | `BTA` | `BTA`, `bta` |
| table (caption before tabular) | `BTB` | `BTB`, `btb` |
| tikzcd | `BTC` | `BTC`, `btc` |
| tikzpicture | `BTP` | `BTP`, `btp` |
| set font size | `fontsize` | `FONTSIZE`, `fontsize` |
| textnormal | `FNO` | `FNO`, `fno` |
| textrm | `FRM` | `FRM`, `frm` |
| emph | `FEM` | `FEM`, `fem` |
| textsf | `FSF` | `FSF`, `fsf` |
| texttt | `FTT` | `FTT`, `ftt` |
| textit | `FIT` | `FIT`, `fit` |
| textsl | `FSL` | `FSL`, `fsl` |
| textsc | `FSC` | `FSC`, `fsc` |
| underline | `FUL` | `FUL`, `ful` |
| uppercase | `FUC` | `FUC`, `fuc` |
| lowercase | `FLC` | `FLC`, `flc` |
| textbf | `FBF` | `FBF`, `fbf` |
| textsuperscript | `FSS` | `FSS`, `fss` |
| textsubscript | `FBS` | `FBS`, `fbs` |
| mathrm | `MRM` | `MRM`, `mrm` |
| mathsf | `MSF` | `MSF`, `msf` |
| mathbf | `MBF` | `MBF`, `mbf` |
| mathbb | `MBB` | `MBB`, `mbb` |
| mathcal | `MCA` | `MCA`, `mca` |
| mathit | `MIT` | `MIT`, `mit` |
| mathtt | `MTT` | `MTT`, `mtt` |
| part | `SPA` | `SPA`, `spa` |
| chapter | `SCH` | `SCH`, `sch` |
| section | `SSE` | `SSE`, `sse` |
| subsection | `SSS` | `SSS`, `sss` |
| subsubsection | `SS2` | `SS2`, `ss2` |
| paragraph | `SPG` | `SPG`, `spg` |
| subparagraph | `SSP` | `SSP`, `ssp` |
