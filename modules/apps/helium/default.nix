{ den, ... }:
{
  den.aspects.apps.helium.includes = [
    den.aspects.homebrew
    den.aspects.app-preferences
  ];

  den.aspects.apps.helium.darwin.homebrew.casks = [ "helium-browser" ];

  den.aspects.apps.helium.darwin.dotfiles.appPreferences.helium = {
    domain = "net.imput.helium";
    processName = "Helium";
    preferences = {
      SUAutomaticallyUpdate = true;
      SUEnableAutomaticChecks = true;
      DefaultSearchProviderEnabled = true;
      DefaultSearchProviderName = "DuckDuckGo";
      DefaultSearchProviderKeyword = "duckduckgo.com";
      DefaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
      DefaultSearchProviderSuggestURL = "https://duckduckgo.com/ac/?q={searchTerms}&type=list";
    };
  };

  den.aspects.apps.helium.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      warnPreferencesSkipped = import ../../_lib/app-preferences-warning.nix { inherit lib; };
      userDataDir = "${config.home.homeDirectory}/Library/Application Support/net.imput.helium";
    in
    {
      dotfiles.helium.enable = lib.mkDefault true;

      home.activation.configureHeliumPreferences = lib.mkIf config.dotfiles.helium.enable (
        config.lib.dag.entryAfter [ "linkGeneration" ] ''
          if /usr/bin/pgrep -x -u "$(id -u)" Helium >/dev/null; then
            ${warnPreferencesSkipped "Helium"}
          else
            run ${pkgs.python3}/bin/python3 ${./apply-preferences.py} \
              ${lib.escapeShellArg "${userDataDir}/Default/Preferences"} ${./preferences.json}
            run ${pkgs.python3}/bin/python3 ${./apply-preferences.py} \
              ${lib.escapeShellArg "${userDataDir}/Local State"} ${./local-state.json}
          fi
        ''
      );

      home.activation.remindHeliumExtensions = lib.mkIf config.dotfiles.helium.enable (
        config.lib.dag.entryAfter [ "linkGeneration" ] ''
          ${pkgs.python3}/bin/python3 ${./check-extensions.py} \
            ${./extensions.csv} \
            ${lib.escapeShellArg "${config.home.homeDirectory}/Library/Application Support/net.imput.helium/Default/Extensions"}
        ''
      );

      home.file."Library/Application Support/net.imput.helium/NativeMessagingHosts/org.keepassxc.keepassxc_browser.json" =
        lib.mkIf (config.dotfiles.helium.enable && config.dotfiles.keepassxc.enable) {
          source = (pkgs.formats.json { }).generate "org.keepassxc.keepassxc_browser.json" {
            name = "org.keepassxc.keepassxc_browser";
            description = "KeePassXC integration with native messaging support";
            path = "/Applications/KeePassXC.app/Contents/MacOS/keepassxc-proxy";
            type = "stdio";
            allowed_origins = [ "chrome-extension://oboonakemofpalcgghocfoadofidjkkk/" ];
          };
        };
    };
}
