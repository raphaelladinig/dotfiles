{ den, ... }:
{
  den.aspects.apps.neovim.treesitter.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.treesitter.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkMerge [
        { dotfiles.neovim.treesitter.enable = lib.mkDefault true; }
        (lib.mkIf config.dotfiles.neovim.treesitter.enable {
          dotfiles.neovim.configFiles."lua/my/plugins/treesitter.lua" = "treesitter/treesitter.lua";

          dotfiles.neovim.treesitterParsers = [
            "vim"
            "vimdoc"
          ];

          programs.neovim.plugins = with pkgs.vimPlugins; [
            (nvim-treesitter.withPlugins (
              parsers: map (name: parsers.${name}) config.dotfiles.neovim.treesitterParsers
            ))
            nvim-treesitter-textobjects
            nvim-treesitter-context
            nvim-ts-autotag
          ];

          home.packages = [ pkgs.tree-sitter ];
        })
      ];
    };
}
