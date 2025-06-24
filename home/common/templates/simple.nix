{homeSpec, ...}: {
  imports = [
    ../xdg-user-dirs.nix
    ../nixpkgs
    ../agenix.nix
  ];

  homeSpec = {
    agenixIdentityPaths = homeSpec.agenixIdentityPaths;
  };
}
