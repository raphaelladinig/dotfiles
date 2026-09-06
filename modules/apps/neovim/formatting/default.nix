{ den, ... }:
{
  den.aspects.apps.neovim.formatting.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.formatting.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkMerge [
        { dotfiles.neovim.formatting.enable = lib.mkDefault true; }
        (lib.mkIf config.dotfiles.neovim.formatting.enable {
          dotfiles.neovim.configFiles."lua/my/plugins/formatting.lua" = "formatting/formatting.lua";

          programs.neovim.plugins = [ pkgs.vimPlugins.conform-nvim ];
        })
      ];
    };
}
