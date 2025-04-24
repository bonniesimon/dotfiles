# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git ruby rails yarn bundler docker docker-compose z node zsh-autosuggestions zsh-syntax-highlighting)

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# Custom Aliases

alias lla="ls -lGAF"
alias gs="git status --show-stash --long"
alias rails="bundle exec rails"
alias glogl="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --branches"
alias tmux="TERM=xterm-256color tmux"
alias tf="terraform"

# [Depreciated] use 'or' instead
alias ovmr="overmind restart"
# [Depreciated] use 'oc' instead
alias ovmc="overmind connect"

alias oc="overmind connect"
alias or="overmind restart"

alias lock="cinnamon-screensaver-command -l"



ghissue() {
  gh issue develop $1 -n "$1-$2" -b "main" -c
}

# This will checkout main, update it, create a release branch,
# create a PR and then open it in the browser.
release() {
  gco main
  gpr
  gco -b $(date '+release-%Y-%m-%d')
  ggp
  gh pr create --fill --base production --title "$(date '+Release %Y-%m-%d')"
  gh pr view --web
}

# This will checkout production, update it, This will merge
# the release branch to production and then push it to remote.
deploy() {
  gco production
  gpr
  git merge $(date '+release-%Y-%m-%d')
  ggp --no-verify
  gbD $(date "+release-%Y-%m-%d")
}

reset_dev() {
  rails db:drop db:create && rake db:schema:load && rake db:migrate:with_data && redis-cli FLUSHDB && redis-cli FLUSHALL && rails log:clear tmp:clear

  echo "========================= Starting seeding =========================\n"
  rake db:seed --trace
}

gdev() {
  if [ -z "$1" ]; then
    echo "Usage: gdev <linear_branch_name>"
    return 1
  fi

  current_branch=$(git rev-parse --abbrev-ref HEAD)

  if [[ "$current_branch" != "development" && "$current_branch" != "master" && ! "$current_branch" =~ ^release/v[0-9]+\.* ]]; then
    echo "Error: You must be on the 'development' branch or a 'release/v**' branch or master branch to create a new branch."
    return 1
  fi

  # Check if the branch already exists locally
  if git rev-parse --verify "$1" > /dev/null 2>&1; then
    echo "Branch $1 already exists locally. Not creating a new one."
    return 1
  fi

  git checkout -b "$1"
  if [ $? -ne 0 ]; then
    echo "Failed to create branch $1"
    return 1
  fi

  # Check if the branch already exists on the remote
  if git ls-remote --exit-code --heads origin "$1" > /dev/null; then
    echo "Branch $1 already exists on the remote. Not pushing."
    return 1
  fi

  git push -u origin "$1"
  if [ $? -ne 0 ]; then
    echo "Failed to push branch $1 to origin"
    return 1
  fi
}

function ovm() {
    local procfile="Procfile.dev"
    local minimal_services="web,worker,css,js,searchkick_worker"
    local config_target="/Users/bonstine/dev/bigbinary/rootlyhq/rootly/ngrok.yml"
    local config_minimal="/Users/bonstine/dev/bigbinary/rootlyhq/ngrok-configs/ngrok-minimal.yml"
    local config_full="/Users/bonstine/dev/bigbinary/rootlyhq/ngrok-configs/ngrok.yml"

    # Function to print colored logs
    log() {
        local blue='\033[0;34m'
        local nc='\033[0m' # No Color
        echo -e "${blue}[ov]${nc} $1"
    }

    # Handle help before passing to overmind
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo "Usage: ovm [options]"
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo "  -m            Run with minimal services ($minimal_services)"
        echo "  [any]         Any other flags are passed directly to overmind"
        echo
        echo "Examples:"
        echo "  ovm           # runs: overmind start -f $procfile"
        echo "  ovm -m        # runs: overmind start -f $procfile -l $minimal_services"
        echo "  ovm -f other  # runs: overmind start -f $procfile -f other"
        return 0
    elif [[ "$1" == "-m" ]]; then
        log "Starting in minimal mode..."
        log "Copying minimal config: $config_minimal -> $config_target"
        cp "$config_minimal" "$config_target"
        log "Starting overmind with minimal services: $minimal_services"
        overmind start -f "$procfile" -l "$minimal_services"
    else
        log "Starting in full mode..."
        log "Copying full config: $config_full -> $config_target"
        cp "$config_full" "$config_target"
        log "Starting overmind with all services"
        overmind start -f "$procfile" -x skyla_worker "$@"
    fi
}

# Application Aliases
# alias tunnelto="/Applications/tunnelto"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# To make redis work with sidekiq for granite
# export REDIS_URL="redis://127.0.0.1:6379/12"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Bindings to move word in iterm
# bindkey "[D" backward-word
# bindkey "[C" forward-word
# bindkey "^[a" beginning-of-line
# bindkey "^[e" end-of-line

# Fix issue with ruby https://github.com/rails/rails/issues/38560
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export DISABLE_SPRING=true

# Fix tmux not showing prompt icons
alias tmux="TERM=xterm-256color tmux"


# Fix autosuggest text color is not faded enough: https://stackoverflow.com/questions/47310537/how-to-change-zsh-autosuggestions-color
AUTOSUGGESTION_HIGHLIGHT_COLOR='fg=250'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'

# New autocomplete of zsh
autoload -U +X bashcompinit && bashcompinit

# Adding to $PATH
# zoxide
export PATH="$PATH:$HOME/.local/bin"
# rbenv
export PATH="$PATH:$HOME/.rbenv/bin"
# nvim appimage to /opt/nvim/nvim
export PATH="$PATH:/opt/nvim/"
# golang
export PATH="$PATH:/usr/local/go/bin"
# overmind
export PATH="$PATH:$HOME/go/bin"


eval "$(zoxide init zsh)"

# Added by `rbenv init` on Friday 04 April 2025 09:23:58 PM IST
eval "$(rbenv init - --no-rehash zsh)"
