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
- Use `repoRoot` for links into this checkout. `modules/defaults.nix` sets it to
  `~/Projects/dotfiles`. Fish and Neovim use out-of-store links, so edits to
  existing linked files can affect the running setup before a rebuild.

For macOS app preferences, use `dotfiles.appPreferences` from
`modules/app-preferences.nix` for scalar defaults. Preserve its behavior of
skipping open apps and telling the user to quit and reapply. For app-owned
configuration files, follow `modules/apps/keepassxc.nix`: merge managed keys
while preserving other settings and skip writes while the app is running.

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

The reusable Nix base lives in `modules/templates/_nix-base` and is exposed
through `modules/templates/default.nix`. Keep the template under `_nix-base/` so
import-tree excludes its modules from the parent flake. Keep it general, without
host, user, or OS-specific declarations. Define template Nix settings through
`flake-file.nixConfig` and package configuration through `perSystem`. Run its `just write-flake`
from that directory when changing its dependency declarations. Validate it with
`nix flake check path:./modules/templates/_nix-base`.
