{ den, ... }:
{
  den.aspects.apps.neovim.spell.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.spell.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.spell.enable = lib.mkEnableOption "Neovim spell files" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.spell.enable {
        xdg.configFile = {
          "nvim/spell/de.utf-8.spl".source = pkgs.fetchurl {
            url = "https://ftp.nluug.nl/pub/vim/runtime/spell/de.utf-8.spl";
            hash = "sha256-c8cQfqM5hWzb6SHeuSpFk5xN5uucByYdobndGfaDo9E=";
          };

          "nvim/spell/de.utf-8.sug".source = pkgs.fetchurl {
            url = "https://ftp.nluug.nl/pub/vim/runtime/spell/de.utf-8.sug";
            hash = "sha256-E9Ds+Shj2J72DNSopesqWhOg6Pm6jRxqvkerqFcUqUg=";
          };
        };
      };
    };
}
