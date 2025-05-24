{
  config,
  lib,
  ...
}: {
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber =
      lib.mkIf config.hostSpec.useOSProber
      true;
    splashImage = null;
  };
}
