#!/bin/zsh
# Paths and Variables
export ZSH=$HOME/.oh-my-zsh
local dotfiles=$HOME/.dotfiles
export DOTFILES=$dotfiles
export ZSH_CUSTOM=$DOTFILES/zsh/custom
export XDG_CONFIG_HOME=$HOME/.config
export PATH=/usr/local/bin:$PATH
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
## terraform env mgr
PATH="$HOME/.tfenv/bin:$PATH"
## trash-cli
PATH="/opt/homebrew/opt/trash-cli/bin:$PATH"


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


# Load Homebrew (macOS only)
if [[ "$(uname -s)" == "Darwin" ]]; then
    export BREW_COMMAND="/opt/homebrew/bin/brew"
    [[ -s "$BREW_COMMAND" ]] && eval "$($BREW_COMMAND shellenv)"
fi


# Enable iTerm2 Shell Integration (macOS only)
if [[ "$(uname -s)" == "Darwin" ]]; then
    test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi


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
