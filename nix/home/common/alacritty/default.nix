{pkgs, ...}: {
  home.file = {
    ".config/alacritty".source = ./alacritty;
  };

  home.packages = with pkgs; [
    alacritty
    nerd-fonts.caskaydia-cove
  ];
}
