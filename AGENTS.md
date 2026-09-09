# Project instructions

Personal macOS dotfiles using Nix flakes, nix-darwin, Home Manager, and Den aspects.
Keep project instructions here.

Use Conventional Commits for commit messages: `type(scope): description`.
The scope is optional. Examples: `feat(neovim): add Python support` and
`docs: update project instructions`.

Follow these conventions when changing configuration:

- Edit `flake-file.inputs` and other flake declarations in `modules/`, then run
  `just write-flake` to regenerate `flake.nix`. The generated file is not the
  source of truth. Keep dependency updates scoped to the task.
- `import-tree` discovers Nix modules recursively under `modules/`. Put helper
  functions in `_lib/`, which it excludes, and import those helpers explicitly.
  New files must be tracked by Git to participate in the Git-backed flake.
- Use `<name>.nix` for standalone modules. For modules with supporting files,
  keep the entry point at `<name>/default.nix` and the supporting files in that
  directory, as in `modules/ai/skills/default.nix`. When adding supporting files
  to an existing module, move its entry point and update its relative paths.
- Define features under `den.aspects` and compose them with `includes`.
  Discovery makes an aspect available; a host, user, or included aspect must
  select it. Follow `modules/hosts/` and `modules/users/` for that wiring.
- Put system settings in an aspect's `darwin` module and user configuration in
  its `homeManager` module. Request `config`, `pkgs`, and other class-specific
  arguments inside that module's function.
- Keep app packages and configuration together under `modules/apps/`.
  Declare shared dependencies through the app aspect's `includes`.
- Keep shared nixpkgs settings in `modules/nixpkgs.nix`; its `perSystem` package
  set and Darwin aspect use the same configuration and overlays.
- Declare cross-aspect `dotfiles.*` flags in `modules/defaults.nix` so consumers
  can read them when the providing aspect is absent. Follow the KeePassXC flag
  pattern. Keep feature-local options in their owning module.
- Fish, Neovim, AI skills, and agent instructions use Nix-managed files through
  `home.file` with relative source paths. Edits require a rebuild and activation.

For macOS app preferences, use `dotfiles.appPreferences` from
`modules/app-preferences.nix` for scalar defaults. Preserve its behavior of
skipping open apps and telling the user to quit and reapply. For app-owned
configuration files, follow `modules/apps/keepassxc.nix`: merge managed keys
while preserving other settings and skip writes while the app is running.

Helium's `preferences.json` and `local-state.json` contain curated settings, not
profile exports. Keep account data, history, identifiers, and extension state out
of these files. Darwin activation merges them as the primary user only while Helium
is closed. All Helium preference writers run in the same activation shell so the
shared warning helper emits one reminder per app. Search uses
macOS recommended policies to avoid editing protected search preferences.

Helium's `extensions.csv` is the source for its macOS `ExtensionInstallForcelist`
and `ExtensionSettings` toolbar pins. Blank pin values preserve existing settings.
Darwin activation merges that list into the primary user's managed preferences
while Helium is closed, preserving other policy keys. Keep the CSV updated when
adding or removing forced extensions.

Helium's `apply-dark-reader.py` sets Dark Reader to "Invert listed only" in
the Default profile's local and sync extension stores while Helium is closed.
It preserves site lists and other settings. It also sets the legacy mode key
when needed so Dark Reader's first-run migration preserves the declared mode.

Git signs commits and tags with the SSH public key in `modules/apps/git.nix`.
KeePassXC must load the matching private key into the SSH agent before committing.

For Neovim changes, read `modules/apps/neovim/default.nix` and `init.lua` before
adding a feature. Feature modules contribute files through
`dotfiles.neovim.configFiles`; `init.lua` discovers the linked Lua modules.
Language modules return `{ filetypes, setup }` and initialize on the first
matching filetype. Keep packages and plugins in Nix and runtime behavior in Lua.

Use the recipes in `justfile` for validation and activation:

- Enter `nix develop` when repository tools are missing from the shell.
- For code or configuration changes, run `just check`. It checks Nix formatting,
  Fish and JavaScript syntax, Lua linting and formatting, and the flake.
- For changes to the host configuration, also run `just build sol` to build
  without activation. Specify the intended host when working on another machine;
  omitting it uses the local hostname.
- Run `just switch sol` when the task includes applying the configuration.
  Activation changes the live system and runs Homebrew upgrades and cleanup,
  including removal of packages absent from the declared configuration.
- For documentation-only edits, review the diff and verify referenced paths and
  commands. A Nix rebuild is unnecessary.

GitHub Actions runs `.github/workflows/check.yml` on pull requests, pushes to `main`,
and manual dispatch. It runs `just check`, validates the Nix base template, and
builds `sol` on an Apple Silicon macOS runner without activation. Keep these
steps in sync with the validation recipes.
Check runs in the same concurrency group run one at a time and queue up to 100
pending runs with `queue: max`.

`.github/workflows/update.yml` runs `just update` every Monday at 07:23 UTC
and on manual dispatch. It updates the main `flake.lock`, runs the same checks
and build, and opens or updates one PR for manual merging. It leaves the
template lockfile and stable release pin unchanged. Enable "Allow GitHub
Actions to create and approve pull requests" in the repository settings.
PRs created or updated with `GITHUB_TOKEN` trigger check workflow runs that
require approval. The update workflow validates changes before opening or
updating the PR.

The reusable Nix base lives in `modules/templates/_nix-base` and is exposed
through `modules/templates/default.nix`. Keep the template under `_nix-base/` so
import-tree excludes its modules from the parent flake. Keep it general, without
host, user, or OS-specific declarations. Define template Nix settings through
`flake-file.nixConfig` and package configuration through `perSystem`. Run its `just write-flake`
from that directory when changing its dependency declarations. Validate it with
`nix flake check path:./modules/templates/_nix-base`.
