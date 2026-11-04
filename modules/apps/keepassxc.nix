{ den, ... }:
{
  den.aspects.apps.keepassxc.includes = [ den.aspects.homebrew ];

  den.aspects.apps.keepassxc.darwin.homebrew.casks = [ "keepassxc" ];

  den.aspects.apps.keepassxc.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      warnPreferencesSkipped = import ../_lib/app-preferences-warning.nix { inherit lib; };
      keepassxcSettings = {
        General = {
          URLDoubleClickAction = 2;
          UpdateCheckMessageShown = true;
        };

        Browser = {
          AlwaysAllowAccess = config.dotfiles.helium.enable;
          Enabled = config.dotfiles.helium.enable;
          UpdateBinaryPath = false;
        };

        GUI = {
          CheckForUpdates = false;
          MinimizeOnStartup = false;
          MinimizeToTray = false;
          ShowTrayIcon = false;
        };

        Security.IconDownloadFallback = true;
      };

      settingsFile = (pkgs.formats.ini { }).generate "keepassxc-settings" keepassxcSettings;
      applySettings = pkgs.writeShellScript "configure-keepassxc-settings" ''
        set -eu

        config_dir="$HOME/Library/Application Support/KeePassXC"
        config_file="$config_dir/keepassxc.ini"
        temporary="$(/usr/bin/mktemp -t keepassxc-settings)"
        staged=""
        trap '/bin/rm -f "$temporary"; if [[ -n "$staged" ]]; then /bin/rm -f "$staged"; fi' EXIT

        if [[ -e "$config_file" && ! -f "$config_file" && ! -L "$config_file" ]]; then
          echo "Refusing to replace non-file KeePassXC settings: $config_file" >&2
          exit 1
        fi

        if [[ -f "$config_file" || -L "$config_file" ]]; then
          /bin/cp "$config_file" "$temporary"
        fi

        ${pkgs.crudini}/bin/crudini --merge "$temporary" < ${settingsFile}

        if [[ -f "$config_file" && ! -L "$config_file" ]]; then
          if /usr/bin/cmp -s "$temporary" "$config_file"; then
            exit 0
          elif [[ $? -ne 1 ]]; then
            echo "Could not compare KeePassXC settings: $config_file" >&2
            exit 1
          fi
        fi

        mkdir -p "$config_dir"
        staged="$(/usr/bin/mktemp "$config_dir/.keepassxc-settings.XXXXXX")"
        install -m 0600 "$temporary" "$staged"
        mv -f "$staged" "$config_file"
      '';
    in
    {
      dotfiles.keepassxc.enable = lib.mkDefault true;

      home.activation.configureKeePassXCSettings = lib.mkIf config.dotfiles.keepassxc.enable (
        config.lib.dag.entryAfter [ "linkGeneration" ] ''
          if /usr/bin/pgrep -x -u "$(id -u)" KeePassXC >/dev/null; then
            ${warnPreferencesSkipped "KeePassXC"}
          elif ! run ${applySettings}; then
            echo 'Warning: could not update KeePassXC settings. Fix the error and run `just switch` again to apply them.' >&2
          fi
        ''
      );
    };
}
