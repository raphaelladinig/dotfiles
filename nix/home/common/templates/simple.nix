{hostSpec, ...}: {
  imports = [
    ../xdg-user-dirs.nix
    ../nixpkgs
    ../sops.nix
  ];

  homeSpec = {
    secretsPath = hostSpec.secretsPath;
    sopsAgeKeyFile = hostSpec.sopsAgeKeyFile;
  };
}
