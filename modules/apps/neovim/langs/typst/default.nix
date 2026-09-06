{ den, ... }:
{
  den.aspects.apps.neovim.langs.typst.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.langs.typst.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.langs.typst.enable = lib.mkEnableOption "Neovim Typst support" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.langs.typst.enable {
        dotfiles.neovim.configFiles = {
          "lua/my/langs/typst.lua" = "langs/typst/typst.lua";
          "after/lsp/tinymist.lua" = lib.mkIf config.dotfiles.neovim.lsp.enable "langs/typst/tinymist.lua";
          "after/ftplugin/typst.lua" = "langs/typst/ftplugin.lua";
        };
        dotfiles.neovim.treesitterParsers = [ "typst" ];

        programs.neovim.plugins = [
          {
            plugin = pkgs.vimPlugins.typst-preview-nvim;
            optional = true;
          }
        ];

        home.packages = with pkgs; [
          # Preview needs tinymist even when the LSP integration is disabled.
          tinymist
          typstyle
          websocat
        ];
      };
    };
}
