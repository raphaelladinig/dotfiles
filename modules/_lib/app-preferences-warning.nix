{ lib }:
processName:
let
  marker = "app_preferences_warned_${builtins.hashString "sha256" processName}";
in
''
  if [[ "''${${marker}:-}" != true ]]; then
    ${marker}=true
    printf '\033[1;33m%s\033[0m\n' ${lib.escapeShellArg "Skipping ${processName} preferences: quit ${processName} and run `just switch` again to apply its settings."}
  fi
''
