{ den, ... }:
{
  den.aspects.apps.neovim.linting.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.linting.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkMerge [
        { dotfiles.neovim.linting.enable = lib.mkDefault true; }
        (lib.mkIf config.dotfiles.neovim.linting.enable {
          dotfiles.neovim.configFiles."lua/my/plugins/linting.lua" = "linting/linting.lua";

          programs.neovim.plugins = [ pkgs.vimPlugins.nvim-lint ];
        })
      ];
    };
}
