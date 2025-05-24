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
    ../mako
    ../alacritty
    ../mpv
    ../zsh.nix
    ../gtk.nix
    ../qt.nix
    ../zen-browser.nix
    ../wireplumber
    ../waybar
  ];

  services = {
    hyprpolkitagent.enable = true;
    hyprsunset.enable = true;
  };

  programs.hyprlock.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = ["zen-beta.desktop"];
    };
  };
}
