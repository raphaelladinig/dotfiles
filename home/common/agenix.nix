{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  age.identityPaths = config.homeSpec.agenixIdentityPaths;
}
