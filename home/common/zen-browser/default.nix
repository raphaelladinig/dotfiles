{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.zen-browser.homeModules.default
  ];

  programs.zen-browser = {
    enable = true;
    nativeMessagingHosts = [pkgs.firefoxpwa];
    policies = {
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      PromptForDownloadLocation = true;
      TranslateEnabled = false;
      NoDefaultBookmarks = true;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;
      AppAutoUpdate = false;
      ExtensionSettings = {
        "*".installation_mode = "blocked";
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
      };
      Containers = {
        Default = [
        ];
      };
    };
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        search = {
          force = true;
          default = "ddg";
        };
      };
    };
  };

  home.file = {
    ".zen/default/user.js".source = ./user.js;
  };
}
