{ ... }:
{
  den.aspects.nix-settings.darwin =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      nix.gc = {
        automatic = true;
        interval = [
          {
            Hour = 4;
            Minute = 0;
          }
        ];
        options = "--delete-older-than 30d";
      };

      launchd.daemons.nix-gc.command = lib.mkForce (
        pkgs.writeShellScript "nix-store-maintenance" ''
          set -e
          ${config.nix.package}/bin/nix-collect-garbage ${config.nix.gc.options}
          ${config.nix.package}/bin/nix-store --optimise
        ''
      );

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
}
