{ den, ... }:
{
  den.aspects.apps.neovim.langs.yaml.includes = [ den.aspects.apps.neovim.core ];

  den.aspects.apps.neovim.langs.yaml.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.dotfiles.neovim.langs.yaml.enable = lib.mkEnableOption "Neovim YAML support" // {
        default = true;
      };

      config = lib.mkIf config.dotfiles.neovim.langs.yaml.enable {
        dotfiles.neovim.configFiles."lua/my/langs/yaml.lua" = "langs/yaml/yaml.lua";
        dotfiles.neovim.treesitterParsers = [ "yaml" ];

        home.packages =
          with pkgs;
          [ prettierd ] ++ lib.optionals config.dotfiles.neovim.lsp.enable [ yaml-language-server ];
      };
    };
}
