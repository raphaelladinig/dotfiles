{ inputs, ... }:
{
  flake-file.inputs.homebrew-cask = {
    url = "github:Homebrew/homebrew-cask";
    flake = false;
  };
  flake-file.inputs.homebrew-core = {
    url = "github:Homebrew/homebrew-core";
    flake = false;
  };
  flake-file.inputs.nix-homebrew.url = "github:zhaofengli/nix-homebrew";

  den.aspects.homebrew.darwin =
    { config, ... }:
    {
      imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

      nix-homebrew = {
        enable = true;
        autoMigrate = true;
        mutableTaps = false;
        taps = {
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
          "homebrew/homebrew-core" = inputs.homebrew-core;
        };
        user = config.system.primaryUser;
      };

      homebrew = {
        enable = true;
        taps = builtins.attrNames config.nix-homebrew.taps;

        onActivation = {
          autoUpdate = false;
          cleanup = "uninstall";
          upgrade = true;
        };
      };
    };
}
