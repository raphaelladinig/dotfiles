{pkgs, ...}: {
  home.file = {
    ".config/mako".source = ./mako;
  };

  home.packages = with pkgs; [
    mako
    nerd-fonts.caskaydia-cove
    libnotify
  ];
}
