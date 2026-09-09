{ den, ... }:
{
  den.aspects.apps.helium.includes = [
    den.aspects.homebrew
    den.aspects.app-preferences
  ];

  den.aspects.apps.helium.darwin =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      warnPreferencesSkipped = import ../../_lib/app-preferences-warning.nix { inherit lib; };
      user = config.system.primaryUser;
      userDataDir = "${config.users.users.${user}.home}/Library/Application Support/net.imput.helium";
      asUser =
        command:
        ''launchctl asuser "$(id -u -- ${lib.escapeShellArg user})" sudo --user=${lib.escapeShellArg user} --set-home -- ${command}'';
      policyFile = "/Library/Managed Preferences/${user}/net.imput.helium.plist";
    in
    {
      homebrew.casks = [ "helium-browser" ];

      dotfiles.appPreferences.helium = {
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

      system.activationScripts.postActivation.text = lib.mkAfter ''
        if /usr/bin/pgrep -x -u "$(id -u -- ${lib.escapeShellArg user})" Helium >/dev/null; then
          ${warnPreferencesSkipped "Helium"}
        else
          ${asUser "${pkgs.python3}/bin/python3 ${./apply-preferences.py}"} \
            ${lib.escapeShellArg "${userDataDir}/Default/Preferences"} ${./preferences.json}
          ${asUser "${pkgs.python3}/bin/python3 ${./apply-preferences.py}"} \
            ${lib.escapeShellArg "${userDataDir}/Local State"} ${./local-state.json}
          ${pkgs.python3}/bin/python3 ${./apply-extension-policy.py} \
            ${lib.escapeShellArg policyFile} ${./extensions.csv}
        fi
      '';
    };

  den.aspects.apps.helium.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      dotfiles.helium.enable = lib.mkDefault true;

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
