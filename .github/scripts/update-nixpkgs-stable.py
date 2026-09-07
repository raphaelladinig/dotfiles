import os
import re
import subprocess
from pathlib import Path


def version(value):
    return tuple(map(int, value.split(".")))


def update(release):
    pattern = re.compile(r'(nixpkgs-stable\.url = "github:NixOS/nixpkgs/nixos-)(\d{2}\.\d{2})(";)')
    changed = False
    for root in (Path("."), Path("modules/templates/_nix-base")):
        source = root / "modules/nixpkgs.nix"
        content = source.read_text()
        matches = list(pattern.finditer(content))
        if len(matches) != 1:
            raise ValueError(f"Expected one stable nixpkgs input in {source}")
        if version(release) <= version(matches[0][2]):
            continue
        source.write_text(pattern.sub(lambda m: f"{m[1]}{release}{m[3]}", content))
        subprocess.run(["just", "write-flake"], cwd=root, check=True)
        subprocess.run(["nix", "flake", "update", "nixpkgs-stable"], cwd=root, check=True)
        changed = True
    return changed


if __name__ == "__main__":
    refs = subprocess.check_output(
        ["git", "ls-remote", "--tags", "--refs", "https://github.com/NixOS/nixpkgs.git",
         "refs/tags/[0-9][0-9].[0-9][0-9]"],
        text=True,
    )
    releases = re.findall(r"refs/tags/(\d{2}\.\d{2})$", refs, re.MULTILINE)
    release = max(releases, key=version)
    changed = update(release)
    with open(os.environ["GITHUB_OUTPUT"], "a") as output:
        output.write(f"release={release}\nchanged={str(changed).lower()}\n")
