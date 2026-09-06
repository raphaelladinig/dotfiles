{ den, ... }:
{
  den.aspects.apps.neovim.navigation.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.navigation.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.navigation.enable = lib.mkEnableOption "Neovim navigation" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.navigation.enable {
        dotfiles.neovim.configFiles."lua/my/plugins/navigation.lua" = "navigation/navigation.lua";

        programs.neovim.plugins = with pkgs.vimPlugins; [
          oil-nvim
          fzf-lua
        ];

        home.packages = with pkgs; [
          fzf
          fd
          ripgrep
        ];
      };
    };
}
