{ den, ... }:
{
  den.aspects.users.raphaelladinig = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      den.aspects.homebrew
      den.aspects.apps.alcove
      den.aspects.apps.cmux
      den.aspects.apps.git
      den.aspects.apps.helium
      den.aspects.apps.keepassxc
      den.aspects.apps.lazygit
      den.aspects.apps.neovim
      den.aspects.apps.fish
      den.aspects.ai.agents-md
      den.aspects.ai.skills
      den.aspects.fonts
    ];

    darwin.homebrew.casks = [
      "affinity"
      "claude"
      "claude-code@latest"
      "chatgpt"
      "codex"
      "colemak-dh"
      "hammerspoon"
      "hyperkey"
      "linearmouse"
      "middledrag"
      "obs"
      "petrichor"
      "soulseek"
      "tailscale-app"
      "vicinae"
      "wispr-flow"
      "equinox"
      "t3-code@nightly"
      "istat-menus"
      "finetune"
      "libreoffice"
    ];

    darwin.homebrew.masApps = {
      "Brother iPrint&Scan" = 1193539993;
      "Xcode" = 497799835;
    };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          anki-bin
          betterdisplay
          btop
          fastfetch
          gh
          iina
          just
          nh
          shottr
          signal-desktop
          tokei
          typst
          vesktop
          whatsapp-for-mac
        ];
      };
  };
}
