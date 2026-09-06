{ den, ... }:
{
  den.aspects.apps.neovim.langs.markdown.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.langs.markdown.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.langs.markdown.enable = lib.mkEnableOption "Neovim Markdown support" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.langs.markdown.enable {
        dotfiles.neovim.configFiles = {
          "lua/my/langs/markdown.lua" = "langs/markdown/markdown.lua";
          "after/ftplugin/markdown.lua" = "langs/markdown/ftplugin.lua";
        };
        dotfiles.neovim.treesitterParsers = [
          "markdown"
          "markdown_inline"
        ];

        programs.neovim.plugins = [ pkgs.vimPlugins.markdown-preview-nvim ];

        home.packages =
          with pkgs;
          [ prettierd ] ++ lib.optionals config.dotfiles.neovim.lsp.enable [ marksman ];
      };
    };
}
