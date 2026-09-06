{ den, ... }:
{
  den.aspects.apps.neovim.ui.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.ui.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.ui.enable = lib.mkEnableOption "Neovim UI" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.ui.enable {
        dotfiles.neovim.configFiles = {
          "lua/my/ui/colorscheme.lua" = "ui/colorscheme.lua";
          "lua/my/ui/editor.lua" = "ui/editor.lua";
          "lua/my/ui/lualine.lua" = "ui/lualine.lua";
        };

        programs.neovim.plugins = with pkgs.vimPlugins; [
          catppuccin-nvim
          indent-blankline-nvim
          lualine-nvim
          nvim-web-devicons
        ];
      };
    };
}
