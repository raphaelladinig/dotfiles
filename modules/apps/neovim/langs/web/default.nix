{ den, ... }:
{
  den.aspects.apps.neovim.langs.web.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.langs.web.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.langs.web.enable = lib.mkEnableOption "Neovim web support" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.langs.web.enable {
        dotfiles.neovim.configFiles."lua/my/langs/web.lua" = "langs/web/web.lua";
        dotfiles.neovim.treesitterParsers = [
          "css"
          "scss"
          "html"
          "javascript"
          "typescript"
          "tsx"
          "json"
        ];

        home.packages =
          with pkgs;
          [ prettierd ]
          ++ lib.optionals config.dotfiles.neovim.lsp.enable [
            vtsls
            vscode-langservers-extracted
          ];
      };
    };
}
