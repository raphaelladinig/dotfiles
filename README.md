# Dotfiles

My personal dotfiles, including Nix configuration for macOS using nix-darwin,
Home Manager, and Den.

The checkout is expected at `~/Projects/dotfiles`.

Helium is the configured browser, with KeePassXC native messaging integration.
Current profile settings are declared in `modules/apps/helium/preferences.json`
and `local-state.json`. Activation merges these settings while Helium is closed,
preserving other profile data. The app module also declares updater preferences
and DuckDuckGo as the recommended search provider, which browser choices can override.
The [Helium extension list](modules/apps/helium/extensions.csv) declares extensions
for automatic installation through the macOS `ExtensionInstallForcelist` policy
and toolbar pins through `ExtensionSettings`.
Quit Helium before activation, then reopen it to install the extensions.
Connect KeePassXC-Browser to your database after installation.

GitHub Actions checks formatting and syntax, validates both flakes, and builds
the `sol` configuration on pull requests and pushes to `main`. The workflow can
also be run manually. It does not activate the configuration.

A weekly workflow runs `just update` and opens or updates a dependency PR after
checks and the `sol` build pass. It can also be run manually. Enable "Allow
GitHub Actions to create and approve pull requests" in the repository's Actions
settings. Updates require manual merging and activation.
