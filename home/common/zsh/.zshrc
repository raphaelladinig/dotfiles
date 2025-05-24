# setup completions
autoload -U compinit && compinit

# plugins
if [[ -f "$HOME/.zsh/plugins/zsh-fast-syntax-highlighting/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh" ]]; then
  source "$HOME/.zsh/plugins/zsh-fast-syntax-highlighting/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh"
fi
export ZSH_AUTOSUGGEST_MANUAL_REBIND
if [[ -f "$HOME/.zsh/plugins/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.zsh/plugins/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [[ -f "$HOME/.zsh/plugins/zsh-fzf-tab/share/fzf-tab/fzf-tab.plugin.zsh" ]]; then
  source "$HOME/.zsh/plugins/zsh-fzf-tab/share/fzf-tab/fzf-tab.plugin.zsh"
fi

# starship
eval "$(starship init zsh)"

# history
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

# shell integrations
source <(fzf --zsh)
eval "$(zoxide init zsh)"

# aliases
alias v="nvim"
alias g="lazygit"

# nnn
export NNN_OPTS="QHUai"
export NNN_PLUG="p:preview-tui"
export NNN_BMS="d:$HOME/Downloads;D:$HOME/Documents/;m:/run/media"
export NNN_COLORS="4444"
BLK="0B" CHR="0B" DIR="04" EXE="01" REG="00" HARDLINK="02" SYMLINK="02" MISSING="08" ORPHAN="09" FIFO="02" SOCK="0B" OTHER="06"
export NNN_FCOLORS="$BLK$CHR$DIR$EXE$REG$HARDLINK$SYMLINK$MISSING$ORPHAN$FIFO$SOCK$OTHER"
n ()
{
    [ "${NNNLVL:-0}" -eq 0 ] || {
        echo "nnn is already running"
        return
    }

    NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd" 

    command nnn "$@"

    [ ! -f "$NNN_TMPFILE" ] || {
        . "$NNN_TMPFILE"
        rm -f -- "$NNN_TMPFILE" > /dev/null
    }
}

# direnv
eval "$(direnv hook zsh)"

# gemini
export GEMINI_API_KEY=$(cat ~/.config/agenix/GEMINI_API_KEY)
