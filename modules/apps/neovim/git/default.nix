{ den, ... }:
{
  den.aspects.apps.neovim.git.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.git.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.git.enable = lib.mkEnableOption "Neovim git integration" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.git.enable {
        dotfiles.neovim.configFiles."lua/my/plugins/git.lua" = "git/git.lua";

        dotfiles.neovim.treesitterParsers = [
          "diff"
          "gitignore"
          "gitcommit"
          "gitattributes"
          "git_rebase"
          "git_config"
        ];

        programs.neovim.plugins = [ pkgs.vimPlugins.gitsigns-nvim ];
      };
    };
}
