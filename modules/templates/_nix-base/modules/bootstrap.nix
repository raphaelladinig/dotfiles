{ inputs, lib, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.default
    inputs.flake-file.flakeModules.import-tree
    (inputs.flake-parts.flakeModules.modules or { })
    (inputs.den.flakeModules.dendritic or { })
  ];

  flake-file.outputs = lib.mkDefault "dendritic";
  flake-file.nixConfig.extra-experimental-features = [
    "nix-command"
    "flakes"
  ];
  flake.modules = { };
  systems = lib.mkDefault lib.systems.flakeExposed;

  flake-file.inputs = {
    den.url = "github:denful/den";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-unstable";
    };
  };
}
