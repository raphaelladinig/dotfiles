#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
repo=$(pwd)
tools=$(nix build --no-link --print-out-paths --impure --expr '
  let
    flake = builtins.getFlake (toString ./.);
    pkgs = import flake.inputs.nixpkgs-unstable { system = builtins.currentSystem; };
  in pkgs.symlinkJoin {
    name = "luacheck-context-test-tools";
    paths = [ pkgs.neovim-unwrapped pkgs.luajitPackages.luacheck ];
  }')
lint=$(nix build --no-link --print-out-paths --impure --expr '
  let flake = builtins.getFlake (toString ./.);
  in (import flake.inputs.nixpkgs-unstable { system = builtins.currentSystem; }).vimPlugins.nvim-lint')
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture"/{home,config,data,state,cache,runtime,tmp}

env HOME="$fixture/home" XDG_CONFIG_HOME="$fixture/config" \
  XDG_DATA_HOME="$fixture/data" XDG_STATE_HOME="$fixture/state" \
  XDG_CACHE_HOME="$fixture/cache" XDG_RUNTIME_DIR="$fixture/runtime" \
  XDG_CONFIG_DIRS="$fixture/config" XDG_DATA_DIRS="$fixture/data" \
  TMPDIR="$fixture/tmp" PATH="$tools/bin:$PATH" NVIM_LINT_RTP="$lint" \
  LUACHECK_TEST_ROOT="$fixture/projects" LUACHECK_TEST_REPO="$repo" \
  "$tools/bin/nvim" --headless -u NONE -i NONE -l "$repo/tests/neovim_luacheck_context.lua"
