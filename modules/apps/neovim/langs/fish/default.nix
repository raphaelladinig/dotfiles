{ den, ... }:
{
  den.aspects.apps.neovim.langs.fish.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.langs.fish.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.langs.fish.enable = lib.mkEnableOption "Neovim Fish support" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.langs.fish.enable {
        dotfiles.neovim.configFiles."lua/my/langs/fish.lua" = "langs/fish/fish.lua";
        dotfiles.neovim.treesitterParsers = [ "fish" ];

        home.packages = with pkgs; [ fish ] ++ lib.optionals config.dotfiles.neovim.lsp.enable [ fish-lsp ];
      };
    };
}
