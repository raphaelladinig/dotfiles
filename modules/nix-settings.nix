{ ... }:
{
  den.aspects.nix-settings.darwin = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
