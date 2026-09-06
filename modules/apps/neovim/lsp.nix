{ den, ... }:
{
  den.aspects.apps.neovim.lsp.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.lsp.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkMerge [
        { dotfiles.neovim.lsp.enable = lib.mkDefault true; }
        (lib.mkIf config.dotfiles.neovim.lsp.enable {
          programs.neovim.plugins = [ pkgs.vimPlugins.nvim-lspconfig ];
        })
      ];
    };
}
