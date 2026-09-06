{ den, ... }:
{
  den.aspects.apps.neovim.langs.xml.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.langs.xml.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.langs.xml.enable = lib.mkEnableOption "Neovim XML support" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.langs.xml.enable {
        dotfiles.neovim.configFiles."lua/my/langs/xml.lua" = "langs/xml/xml.lua";
        dotfiles.neovim.treesitterParsers = [ "xml" ];

        home.packages =
          with pkgs;
          [ xmlformat ] ++ lib.optionals config.dotfiles.neovim.lsp.enable [ lemminx ];
      };
    };
}
