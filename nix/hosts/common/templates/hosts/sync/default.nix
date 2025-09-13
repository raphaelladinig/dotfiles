{
  inputs,
  config,
  ...
}: {
  imports = [
    ../vm
    ./disk-config.nix
    ../../../sops.nix
    ./syncthing.nix
  ];

  hostSpec = {
    sopsAgeKeyFile = "/var/lib/sops-nix/keys.txt";
    secretsPath = "${builtins.toString inputs.secrets}/src/age_${config.hostSpec.hostName}";
  };
}
