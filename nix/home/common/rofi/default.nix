{pkgs, ...}: {
  home.file = {
    ".config/rofi".source = ./rofi;
  };

  home.packages = with pkgs; [
    rofi
  ];
}
