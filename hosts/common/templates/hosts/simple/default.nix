{
  inputs,
  modulesPath,
  outputs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    outputs.nixosModules.host-spec
    ../../../system-config.nix
    ../../../users/root
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    ../../../impermanence.nix
    ../../../sops.nix
    ../../../users/raphael
    ../../../network.nix
    ../../../audio.nix
    ../../../printing.nix
    ../../../scanning.nix
    ../../../grub.nix
  ];

  hostSpec = {
    hostPlatform = "x86_64-linux";
    locale = "en_US.UTF-8";
    timezone = "Europe/Vienna";
    yubikey = true;
    sopsAgeKeyFile = "/persist/var/lib/sops-nix/keys.txt";
    secretsPath = "${builtins.toString inputs.secrets}/src/age_raphael";
  };

  "userSpec-raphael".scanning = true;
}
