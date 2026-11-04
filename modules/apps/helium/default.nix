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
      extensionPython = pkgs.python3.withPackages (ps: [ ps.plyvel ]);
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
          if ! ${asUser "${pkgs.python3}/bin/python3 ${./apply-preferences.py}"} \
            ${lib.escapeShellArg "${userDataDir}/Default/Preferences"} ${./preferences.json}; then
            printf '%s\n' ${lib.escapeShellArg "Could not apply Helium preferences at ${userDataDir}/Default/Preferences. Check the error above, fix access or file contents, and run `just switch` again with Helium closed."} >&2
          fi
          if ! ${asUser "${pkgs.python3}/bin/python3 ${./apply-preferences.py}"} \
            ${lib.escapeShellArg "${userDataDir}/Local State"} ${./local-state.json}; then
            printf '%s\n' ${lib.escapeShellArg "Could not apply Helium Local State at ${userDataDir}/Local State. Check the error above, fix access or file contents, and run `just switch` again with Helium closed."} >&2
          fi
          if ! ${asUser "${extensionPython}/bin/python3 ${./apply-dark-reader.py}"} \
            ${lib.escapeShellArg "${userDataDir}/Default"}; then
            printf '%s\n' ${lib.escapeShellArg "Could not apply Helium Dark Reader settings under ${userDataDir}/Default. Check the error above, fix access or close processes using its extension databases, and run `just switch` again with Helium closed."} >&2
          fi
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

      home.file.".config/helium/extensions.mobileconfig" = {
        source = pkgs.runCommand "helium-extensions.mobileconfig" { } ''
          ${pkgs.python3}/bin/python3 ${./generate-extension-profile.py} ${./extensions.csv} "$out"
        '';
        onChange = ''
          echo 'Helium extension profile changed. Open ~/.config/helium/extensions.mobileconfig and install it in System Settings > General > Device Management.'
        '';
      };

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
