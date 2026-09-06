{ den, ... }:
{
  den.aspects.apps.neovim.editing.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.editing.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkMerge [
        { dotfiles.neovim.editing.enable = lib.mkDefault true; }
        (lib.mkIf config.dotfiles.neovim.editing.enable {
          dotfiles.neovim.configFiles."lua/my/plugins/editing.lua" = "editing/editing.lua";

          programs.neovim.plugins = with pkgs.vimPlugins; [
            nvim-surround
            nvim-autopairs
            img-clip-nvim
          ];

          home.packages = [ pkgs.pngpaste ];
        })
      ];
    };
}
