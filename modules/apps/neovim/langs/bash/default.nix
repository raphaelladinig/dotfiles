{ den, ... }:
{
  den.aspects.apps.neovim.langs.bash.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.langs.bash.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.langs.bash.enable = lib.mkEnableOption "Neovim Bash support" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.langs.bash.enable {
        dotfiles.neovim.configFiles."lua/my/langs/bash.lua" = "langs/bash/bash.lua";
        dotfiles.neovim.treesitterParsers = [ "bash" ];

        home.packages =
          with pkgs;
          [
            shfmt
            shellcheck
          ]
          ++ lib.optionals config.dotfiles.neovim.lsp.enable [ bash-language-server ];
      };
    };
}
