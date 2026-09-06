{ den, ... }:
{
  den.aspects.apps.neovim.langs.cpp.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.langs.cpp.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.langs.cpp.enable = lib.mkEnableOption "Neovim C/C++ support" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.langs.cpp.enable {
        dotfiles.neovim.configFiles."lua/my/langs/cpp.lua" = "langs/cpp/cpp.lua";
        dotfiles.neovim.treesitterParsers = [
          "cpp"
          "c"
        ];

        home.packages =
          with pkgs;
          # clang-tools supplies both clangd and clang-format.
          lib.optionals (config.dotfiles.neovim.lsp.enable || config.dotfiles.neovim.formatting.enable) [
            clang-tools
          ]
          ++ lib.optionals config.dotfiles.neovim.dap.enable [ lldb ];
      };
    };
}
