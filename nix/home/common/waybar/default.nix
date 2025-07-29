{
  pkgs,
  hostSpec,
  ...
}: {
  home.file = {
    ".config/waybar".source = ./${hostSpec.hostName};
  };

  home.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };
}
