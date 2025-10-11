{
  pkgs,
  hostSpec,
  ...
}: {
  home.file = {
    ".config/hypr/hyprland.conf".source = ./hypr/hyprland.conf;
    ".config/hypr/vars.conf".source = ./hypr/vars.conf;
    ".config/hypr/binds.conf".source = ./hypr/binds.conf;
    ".config/hypr/hyprlock.conf".source = ./hypr/hyprlock.conf;
    ".config/hypr/hypridle.conf".source = ./hypr/hypridle.conf;
    ".config/hypr/host-specific.conf".source = ./hypr/${hostSpec.hostName}.conf;
  };

  home.packages = with pkgs; [
    bibata-cursors
    slurp
    grim
    brightnessctl
    cliphist
    wl-clipboard
    hyprpicker
  ];

  imports = [
    ../rofi
    ../mako
    ../kitty
    ../mpv
    ../wireplumber
    ../waybar
    ../zsh.nix
    ../gtk.nix
    ../qt.nix
    ../zen-browser.nix
  ];

  services = {
    hyprpolkitagent.enable = true;
    hypridle.enable = true;
  };

  programs.hyprlock.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = ["zen-beta.desktop"];
      "image/jpeg" = ["zen-beta.desktop"];
      "image/png" = ["zen-beta.desktop"];
      "image/gif" = ["zen-beta.desktop"];
      "image/webp" = ["zen-beta.desktop"];
      "image/svg+xml" = ["zen-beta.desktop"];
    };
  };
}
