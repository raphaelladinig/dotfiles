{ den, ... }:
{
  den.aspects.apps.neovim.dap.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.dap.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkMerge [
        { dotfiles.neovim.dap.enable = lib.mkDefault true; }
        (lib.mkIf config.dotfiles.neovim.dap.enable {
          dotfiles.neovim.configFiles."lua/my/plugins/dap.lua" = "dap/dap.lua";

          programs.neovim.plugins = [
            pkgs.vimPlugins.nvim-dap
          ]
          ++ lib.optionals config.dotfiles.neovim.treesitter.enable [
            pkgs.vimPlugins.nvim-dap-virtual-text
          ];
        })
      ];
    };
}
