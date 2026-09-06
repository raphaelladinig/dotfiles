{ den, ... }:
let
  domain = "com.henrikruscon.Alcove";
  preferences = {
    "NSStatusItem VisibleCC Alcove" = true;
    "NSStatusItem VisibleCC Item-0" = false;
    automaticallyCheckForUpdates = false;
    enableBattery = false;
    enableBrightness = true;
    enableVolume = true;
    expandNotchOnHover = true;
    forceSimulatedNotch = true;
    launchAtLogin = true;
    musicApp = "system";
    nowPlayingStyle = "frosted";
    playSoundOnLock = true;
    playSoundOnLowConnectBattery = true;
    showVolumeControl = true;
    warnOnLowConnectBattery = true;
  };
in
{
  den.aspects.apps.alcove = {
    includes = [
      den.aspects.homebrew
      den.aspects.app-preferences
    ];

    darwin = {
      homebrew.casks = [ "alcove" ];

      dotfiles.appPreferences.alcove = {
        inherit domain preferences;
        processName = "Alcove";
      };
    };
  };
}
