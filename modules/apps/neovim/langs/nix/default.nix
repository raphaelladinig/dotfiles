{ den, ... }:
{
  den.aspects.apps.neovim.langs.nix.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.langs.nix.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.langs.nix.enable = lib.mkEnableOption "Neovim Nix support" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.langs.nix.enable {
        dotfiles.neovim.configFiles."lua/my/langs/nix.lua" = "langs/nix/nix.lua";
        dotfiles.neovim.treesitterParsers = [ "nix" ];

        home.packages = with pkgs; [ nixfmt ] ++ lib.optionals config.dotfiles.neovim.lsp.enable [ nixd ];
      };
    };
}
