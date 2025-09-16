{pkgs, ...}: {
  home.file = {
    ".config/waybar".source = ./waybar;
  };

  home.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };
}
