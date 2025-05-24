{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  hostSpec.secretsPath = "${builtins.toString inputs.secrets}/secrets";

  environment.systemPackages = [
    inputs.agenix.packages.${config.hostSpec.hostPlatform}.default
  ];

  age.identityPaths = config.hostSpec.agenixIdentityPaths;
}
