{inputs, ...}: {
  imports = [
    ../common/templates/hosts/vm
    ./disk-config.nix
    ../common/sops.nix
    ./syncthing.nix
  ];

  hostSpec = {
    hostName = "hetzner-cloud";
    sopsAgeKeyFile = "/var/lib/sops-nix/keys.txt";
    secretsPath = "${builtins.toString inputs.secrets}/src/age_hetzner-cloud";
  };
}
