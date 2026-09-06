{ ... }:
{
  den.aspects.app-preferences.darwin =
    { config, lib, ... }:
    let
      warnPreferencesSkipped = import ./_lib/app-preferences-warning.nix { inherit lib; };
      applyIfClosed =
        {
          prefix,
          user,
          domain,
          processName,
          preferences,
        }:
        let
          run =
            command:
            ''launchctl asuser "''$${prefix}_user_id" sudo --user="''$${prefix}_user" --set-home -- ${command}'';
          valueString = value: if builtins.isBool value then if value then "1" else "0" else toString value;
          valueType =
            value:
            if builtins.isBool value then
              "-bool"
            else if builtins.isInt value then
              "-int"
            else if builtins.isFloat value then
              "-float"
            else if builtins.isString value then
              "-string"
            else
              throw "App preferences support only boolean, integer, float, and string values.";
        in
        ''
          ${prefix}_user=${lib.escapeShellArg user}
          ${prefix}_user_id="$(id -u -- "''$${prefix}_user")"
          ${prefix}_preferences_changed=false

          ${prefix}_default_matches() {
            local actual
            actual="$(
              ${run "/usr/bin/defaults read ${lib.escapeShellArg domain}"} "$1" 2>/dev/null
            )" || return 1
            [[ "$actual" == "$2" ]]
          }

          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (name: value: ''
              if ! ${prefix}_default_matches ${lib.escapeShellArg name} ${lib.escapeShellArg (valueString value)}; then
                ${prefix}_preferences_changed=true
              fi
            '') preferences
          )}

          if [[ "''$${prefix}_preferences_changed" == true ]]; then
            if /usr/bin/pgrep -x -u "''$${prefix}_user_id" ${lib.escapeShellArg processName} >/dev/null; then
              ${warnPreferencesSkipped processName}
            else
              ${lib.concatStringsSep "\n" (
                lib.mapAttrsToList (
                  name: value:
                  run "/usr/bin/defaults write ${lib.escapeShellArg domain} ${lib.escapeShellArg name} ${valueType value} ${lib.escapeShellArg (valueString value)}"
                ) preferences
              )}
            fi
          fi
        '';
    in
    {
      options.dotfiles.appPreferences = lib.mkOption {
        default = { };
        description = "Application preferences applied only while the application is closed.";
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              domain = lib.mkOption {
                type = lib.types.str;
                description = "macOS preferences domain.";
              };
              processName = lib.mkOption {
                type = lib.types.str;
                description = "Exact process name used to detect whether the application is running.";
              };
              preferences = lib.mkOption {
                type = lib.types.attrsOf (
                  lib.types.oneOf [
                    lib.types.bool
                    lib.types.int
                    lib.types.float
                    lib.types.str
                  ]
                );
                default = { };
                description = "Preference keys and scalar values to apply.";
              };
            };
          }
        );
      };

      config.system.activationScripts.postActivation.text = lib.mkAfter (
        lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            name: settings:
            applyIfClosed {
              prefix = "app_preferences_${builtins.hashString "sha256" name}";
              user = config.system.primaryUser;
              inherit (settings) domain processName preferences;
            }
          ) config.dotfiles.appPreferences
        )
      );
    };
}
