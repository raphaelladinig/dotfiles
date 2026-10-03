{ den, ... }:
{
  den.aspects.hosts.caelum = {
    includes = [
      den.aspects.home-manager
      den.aspects.macos
    ];

    darwin =
      { config, lib, ... }:
      {
        networking = {
          computerName = "caelum";
          hostName = "caelum";
          localHostName = "caelum";
        };

        # nix-darwin only applies `users.users.<name>.shell` to accounts it
        # manages via `users.knownUsers`; this account predates the config, so
        # set the login shell directly with dscl.
        system.activationScripts.users.text = lib.mkIf config.programs.fish.enable (
          lib.mkAfter ''
            dscl . -create ${lib.escapeShellArg "/Users/${config.system.primaryUser}"} UserShell /run/current-system/sw/bin/fish
          ''
        );
      };
  };
}
