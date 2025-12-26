##### POWERLEVEL10K INSTANT PROMPT (MUST BE FIRST) #####
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

##### ENVIRONMENT #####
export EDITOR="nvim"
export VISUAL="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export PATH="$HOME/.local/bin:$PATH"

##### HISTORY (PRIVACY + EFFICIENCY) #####
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=20000

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY

##### SAFETY #####
setopt NO_CLOBBER

##### OH MY ZSH #####
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  sudo
  zsh-autosuggestions
  history-substring-search
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

##### POWERLEVEL10K CONFIG #####
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Disable instant prompt to avoid fastfetch warning
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

##### ALIASES #####
alias ll='ls -la --color=auto'
alias gs='git status'
alias gp='git pull'
alias update='sudo dnf upgrade --refresh -y && flatpak update -y'
alias cls='clear'

##### FUNCTIONS #####
mkcd() { mkdir -p "$1" && cd "$1"; }

##### ASDF (QUIET) #####
[[ -f ~/.asdf/asdf.sh ]] && source ~/.asdf/asdf.sh >/dev/null 2>&1

##### DOTFILES GIT ALIAS #####
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

##### FASTFETCH (RUN ONCE AT LOGIN) #####
if command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi
# Git config for dotfiles management (if you're using it)
alias config='/usr/bin/git --git-dir=/home/briansmith/.dotfiles/ --work-tree=/home/briansmith'
