#!/bin/bash

# ALIASES
# #######

# Platform detection
is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

# List - platform specific
if is_macos; then
    alias  l='ls -FG'
    alias la='ls -FGalh'
    alias ll='ls -FG1'
else
    alias  l='ls -F --color=auto'
    alias la='ls -Falh --color=auto'
    alias ll='ls -F1 --color=auto'
fi

alias rm='echo "This is not the command you are looking for. Try \`del <path-to-dir-or-file>\` to use trash-cli"; false'

# Directories
alias      _cd="z"
alias dotfiles="_cd $dotfiles"

# Lock Screen - platform specific
if is_macos; then
    alias lockscreen='pmset displaysleepnow'
else
    if command -v gnome-screensaver-command >/dev/null 2>&1; then
        alias lockscreen='gnome-screensaver-command -l'
    elif command -v xdg-screensaver >/dev/null 2>&1; then
        alias lockscreen='xdg-screensaver lock'
    elif command -v loginctl >/dev/null 2>&1; then
        alias lockscreen='loginctl lock-session'
    else
        alias lockscreen='echo "No screen lock command found for this Linux distribution"'
    fi
fi

# Reload settings or hardware
alias reload!="source $HOME/.zshrc"
alias reload="echo 'Use \"reload!\" instead'"

# Platform-specific reload commands
if is_macos; then
    alias reload-wifi='sudo iwlist wlp3s0 scan'
    alias reload-audio='sudo killall coreaudiod'
    alias reload-touchbar="sudo pkill TouchBarServer && sudo killall ControlStrip && sudo pkill NowPlayingTouchUI"
else
    alias reload-wifi='sudo systemctl restart NetworkManager'
    alias reload-audio='pulseaudio -k && pulseaudio --start'
    # No touchbar on Linux
fi

# Networking - platform specific
alias sshproxy='echo "Starting proxy server on port 5555..."; ssh -qTnN -D 5555'
alias pubip='curl ipv4.icanhazip.com'

if is_macos; then
    alias myip="ifconfig | grep inet | grep -vE '(inet6|127.0.0.1)' | awk '{print \$2}' | awk -F ':' '{print \$2}'"
    alias mymac='ifconfig en0 | grep ether'
    alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
else
    alias myip="ip route get 1.1.1.1 | grep -oP 'src \K\S+'"
    alias mymac='ip link show | grep ether'
    alias flushdns='sudo systemctl flush-dns || sudo systemd-resolve --flush-caches'
fi

# Random
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,node_modules,deps} -i --color'

# Applications - platform specific
if is_macos; then
    alias brave='open -a "Brave Browser"'
    alias brave_new='open -na "Brave Browser" --args --new-window'
    alias chrome='open -a "Google Chrome"'
    alias chrome_new='open -na "Google Chrome" --args --new-window'
    alias firefox='open -a "Firefox Developer Edition"'
    alias firefox_new='open -na "Firefox Developer Edition" --args --new-window'
    alias settings='open -a "System Settings"'
    alias slack='open -a Slack'
# Not using in a Linux GUI at the moment, so let's leave this alone...
# else
#     # Linux alternatives
#     alias brave='xdg-open --browser brave-browser'
#     alias brave_new='brave-browser --new-window'
#     alias chrome='xdg-open --browser google-chrome'
#     alias chrome_new='google-chrome --new-window'
#     alias firefox='xdg-open --browser firefox'
#     alias firefox_new='firefox --new-window'
    
#     # System settings (Linux alternatives)
#     if command -v gnome-control-center >/dev/null 2>&1; then
#         alias settings='gnome-control-center'
#     elif command -v systemsettings5 >/dev/null 2>&1; then
#         alias settings='systemsettings5'
#     elif command -v unity-control-center >/dev/null 2>&1; then
#         alias settings='unity-control-center'
#     else
#         alias settings='echo "No system settings GUI found"'
#     fi
    
#     # Slack
#     if command -v slack >/dev/null 2>&1; then
#         alias slack='slack'
#     elif command -v flatpak >/dev/null 2>&1 && flatpak list | grep -q com.slack.Slack; then
#         alias slack='flatpak run com.slack.Slack'
#     else
#         alias slack='echo "Slack not found - install via snap, flatpak, or package manager"'
#     fi
fi

# Make sudo work with aliases
alias sudo='sudo '

# Git
if command -v hub >/dev/null 2>&1; then
    alias git=hub
fi