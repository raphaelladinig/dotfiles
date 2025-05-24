{pkgs, ...}: {
  home.file = {
    ".config/mpv".source = ./mpv;
  };

  home.packages = with pkgs; [mpv];
}
