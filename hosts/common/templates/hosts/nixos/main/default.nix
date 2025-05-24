{
  inputs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../../../system-config.nix
    ../../../../users/nixos/root
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    ../../../../impermanence.nix
    ../../../../agenix.nix
    ../../../../users/nixos/raphael
    ../../../../network.nix
    ../../../../audio.nix
    ../../../../printing.nix
    ../../../../grub.nix
  ];

  hostSpec = {
    hostPlatform = "x86_64-linux";
    locale = "en_US.UTF-8";
    timezone = "Europe/Vienna";
    yubikey = true;
    agenixIdentityPaths = [
      "/persist/var/lib/agenix/age_raphael.txt"
    ];
  };
}
