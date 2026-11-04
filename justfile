host := "caelum"

default:
    @just --list

alias c := check
alias b := build
alias s := switch
alias u := update
alias w := write-flake

check:
    nix fmt -- --check $(find . -name '*.nix' -type f -print)
    nix develop --command bash -euo pipefail -c 'fish -n modules/apps/fish/config/config.fish; (cd modules/apps/neovim && luacheck . ../../../tests/*.lua && stylua --check . ../../../tests/*.lua); node --check modules/macos/config/apply-wallpaper.js'
    just check-python
    just check-neovim
    nix flake check

check-python:
    nix develop --command python3 -B tests/check_python.py

check-neovim:
    nix run .#check-neovim
    nix develop --command python3 -B tests/neovim_dialects.py

build hostname=host:
    nh darwin build . -H {{ hostname }}

switch hostname=host:
    nh darwin switch . -H {{ hostname }} --show-activation-logs

update:
    nix flake update

write-flake:
    nix run .#write-flake
