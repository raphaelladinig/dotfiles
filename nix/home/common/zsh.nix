{
  pkgs,
  hostSpec,
  ...
}: {
  home.file = {
    ".zshrc".text = ''
      autoload -U compinit && compinit

      if [[ -f "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh" ]]; then
        source "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh"
      fi
      export ZSH_AUTOSUGGEST_MANUAL_REBIND
      if [[ -f "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
        source "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
      fi
      if [[ -f "${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh" ]]; then
        source "${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh"
      fi

      eval "$(starship init zsh)"

      HISTSIZE=10000
      HISTFILE=/persist/home/raphael/.zsh_history
      SAVEHIST=$HISTSIZE
      HISTDUP=erase
      setopt appendhistory
      setopt sharehistory
      setopt hist_ignore_space
      setopt hist_save_no_dups
      setopt hist_ignore_dups
      setopt hist_find_no_dups

      source <(fzf --zsh)
      eval "$(zoxide init zsh)"

      alias v="nvim"
      alias g="lazygit"

      function t {
        name=$(basename `pwd` | sed -e 's/\.//g')

        if tmux ls 2>&1 | grep "$name"; then
          tmux attach -t "$name"
        elif [ -f .envrc ]; then
          direnv exec / tmux new-session -s "$name"
        else
          tmux new-session -s "$name"
        fi
      }

      export NNN_OPTS="QUai"
      export NNN_BMS="d:$HOME/Downloads;D:$HOME/Documents/;m:/run/media"
      export NNN_COLORS="4444"
      BLK="0B" CHR="0B" DIR="04" EXE="01" REG="00" HARDLINK="02" SYMLINK="02" MISSING="08" ORPHAN="09" FIFO="02" SOCK="0B" OTHER="06"
      export NNN_FCOLORS="$BLK$CHR$DIR$EXE$REG$HARDLINK$SYMLINK$MISSING$ORPHAN$FIFO$SOCK$OTHER"
      n ()
      {
          [ "$\{NNNLVL:-0}" -eq 0 ] || {
              echo "nnn is already running"
              return
          }

          NNN_TMPFILE="$\{XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

          command nnn "$@"

          [ ! -f "$NNN_TMPFILE" ] || {
              . "$NNN_TMPFILE"
              rm -f -- "$NNN_TMPFILE" > /dev/null
          }
      }

      eval "$(direnv hook zsh)"
      
      export GEMINI_API_KEY=$(cat ~/.config/sops-nix/secrets/GEMINI_API_KEY)
    '';
  };

  imports = [
    ./starship
    ./lazygit
    ./neovim
    ./btop
    ./tmux
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    nnn.enable = true;
  };

  home.packages = with pkgs; [
    fzf
    zoxide
  ];

  sops.secrets.GEMINI_API_KEY.sopsFile = "${hostSpec.secretsPath}/GEMINI_API_KEY";
}
