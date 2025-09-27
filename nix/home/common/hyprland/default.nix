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
    ".config/hypr/hyprsunset.conf".source = ./hypr/hyprsunset.conf;
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
    ../alacritty
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
    hyprsunset.enable = true;
    hypridle.enable = true;
  };

  programs.hyprlock.enable = true;
}
