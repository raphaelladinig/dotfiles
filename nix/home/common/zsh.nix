{
  pkgs,
  hostSpec,
  config,
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
      alias t="tmux"

      export nnn_opts="quai"
      export nnn_bms="d:$home/downloads;d:$home/documents/;m:/run/media"
      export nnn_colors="4444"
      blk="0b" chr="0b" dir="04" exe="01" reg="00" hardlink="02" symlink="02" missing="08" orphan="09" fifo="02" sock="0b" other="06"
      export nnn_fcolors="$blk$chr$dir$exe$reg$hardlink$symlink$missing$orphan$fifo$sock$other"
      source ${pkgs.nnn}/share/quitcd/quitcd.bash_sh_zsh

      eval "$(direnv hook zsh)"

      export GEMINI_API_KEY=$(cat ${config.sops.secrets.GEMINI_API_KEY.path})
      export EDITOR=nvim
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
