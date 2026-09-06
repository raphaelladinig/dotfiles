{ inputs, ... }:
{
  flake-file.inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs-unstable { inherit system; };
    };

  den.aspects.nixpkgs.darwin =
    { system, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      nixpkgs.overlays = [
        (final: _prev: {
          stable = import inputs.nixpkgs-stable {
            inherit system;
            config.allowUnfree = final.config.allowUnfree or false;
          };
          unstable = import inputs.nixpkgs-unstable {
            inherit system;
            config.allowUnfree = final.config.allowUnfree or false;
          };
        })
      ];
    };
}
