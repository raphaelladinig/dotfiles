{ den, ... }:
{
  den.aspects.apps.neovim.includes = [
    den.aspects.apps.neovim.core
    den.aspects.apps.neovim.completion
    den.aspects.apps.neovim.dap
    den.aspects.apps.neovim.editing
    den.aspects.apps.neovim.formatting
    den.aspects.apps.neovim.git
    den.aspects.apps.neovim.langs.bash
    den.aspects.apps.neovim.langs.cpp
    den.aspects.apps.neovim.langs.fish
    den.aspects.apps.neovim.langs.just
    den.aspects.apps.neovim.langs.lua
    den.aspects.apps.neovim.langs.markdown
    den.aspects.apps.neovim.langs.nix
    den.aspects.apps.neovim.langs.python
    den.aspects.apps.neovim.langs.typst
    den.aspects.apps.neovim.langs.web
    den.aspects.apps.neovim.langs.xml
    den.aspects.apps.neovim.langs.yaml
    den.aspects.apps.neovim.linting
    den.aspects.apps.neovim.lsp
    den.aspects.apps.neovim.navigation
    den.aspects.apps.neovim.spell
    den.aspects.apps.neovim.treesitter
    den.aspects.apps.neovim.ui
  ];

  den.aspects.apps.neovim.core.homeManager =
    {
      config,
      lib,
      ...
    }:
    {
      options.dotfiles.neovim = {
        configFiles = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = ''
            Config files managed through the Nix store in ~/.config/nvim. Keys are
            target paths relative to ~/.config/nvim, values are source paths
            relative to the neovim aspect directory. Each module contributes
            only its own files; init.lua loads whatever ends up linked.
          '';
        };

        treesitterParsers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Tree-sitter grammar names bundled into nvim-treesitter.";
        };
      };

      config = {
        dotfiles.neovim.configFiles."lua/my/settings.lua" = "settings.lua";

        home.file =
          lib.mapAttrs' (target: source: {
            name = "${config.xdg.configHome}/nvim/${target}";
            value.source = ./. + "/${source}";
          }) config.dotfiles.neovim.configFiles
          // {
            "${config.xdg.configHome}/nvim/lua/my/features.lua".text = ''
              return {
                lsp = ${lib.boolToString config.dotfiles.neovim.lsp.enable},
                formatting = ${lib.boolToString config.dotfiles.neovim.formatting.enable},
                linting = ${lib.boolToString config.dotfiles.neovim.linting.enable},
                dap = ${lib.boolToString config.dotfiles.neovim.dap.enable},
                editing = ${lib.boolToString config.dotfiles.neovim.editing.enable},
                treesitter = ${lib.boolToString config.dotfiles.neovim.treesitter.enable},
              }
            '';
          };

        programs.neovim = {
          enable = true;
          defaultEditor = true;
          initLua = builtins.readFile ./init.lua;
        };
      };
    };
}
