{
  config,
  outputs,
  ...
}: let
  locale = config.hostSpec.locale;
  timezone = config.hostSpec.timezone;
in {
  hostSpec = {
    stateVersion = "25.11";
    useOSProber = false;
  };

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = builtins.attrValues outputs.overlays;
  };

  networking.hostName = config.hostSpec.hostName;

  nixpkgs.hostPlatform = config.hostSpec.hostPlatform;

  system.stateVersion = config.hostSpec.stateVersion;

  programs.nix-ld.enable = true;
  time.timeZone = "${timezone}";

  i18n.defaultLocale = "${locale}";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "${locale}";
    LC_IDENTIFICATION = "${locale}";
    LC_MEASUREMENT = "${locale}";
    LC_MONETARY = "${locale}";
    LC_NAME = "${locale}";
    LC_NUMERIC = "${locale}";
    LC_PAPER = "${locale}";
    LC_TELEPHONE = "${locale}";
    LC_TIME = "${locale}";
  };

  console = {
    earlySetup = true;
    useXkbConfig = true;
  };

  services.xserver.xkb = {
    layout = "us, us";
    variant = "colemak_dh_ortho";
    options = "grp:alt_space_toggle";
  };
}
