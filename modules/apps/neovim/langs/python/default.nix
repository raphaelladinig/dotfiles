{ den, ... }:
{
  den.aspects.apps.neovim.langs.python.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.langs.python.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      debuggerPython = pkgs.python3.withPackages (ps: [ ps.debugpy ]);
    in
    {
      options.dotfiles.neovim.langs.python.enable = lib.mkEnableOption "Neovim Python support" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.langs.python.enable {
        dotfiles.neovim.configFiles."lua/my/langs/python.lua" = "langs/python/python.lua";
        dotfiles.neovim.treesitterParsers = [ "python" ];

        xdg.configFile."nvim/lua/my/python.lua" = lib.mkIf config.dotfiles.neovim.dap.enable {
          text = ''
            return {
              debugger = "${lib.getExe debuggerPython}",
            }
          '';
        };

        programs.neovim.plugins = lib.optionals config.dotfiles.neovim.dap.enable [
          pkgs.vimPlugins.nvim-dap-python
        ];

        home.packages =
          with pkgs;
          [ black ]
          ++ lib.optionals config.dotfiles.neovim.lsp.enable [ pyright ]
          ++ lib.optionals config.dotfiles.neovim.dap.enable [ debuggerPython ];
      };
    };
}
