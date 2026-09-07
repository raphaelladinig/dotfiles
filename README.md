# Dotfiles

My personal dotfiles, including Nix configuration for macOS using nix-darwin,
Home Manager, and Den.

The checkout is expected at `~/Projects/dotfiles`.

## Nix base template

Create a general Nix flake starter in an empty directory from this checkout:

```sh
nix flake init -t ~/Projects/dotfiles#nix-base
```

The template lives in `modules/templates/_nix-base`.
The template includes Den, flake-parts, import-tree, and a development shell.

Its package configuration provides `pkgs.stable` and `pkgs.unstable` with unfree
packages allowed. Flake-level Nix settings require `--accept-flake-config`;
Nix must already have flakes enabled to load the template.
