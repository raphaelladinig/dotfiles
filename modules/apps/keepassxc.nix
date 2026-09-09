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
    in
    {
      dotfiles.keepassxc.enable = lib.mkDefault true;

      home.activation.configureKeePassXCSettings = lib.mkIf config.dotfiles.keepassxc.enable (
        config.lib.dag.entryAfter [ "linkGeneration" ] ''
          if /usr/bin/pgrep -x -u "$(id -u)" KeePassXC >/dev/null; then
            ${warnPreferencesSkipped "KeePassXC"}
          else
            (
              config_dir="$HOME/Library/Application Support/KeePassXC"
              config_file="$config_dir/keepassxc.ini"
              temporary="$(/usr/bin/mktemp -t keepassxc-settings)"
              trap '/bin/rm -f "$temporary"' EXIT

              if [[ -e "$config_file" && ! -f "$config_file" && ! -L "$config_file" ]]; then
                echo "Refusing to replace non-file KeePassXC settings: $config_file" >&2
                exit 1
              fi

              if [[ -f "$config_file" || -L "$config_file" ]]; then
                /bin/cp "$config_file" "$temporary"
              fi

              ${pkgs.crudini}/bin/crudini --merge "$temporary" < ${settingsFile}

              if [[ -L "$config_file" ]] || ! /usr/bin/cmp -s "$temporary" "$config_file"; then
                run mkdir -p "$config_dir"
                if [[ -L "$config_file" ]]; then
                  run rm "$config_file"
                fi
                run install -m 0600 "$temporary" "$config_file"
              fi
            )
          fi
        ''
      );
    };
}
