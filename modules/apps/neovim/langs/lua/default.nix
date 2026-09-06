{ den, ... }:
{
  den.aspects.apps.neovim.langs.lua.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.langs.lua.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.langs.lua.enable = lib.mkEnableOption "Neovim Lua support" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.langs.lua.enable {
        dotfiles.neovim.configFiles = {
          "lua/my/langs/lua.lua" = "langs/lua/lua.lua";
          "after/lsp/lua_ls.lua" = lib.mkIf config.dotfiles.neovim.lsp.enable "langs/lua/lua_ls.lua";
        };
        dotfiles.neovim.treesitterParsers = [ "lua" ];

        home.packages =
          with pkgs;
          [ stylua ]
          ++ lib.optionals config.dotfiles.neovim.lsp.enable [ lua-language-server ]
          ++ lib.optionals config.dotfiles.neovim.linting.enable [ luajitPackages.luacheck ];
      };
    };
}
