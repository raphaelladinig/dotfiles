{ den, ... }:
{
  den.aspects.apps.neovim.completion.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.completion.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.completion.enable = lib.mkEnableOption "Neovim completion" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.completion.enable {
        dotfiles.neovim.configFiles."lua/my/plugins/completion.lua" = "completion/completion.lua";

        programs.neovim.plugins = with pkgs.vimPlugins; [
          {
            plugin = blink-cmp;
            optional = true;
          }
          {
            plugin = luasnip;
            optional = true;
          }
          {
            plugin = friendly-snippets;
            optional = true;
          }
        ];
      };
    };
}
