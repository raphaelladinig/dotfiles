# Dotfiles

My personal dotfiles, including Nix configuration for macOS using nix-darwin,
Home Manager, and Den.

The checkout is expected at `~/Projects/dotfiles`.

GitHub Actions checks formatting and syntax, validates both flakes, and builds
the `sol` configuration on pull requests and pushes to `main`. The workflow can
also be run manually. It does not activate the configuration.

A weekly workflow runs `just update` and opens or updates a dependency PR after
checks and the `sol` build pass. It can also be run manually. Enable "Allow
GitHub Actions to create and approve pull requests" in the repository's Actions
settings. Updates require manual merging and activation.
