host := `hostname -s`

default:
    @just --list

alias c := check
alias b := build
alias s := switch
alias u := update
alias w := write-flake

check:
    nix fmt -- --check $(find . -name '*.nix' -type f -print)
    nix develop --command bash -euo pipefail -c 'fish -n modules/apps/fish/config/config.fish; (cd modules/apps/neovim && luacheck . && stylua --check .); node --check modules/macos/config/apply-wallpaper.js'
    nix flake check

build hostname=host:
    nh darwin build . -H {{ hostname }}

switch hostname=host:
    nh darwin switch . -H {{ hostname }} --show-activation-logs

update:
    nix flake update

write-flake:
    nix run .#write-flake
