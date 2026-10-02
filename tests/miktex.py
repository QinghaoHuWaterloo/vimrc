#!/usr/bin/env python3
"""Real builds only with private MiKTeX. No TeX Live fallback or GUI launches."""
import os
from pathlib import Path
import subprocess
import tempfile

bin_dir = Path(os.environ.get('MIKTEX_BIN', '~/.local/lib/miktex/bin')).expanduser()
styles = Path('~/references/template/sty').expanduser()
for tool in ('lualatex', 'xelatex', 'pdflatex', 'bibtex', 'kpsewhich'):
    if not (bin_dir / tool).exists():
        raise SystemExit(f'BLOCKED: missing {bin_dir / tool}; run scripts/install-miktex.sh')
    version = subprocess.run([str(bin_dir / tool), '--version'], capture_output=True, text=True, check=True)
    assert 'miktex' in (version.stdout + version.stderr).lower(), f'{tool} is not MiKTeX'
env = os.environ.copy()
env['PATH'] = str(bin_dir) + ':' + env.get('PATH', '')
env['TEXINPUTS'] = str(styles) + '//:' + env.get('TEXINPUTS', '')
for package in ('qhbase', 'qhnotes', 'qhhomework'):
    found = subprocess.check_output([str(bin_dir / 'kpsewhich'), package + '.sty'], env=env, text=True)
    assert str(styles) in found, f'Custom style not found: {package}'

with tempfile.TemporaryDirectory(prefix="miktex space ' $ ` ") as temporary:
    root = Path(temporary)
    documents = {
        'minimal': r'Hello, MiKTeX.',
        'multi-file': r'\input{child}',
        'ams': r'\begin{align}x&=\mathbb{R}\\y&=2\end{align}',
        'bibliography': r'\cite{test}\bibliographystyle{plain}\bibliography{refs}',
        **{package: r'\section{Test}Custom style.' for package in ('qhbase', 'qhnotes', 'qhhomework')},
    }
    for name, body in documents.items():
        directory = root / name
        directory.mkdir()
        (directory / 'child.tex').write_text('Child document.\n')
        (directory / 'refs.bib').write_text('@book{test,author={A. Author},title={Test},year={2026},publisher={Test}}\n')
        packages = r'\usepackage{amsmath,amssymb}' if name == 'ams' else ''
        if name.startswith('qh'):
            packages = '\\usepackage{' + name + '}'
        main = directory / 'main.tex'
        main.write_text('\\documentclass{article}\n' + packages + '\n\\begin{document}\n' + body + '\n\\end{document}\n')
        for engine in (['lualatex', 'xelatex', 'pdflatex'] if name == 'minimal' else ['lualatex']):
            result = subprocess.run(['/usr/bin/latexmk', '-' + ('pdf' if engine == 'pdflatex' else engine),
                '-g', '-synctex=1', '-interaction=nonstopmode', '-file-line-error', '-outdir=output space', main.name],
                cwd=directory, env=env, text=True, capture_output=True, timeout=600)
            (directory / 'build.txt').write_text(result.stdout + result.stderr)
            if result.returncode:
                print(result.stdout + result.stderr)
                raise SystemExit(f'FAIL: {name}/{engine}')
            assert (directory / 'output space/main.pdf').stat().st_size > 0
            assert (directory / 'output space/main.synctex.gz').stat().st_size > 0
            if name == 'bibliography':
                assert (directory / 'output space/main.bbl').stat().st_size > 0
            print(f'PASS: MiKTeX {name}/{engine}: PDF and SyncTeX')
