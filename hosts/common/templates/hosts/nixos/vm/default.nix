{
  inputs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    ../../../../system-config.nix
    ../../../../grub.nix
    ../../../../users/nixos/root
  ];

  hostSpec = {
    hostPlatform = "x86_64-linux";
    locale = "en_US.UTF-8";
    timezone = "Europe/Vienna";
  };
}
