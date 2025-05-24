{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    age.keyFile = config.hostSpec.sopsAgeKeyFile;
    defaultSopsFormat = "binary";
  };
}
