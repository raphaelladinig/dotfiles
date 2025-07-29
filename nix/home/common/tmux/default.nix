{pkgs, ...}: {
  home.file = {
    ".config/tmux/tmux.conf".source = ./tmux.conf;
  };

  home.packages = with pkgs; [
    tmux
  ];
}
