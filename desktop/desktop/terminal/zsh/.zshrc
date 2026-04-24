# Starship prompt
eval "$(starship init zsh)"

# Aliases
alias ll="ls -la"
alias gs="git status"
alias gp="git pull"
alias ..="cd .."

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
