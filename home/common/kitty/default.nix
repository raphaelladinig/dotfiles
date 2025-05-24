{pkgs, ...}: {
  home.file = {
    ".config/kitty".source = ./kitty;
  };

  home.packages = with pkgs; [
    kitty
    nerd-fonts.caskaydia-cove
  ];
}
