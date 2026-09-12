{ ... }:
{
  den.aspects.macos.darwin =
    { config, lib, ... }:
    let
      userName = config.system.primaryUser;
      homeDirectory = config.users.users.${userName}.home;
      wallpaper = "${./config/blank.heic}";
      applyWallpaper = "${./config/apply-wallpaper.js}";
      wallpaperStore = "${homeDirectory}/Library/Application Support/com.apple.wallpaper/Store";
    in
    {
      security.pam.services.sudo_local.touchIdAuth = true;

      system.defaults = {
        NSGlobalDomain = {
          AppleShowAllExtensions = true;
          AppleShowScrollBars = "WhenScrolling";
          NSAutomaticCapitalizationEnabled = true;
          NSAutomaticPeriodSubstitutionEnabled = true;
          NSTableViewDefaultSizeMode = 2;
        };

        CustomUserPreferences."com.apple.dock" = {
          autohide = true;
          autohide-delay = 0.0;
          autohide-time-modifier = 0.0;
          largesize = 90;
          launchanim = false;
          magnification = true;
          mineffect = "scale";
          minimize-to-application = true;
          orientation = "bottom";
          show-recents = false;
          tilesize = 75;
          wvous-bl-corner = 10;
          wvous-br-corner = 4;
          wvous-tl-corner = 13;
          wvous-tr-corner = 12;
        };

        finder = {
          FXDefaultSearchScope = "SCcf";
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "Nlsv";
          FXRemoveOldTrashItems = true;
          NewWindowTarget = "Recents";
          ShowExternalHardDrivesOnDesktop = false;
          ShowHardDrivesOnDesktop = false;
          ShowPathbar = true;
          ShowRemovableMediaOnDesktop = true;
          ShowStatusBar = false;
        };

        trackpad = {
          ActuateDetents = true;
          Clicking = false;
          DragLock = false;
          Dragging = false;
          FirstClickThreshold = 0;
          ForceSuppressed = false;
          SecondClickThreshold = 0;
          TrackpadCornerSecondaryClick = 0;
          TrackpadFourFingerHorizSwipeGesture = 2;
          TrackpadFourFingerPinchGesture = 2;
          TrackpadFourFingerVertSwipeGesture = 2;
          TrackpadMomentumScroll = true;
          TrackpadPinch = true;
          TrackpadRightClick = true;
          TrackpadRotate = true;
          TrackpadThreeFingerDrag = false;
          TrackpadThreeFingerHorizSwipeGesture = 0;
          TrackpadThreeFingerTapGesture = 0;
          TrackpadThreeFingerVertSwipeGesture = 0;
          TrackpadTwoFingerDoubleTapGesture = true;
          TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
        };

        universalaccess = {
          mouseDriverCursorSize = 1.0;
          reduceMotion = true;
          reduceTransparency = false;
        };

        WindowManager = {
          AppWindowGroupingBehavior = true;
          AutoHide = true;
          EnableStandardClickToShowDesktop = true;
          EnableTiledWindowMargins = false;
          GloballyEnabled = false;
          HideDesktop = true;
          StageManagerHideWidgets = true;
          StandardHideWidgets = false;
        };

        controlcenter.BatteryShowPercentage = true;

        hitoolbox.AppleFnUsageType = "Do Nothing";
      };

      # nix-darwin restarts Dock unconditionally for system.defaults.dock.
      # Write those preferences above, then restart only when they changed.
      system.activationScripts.userDefaults.text = lib.mkMerge [
        (lib.mkBefore ''
          dock_preferences_before=$(launchctl asuser "$(id -u -- ${lib.escapeShellArg userName})" \
            sudo --user=${lib.escapeShellArg userName} -- defaults export com.apple.dock - 2>/dev/null) || dock_preferences_before=""
        '')
        (lib.mkAfter ''
          dock_preferences_after=$(launchctl asuser "$(id -u -- ${lib.escapeShellArg userName})" \
            sudo --user=${lib.escapeShellArg userName} -- defaults export com.apple.dock - 2>/dev/null) || dock_preferences_after=""
          if [[ -z "$dock_preferences_before" || -z "$dock_preferences_after" || "$dock_preferences_before" != "$dock_preferences_after" ]]; then
            echo >&2 "restarting Dock..."
            killall -qu ${lib.escapeShellArg userName} Dock || true
          fi
        '')
      ];

      launchd.user.agents.apply-wallpaper = {
        script = ''
          if [[ "$(/usr/bin/id -un)" != ${lib.escapeShellArg userName} ]]; then
            exit 0
          fi

          if [[ ! -f ${lib.escapeShellArg wallpaper} ]]; then
            echo "Wallpaper not found: ${wallpaper}" >&2
            exit 1
          fi

          /usr/bin/osascript -l JavaScript \
            ${lib.escapeShellArg applyWallpaper} \
            ${lib.escapeShellArg wallpaper}
        '';

        serviceConfig = {
          LimitLoadToSessionType = "Aqua";
          ProcessType = "Interactive";
          RunAtLoad = true;
          # Attaching a display gives it a default wallpaper and rewrites the
          # store, so re-apply whenever the store changes instead of only at
          # login. The script is a no-op once every screen already matches.
          WatchPaths = [ wallpaperStore ];
        };
      };
    };
}
