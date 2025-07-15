#!/bin/bash

# LINUX-SPECIFIC ZSHRC MODIFICATIONS
# ##################################
# This file contains the changes needed for .zshrc to work on Linux

# 1. Amazon Q paths - Linux uses different location
if [[ "$(uname -s)" == "Linux" ]]; then
    # Amazon Q pre block for Linux
    [[ -f "${HOME}/.config/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/.config/amazon-q/shell/zshrc.pre.zsh"
    
    # Override Homebrew setup for Linux package managers
    unset BREW_COMMAND
    
    # Linux doesn't have /opt/homebrew, so we need different PATH handling
    export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"
    
    # trash-cli path is different on Linux
    if command -v trash-put >/dev/null 2>&1; then
        # Most Linux distros put trash-cli in standard PATH
        export PATH="$PATH"
    fi
    
    # iTerm2 integration doesn't exist on Linux
    # test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
    
    # Amazon Q post block for Linux
    [[ -f "${HOME}/.config/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/.config/amazon-q/shell/zshrc.post.zsh"
fi
