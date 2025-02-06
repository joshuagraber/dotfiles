#!/bin/zsh

# Paths and Variables
export ZSH=$HOME/.oh-my-zsh
export dotfiles=$HOME/.dotfiles
export DOTFILES=$dotfiles
export ZSH_CUSTOM=$DOTFILES/zsh/custom
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/sbin:$PATH
## Deno
PATH="$HOME/.deno/bin:$PATH"
## Yarn
PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
# alias yarn="echo update the PATH in ~/.zshrc"
## node_modules 😆 this is *way* faster than using "npm prefix" and it works fine.
PATH="$PATH:./node_modules/.bin:../node_modules/.bin:../../node_modules/.bin:../../../node_modules/.bin:../../../../node_modules/.bin:../../../../../node_modules/.bin:../../../../../../node_modules/.bin:../../../../../../../node_modules/.bin"
## Custom bins
PATH="$PATH:$HOME/.bin:$HOME/.local/bin";
## dotfile bin
PATH="$PATH:$DOTFILES/.bin";

# Editor
export EDITOR="nvim"

# Language fix
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Search Configs (fzf/rg)
export IGNORED_DIRS="{.git,node_modules,dist,.cache,out}"
export RG_DEFAULT_FLAGS=(--no-ignore-vcs --hidden --follow --max-columns 150)
export RG_DEFAULT_ARGS=($RG_DEFAULT_FLAGS --glob "!**/$IGNORED_DIRS/*")
export FZF_DEFAULT_COMMAND="rg --files $RG_DEFAULT_FLAGS --glob '!**/$IGNORED_DIRS/*'"


# Geometry Theme Settings
export GEOMETRY_SYMBOL_PROMPT="▲"
export GEOMETRY_SYMBOL_EXIT_VALUE="▲"
export GEOMETRY_COLOR_EXIT_VALUE="yellow"
export GEOMETRY_PROMPT_PREFIX="\n\n"
export PROMPT_GEOMETRY_EXEC_TIME=true
export PROMPT_GEOMETRY_COMMAND_MAX_EXEC_TIME=0


# Zsh Settings
plugins=(z git gh nvm zsh-syntax-highlighting)
ZSH_THEME="geometry/geometry"
COMPLETION_WAITING_DOTS="true"


# Zsh History
# (Save History to Dropbox)
# export JDG_HISTORY_FILE="$HOME/Dropbox/System/.zsh_history"
# [[ -f $JDG_HISTORY_FILE ]] && export HISTFILE=$JDG_HISTORY_FILE

export HISTSIZE=50000
export SAVEHIST=$HISTSIZE
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY


# Load Oh-My-Zsh
source $ZSH/oh-my-zsh.sh


# Load Homebrew
export BREW_COMMAND="/opt/homebrew/bin/brew"
[[ -s "$BREW_COMMAND" ]] && eval "$($BREW_COMMAND shellenv)"


# Enable iTerm2 Shell Integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# NVM Configs
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"


# NVM auto-load
# Automatically run "nvm use" command when changing directory (https://gist.github.com/tcrammond/e52dfad4c2b36258f83f7a964af10097)
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc



# Load my .(z)sh files
typeset -U my_aliases
typeset -U my_functions
my_aliases=($DOTFILES/**/aliases.sh)
my_functions=($DOTFILES/**/functions.sh)
my_files=($my_aliases $my_functions)

for file in ${my_files} ; do
	source $file
done


# Load .localrc for SUPER SECRET STUFF (at the end)
[[ -a ~/.localrc ]] && source ~/.localrc

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
