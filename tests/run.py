#!/usr/bin/env python3
"""Exercise startup and behavior with copied plugins and isolated XDG directories."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

repo = Path(__file__).resolve().parents[1]
plugin_root = Path(os.environ.get("NVIM_TEST_PLUGIN_ROOT", "~/.local/share/nvim/lazy")).expanduser()
if not (plugin_root / "lazy.nvim").is_dir():
    raise SystemExit("Installed plugins required; set NVIM_TEST_PLUGIN_ROOT to their directory")
with tempfile.TemporaryDirectory(prefix="nvim-modules-") as temporary:
    root = Path(temporary)
    config = root / "config/nvim"
    config.mkdir(parents=True)
    shutil.copy2(repo / "init.lua", config / "init.lua")
    shutil.copy2(repo / "lazy-lock.json", config / "lazy-lock.json")
    shutil.copytree(repo / "lua", config / "lua")
    shutil.copytree(repo / "snippets", config / "snippets")
    shutil.copytree(plugin_root, root / "data/nvim/lazy")
    shutil.copytree(repo / "tests", root / "tests")
    env = os.environ.copy()
    env.update({f"XDG_{name.upper()}_HOME": str(root / name) for name in ("config", "data", "state", "cache")})
    env.update(NVIM_LOG_FILE=str(root / "nvim.log"), NVIM_TEST_ROOT=str(root), NVIM_APPNAME="nvim")
    before = (config / "lazy-lock.json").read_bytes()
    result = subprocess.run([
        "nvim", "--headless", "-i", "NONE",
        "--cmd", f"lua dofile('{root}/tests/prelude.lua')",
        "-c", f"lua dofile('{root}/tests/verify.lua')",
    ], cwd=root, env=env, timeout=60)
    assert (config / "lazy-lock.json").read_bytes() == before, "Lockfile changed"
    if result.returncode == 0:
        subprocess.run([
            "nvim", "--headless", "-i", "NONE", "--cmd", "let g:vscode = 1",
            "--cmd", f"lua dofile('{root}/tests/vscode-prelude.lua')",
            "-c", f"lua dofile('{root}/tests/vscode.lua')",
        ], cwd=root, env=env, timeout=30, check=True)
    raise SystemExit(result.returncode)
