{ den, lib, ... }:
{
  den.default.includes = [
    den.aspects.nix-settings
    den.aspects.nixpkgs
  ];

  den.default.darwin.system.stateVersion = 6;
  den.default.homeManager =
    {
      lib,
      user,
      ...
    }:
    let
      mkAspectEnableOption =
        description: aspect:
        lib.mkEnableOption description
        // {
          apply = enabled: enabled && user.hasAspect.forClass "homeManager" aspect;
        };
    in
    {
      # Cross-aspect dotfiles.* flags are declared here so any aspect can test
      # another aspect's flag without requiring that aspect to be included.
      # A flag is effective only while its providing aspect is included.
      options.dotfiles = {
        keepassxc.enable = mkAspectEnableOption "KeePassXC" den.aspects.apps.keepassxc;
        orion.enable = mkAspectEnableOption "Orion" den.aspects.apps.orion;
        neovim = {
          dap.enable = mkAspectEnableOption "Neovim DAP" den.aspects.apps.neovim.dap;
          editing.enable = mkAspectEnableOption "Neovim editing helpers" den.aspects.apps.neovim.editing;
          formatting.enable = mkAspectEnableOption "Neovim formatting" den.aspects.apps.neovim.formatting;
          linting.enable = mkAspectEnableOption "Neovim linting" den.aspects.apps.neovim.linting;
          lsp.enable = mkAspectEnableOption "Neovim LSP" den.aspects.apps.neovim.lsp;
          treesitter.enable = mkAspectEnableOption "Neovim tree-sitter" den.aspects.apps.neovim.treesitter;
        };
      };

      config.home.stateVersion = "26.05";
    };

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
}
