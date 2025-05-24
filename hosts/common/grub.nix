{
  config,
  lib,
  ...
}: {
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/EFI";
    };
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber =
        lib.mkIf config.hostSpec.useOSProber
        true;
      splashImage = null;
    };
  };
}
