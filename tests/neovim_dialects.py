"""Run with python3 tests/neovim_dialects.py; builds but never activates caelum."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


REPO = Path(__file__).resolve().parents[1]
CONFIG = "darwinConfigurations.caelum.config.home-manager.users.raphaelladinig"
PACKAGES = """c: [ c.programs.neovim.finalPackage c.home-files ] ++
  builtins.filter (p: builtins.elem (p.pname or p.name)
    [ "lemminx" "xmlformat" "prettierd" "vscode-langservers-extracted" "vtsls" ])
  c.home.packages"""
CASES = [
    ("xml", "lemminx", "xmlformat", "<root><child/></root>"),
    ("xsd", "lemminx", "xmlformat", '<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"/>'),
    ("xsl", "lemminx", "xmlformat", '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"/>'),
    ("xslt", "lemminx", "xmlformat", '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"/>'),
    ("svg", "lemminx", "xmlformat", '<svg xmlns="http://www.w3.org/2000/svg"><path d="M0 0"/></svg>'),
    ("css", "cssls", "prettierd", "body{color:red}"),
    ("scss", "cssls", "prettierd", "$color:red;body{color:$color}"),
    ("less", "cssls", "prettierd", "@color:red;body{color:@color}"),
]


def main():
    builds = json.loads(subprocess.check_output(
        ["nix", "build", "--no-link", "--json", "--impure", "--expr",
         f"let c = (builtins.getFlake (toString ./.)).{CONFIG}; in ({PACKAGES}) c"], cwd=REPO
    ))
    outputs = {Path(p) for build in builds for p in build["outputs"].values()}
    nvim = next(p / "bin/nvim" for p in outputs if (p / "bin/nvim").exists())
    managed = next(p for p in outputs if (p / ".config/nvim").exists())
    tool_path = os.pathsep.join(str(p / "bin") for p in sorted(outputs) if (p / "bin").exists())
    for executable in ("lemminx", "xmlformat", "prettierd", "vscode-css-language-server"):
        assert shutil.which(executable, path=tool_path), executable
    failures = []
    for ft, server, formatter, content in CASES:
        modes = ("enabled", "no-lsp", "no-formatting") if ft in ("svg", "less") else ("enabled",)
        for mode in modes:
            with tempfile.TemporaryDirectory(prefix="nvim-dialects-", dir="/tmp") as directory:
                root = Path(directory)
                for name in ("home", "config", "data", "state", "cache", "runtime", "project"):
                    (root / name).mkdir(mode=0o700)
                shutil.copytree(managed / ".config/nvim", root / "config/nvim", symlinks=True)
                shutil.copytree(managed / ".local/share/nvim", root / "data/nvim", symlinks=True)
                if mode != "enabled":
                    features = root / "config/nvim/lua/my/features.lua"
                    text = features.read_text().replace(
                        f"{'lsp' if mode == 'no-lsp' else 'formatting'} = true",
                        f"{'lsp' if mode == 'no-lsp' else 'formatting'} = false",
                    )
                    features.parent.chmod(0o700)
                    features.unlink()
                    features.write_text(text)
                project = root / "project"
                (project / ".git").mkdir()
                fixture = project / f"first.{ft}"
                fixture.write_text(content + "\n")
                env = {
                    "PATH": tool_path + os.pathsep + "/usr/bin:/bin",
                    "HOME": str(root / "home"),
                    **{f"XDG_{key}_HOME": str(root / value) for key, value in (
                        ("CONFIG", "config"), ("DATA", "data"), ("STATE", "state"), ("CACHE", "cache")
                    )},
                    "XDG_RUNTIME_DIR": str(root / "runtime"),
                    "DIALECT_FT": ft, "DIALECT_SERVER": server,
                    "DIALECT_FORMATTER": formatter, "DIALECT_MODE": mode,
                }
                command = [str(nvim), "--headless", "-i", "NONE"]
                # Neovim detects .xsl as xslt; exercise the server's xsl alias separately.
                if ft == "xsl":
                    command += ["--cmd", "lua vim.filetype.add({extension = {xsl = 'xsl'}})"]
                result = subprocess.run(
                    command + [str(fixture),
                     "+luafile " + str(REPO / "tests/neovim_dialects.lua")],
                    cwd=project, env=env, text=True, stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT, timeout=45,
                )
                print(f"{ft} ({mode}): {result.stdout.strip()}", flush=True)
                if result.returncode:
                    failures.append(f"{ft} ({mode})")
    assert not failures, "Failed: " + ", ".join(failures)


if __name__ == "__main__":
    main()
