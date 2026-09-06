{ lib }: processName: ''
  printf '\033[1;33m%s\033[0m\n' ${lib.escapeShellArg "Skipping ${processName} preferences: quit ${processName} and run `just switch` again to apply its settings."}
''
