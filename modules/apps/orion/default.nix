{ den, ... }:
let
  domain = "com.kagi.kagimacOS";
  preferences = {
    AllowCustomChromeColor = false;
    AllowWebsiteThemeColor = false;
    AppearanceStyle = "system";
    AskForEachDownload = true;
    AutoShowSidebar = true;
    AutofillEnabled = true;
    AutomaticPictureInPicture = "auto";
    ChromeThemeColor = "";
    CloseOtherProfilesOnQuit = false;
    CurrentToolbarSize = "small";
    CustomAppIcon = "appicon2";
    CustomAppIconIsOrionPlus = false;
    DefaultFontFamily = "Times New Roman";
    DefaultSearchEngine = "Kagi";
    HomePageURL = "https://kagi.com/";
    HyperlinkAuditingEnabled = false;
    NetworkPredictionEnabled = false;
    NotificationsEnabled = false;
    PasswordProvider = "none";
    QuitWithConfirmation = false;
    SUAutomaticallyUpdate = false;
    SUEnableAutomaticChecks = false;
    ShowBackgroundImageOnStartPage = false;
    ShowFavoritesOnStartPage = true;
    ShowRecommendationsOnStartPage = false;
    SyncEnabled = true;
    TabStyle = "treeStyle";
    UniversalSummaryFont = "SF Pro";
    UniversalSummaryFontSize = 12;
    UseTabSwitcherUI = true;
    WebAutomaticDashSubstitutionEnabled = false;
    WebAutomaticQuoteSubstitutionEnabled = false;
    WebAutomaticSpellingCorrectionEnabled = false;
    WebContinuousSpellCheckingEnabled = false;
    WebExtInstallPermission = "allowAll";
  };
in
{
  den.aspects.apps.orion.includes = [
    den.aspects.homebrew
    den.aspects.app-preferences
  ];

  den.aspects.apps.orion.darwin = {
    homebrew.casks = [ "orion" ];

    dotfiles.appPreferences.orion = {
      inherit domain preferences;
      processName = "Orion";
    };
  };

  den.aspects.apps.orion.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      dotfiles.orion.enable = lib.mkDefault true;

      home.activation.remindOrionExtensions = lib.mkIf config.dotfiles.orion.enable (
        config.lib.dag.entryAfter [ "linkGeneration" ] ''
          ${pkgs.python3}/bin/python3 ${./check-extensions.py} \
            ${./extensions.csv} \
            ${lib.escapeShellArg "${config.home.homeDirectory}/Library/Application Support/Orion/Defaults/Extensions"}
        ''
      );

      home.file."Library/Application Support/Orion/NativeMessagingHosts/org.keepassxc.keepassxc_browser.json" =
        lib.mkIf (config.dotfiles.orion.enable && config.dotfiles.keepassxc.enable) {
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
