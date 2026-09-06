{ den, ... }:
{
  den.aspects.apps.neovim.langs.just.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.langs.just.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.langs.just.enable = lib.mkEnableOption "Neovim Just support" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.langs.just.enable {
        dotfiles.neovim.configFiles."lua/my/langs/just.lua" = "langs/just/just.lua";
        dotfiles.neovim.treesitterParsers = [ "just" ];

        home.packages = with pkgs; [ just ] ++ lib.optionals config.dotfiles.neovim.lsp.enable [ just-lsp ];
      };
    };
}
