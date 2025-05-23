#!/bin/bash

# ALIASES
# #######

# List
alias  l='ls -FG'
alias la='ls -FGalh'
alias ll='ls -FG1'
alias rm='echo "This is not the command you are looking for. Try \`del <path-to-dir-or-file>\` to use trash-cli"; false'

# Directories
alias      _cd="z"
alias dotfiles="_cd $dotfiles"

# Lock Screen
alias lockscreen='pmset displaysleepnow'

# Reload settings or hardware
alias reload!="source $HOME/.zshrc"
alias reload="echo 'Use \"reload!\" instead'"
alias reload-wifi='sudo iwlist wlp3s0 scan'
alias reload-audio='sudo killall coreaudiod'
alias reload-touchbar="sudo pkill TouchBarServer && sudo killall ControlStrip && sudo pkill NowPlayingTouchUI"

# Networking
alias sshproxy='echo "Starting proxy server on port 5555..."; ssh -qTnN -D 5555'
alias pubip='curl ipv4.icanhazip.com'
alias myip="ifconfig | grep inet | grep -vE '(inet6|127.0.0.1)' | awk '{print $2}' | awk -F ':' '{print $2}'"
alias mymac='ifconfig en0 | grep ether'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# Random
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,node_modules,deps} -i --color'

# Applications
alias brave='open -a "Brave Browser"'
alias brave_new='open -na "Brave Browser" --args --new-window'
alias chrome='open -a "Google Chrome"'
alias chrome_new='open -na "Google Chrome" --args --new-window'
alias firefox='open -a "Firefox Developer Edition"'
alias firefox_new='open -na "Firefox Developer Edition" --args --new-window'
alias settings='open -a "System Settings"'
alias slack='open -a Slack'

# Make sudo work with aliases
alias sudo='sudo '

# Git
alias git=hub


