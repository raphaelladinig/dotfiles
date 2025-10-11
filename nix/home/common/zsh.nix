{
  pkgs,
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
      alias j="just"

      eval "$(direnv hook zsh)"

      export EDITOR=nvim
    '';
  };

  imports = [
    ./starship
    ./lazygit
    ./neovim
    ./btop
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  home.packages = with pkgs; [
    fzf
    zoxide
  ];
}
