{pkgs, ...}: {
  home.file = {
    ".config/tmux/tmux.conf".text = ''
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix

      set -g default-terminal "$TERM"
      set -ag terminal-overrides ",$TERM:Tc"
      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on
      set -g history-limit 50000
      set -g display-time 4000
      set -g status-interval 5
      set -g focus-events on
      setw -g clock-mode-style 24
      set -s escape-time 0
      setw -g aggressive-resize on
      set -g mouse on

      set -g status-right "#{=21:pane_title}"
      set -g status-left "#{?client_prefix,[1],[0]}[#{session_name}]"

      set -g status-keys vi
      set -g mode-keys vi
      bind k select-pane -U
      bind j select-pane -D
      bind h select-pane -L
      bind l select-pane -R

      bind p previous-window
      bind n next-window
      bind-key t run-shell "tmux display-popup -h 75% -w 75% -E $SHELL"
      bind-key g run-shell "tmux display-popup -h 75% -w 75% -E lazygit"
    '';
  };

  home.packages = with pkgs; [
    tmux
  ];
}
