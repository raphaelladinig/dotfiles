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
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      OfferToSaveLogins = false;
      NoDefaultBookmarks = false;
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
        settings = {
          "browser.shell.checkDefaultBrowser" = false;
          "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
          "browser.newtabpage.enabled" = false;
          "browser.search.separatePrivateDefault" = false;
          "browser.toolbars.bookmarks.visibility" = "always";
          "zen.tabs.show-newtab-vertical" = false;
          "zen.tabs.vertical.right-side" = true;
          "zen.themes.updated-value-observer" = true;
          "zen.view.compact.toolbar-flash-popup" = false;
          "zen.view.compact.hide-tabbar" = true;
          "zen.view.compact.hide-toolbar" = true;
          "zen.view.use-single-toolbar" = false;
          "zen.welcome-screen.seen" = true;
          "zen.pinned-tab-manager.restore-pinned-tabs-to-pinned-url" = true;
          "layout.spellcheckDefault" = 0;
          "browser.uiCustomization.state" = "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"ublock0_raymondhill_net-browser-action\",\"_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action\"],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"vertical-spacer\",\"urlbar-container\",\"unified-extensions-button\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"tabbrowser-tabs\"],\"vertical-tabs\":[],\"PersonalToolbar\":[\"personal-bookmarks\"],\"zen-sidebar-top-buttons\":[],\"zen-sidebar-foot-buttons\":[\"downloads-button\",\"zen-workspaces-button\",\"zen-create-new-button\"]},\"seen\":[\"ublock0_raymondhill_net-browser-action\",\"developer-button\",\"_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action\"],\"dirtyAreaCache\":[\"unified-extensions-area\",\"nav-bar\",\"vertical-tabs\",\"zen-sidebar-foot-buttons\",\"PersonalToolbar\",\"toolbar-menubar\",\"TabsToolbar\"],\"currentVersion\":22,\"newElementCount\":4}";
        };
        bookmarks = {
          force = true;
          settings = [
            {
              toolbar = true;
              bookmarks = [
                {
                  name = "gemini";
                  url = "https://gemini.google.com";
                }
                {
                  name = "gmail";
                  url = "https://mail.google.com";
                }
                {
                  name = "github";
                  url = "https://github.com";
                }
                {
                  name = "misc";
                  bookmarks = [
                    {
                      name = "hetzner";
                      url = "https://accounts.hetzner.com";
                    }
                    {
                      name = "raphaelladinig";
                      url = "https://raphaelladinig.com";
                    }
                  ];
                }
                {
                  name = "school";
                  bookmarks = [
                    {
                      name = "teams";
                      url = "https://teams.microsoft.com";
                    }
                    {
                      name = "portal-tirol";
                      url = "https://portal.tirol.gv.at";
                    }
                    {
                      name = "digi4school";
                      url = "https://digi4school.at";
                    }
                    {
                      name = "moodle";
                      url = "https://moodle2.htlinn.ac.at";
                    }
                    {
                      name = "untis";
                      url = "https://neilo.webuntis.com";
                    }
                    {
                      name = "htlinn";
                      url = "https://cloud.htlinn.ac.at";
                    }
                    {
                      name = "letto";
                      url = "https://letto.htlinn.ac.at";
                    }
                  ];
                }
              ];
            }
          ];
        };
      };
    };
  };
}
