set -g fish_greeting ""

function fish_title
end

alias l 'eza --icons'
alias ls 'eza --icons'
alias ll 'eza -l --icons --git --group-directories-first'
alias la 'eza -la --icons --git --group-directories-first'
alias lt 'eza --tree --level=2 --icons'

zoxide init fish | source
direnv hook fish | source

# bun
set --export BUN_INSTALL "$HOME/.bun"
fish_add_path --global "$BUN_INSTALL/bin"
