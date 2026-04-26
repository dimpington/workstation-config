# Starship prompt
eval "$(starship init zsh)"

# Aliases
alias ll="ls -lah"
alias la="ls -A"
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias ..="cd .."
alias ...="cd ../.."

# Navigation
alias c="clear"
alias h="history"

# Git shortcuts
alias gcm="git commit -m"
alias gpl="git pull"
alias gco="git checkout"
alias gb="git branch"

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY

# Usability
setopt AUTO_CD
setopt CORRECT
