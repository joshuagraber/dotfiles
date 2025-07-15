#!/bin/bash

# LINUX-SPECIFIC ALIASES
# ######################

# Override macOS-specific aliases when on Linux
if [[ "$(uname -s)" == "Linux" ]]; then
    
    # List (use --color instead of -G)
    alias  l='ls -F --color=auto'
    alias la='ls -Falh --color=auto'
    alias ll='ls -F1 --color=auto'
    
    # Lock Screen (Linux alternatives)
    if command -v gnome-screensaver-command >/dev/null 2>&1; then
        alias lockscreen='gnome-screensaver-command -l'
    elif command -v xdg-screensaver >/dev/null 2>&1; then
        alias lockscreen='xdg-screensaver lock'
    elif command -v loginctl >/dev/null 2>&1; then
        alias lockscreen='loginctl lock-session'
    else
        alias lockscreen='echo "No screen lock command found for this Linux distribution"'
    fi
    
    # Reload settings or hardware (Linux alternatives)
    alias reload-wifi='sudo systemctl restart NetworkManager'
    alias reload-audio='pulseaudio -k && pulseaudio --start'
    unalias reload-touchbar 2>/dev/null  # Remove macOS-specific alias
    
    # Networking (Linux alternatives)
    alias myip="ip route get 1.1.1.1 | grep -oP 'src \K\S+'"
    alias mymac='ip link show | grep ether'
    alias flushdns='sudo systemctl flush-dns || sudo systemd-resolve --flush-caches'
    
    # Applications (Linux alternatives using xdg-open)
    alias brave='xdg-open --browser brave-browser'
    alias brave_new='brave-browser --new-window'
    alias chrome='xdg-open --browser google-chrome'
    alias chrome_new='google-chrome --new-window'
    alias firefox='xdg-open --browser firefox'
    alias firefox_new='firefox --new-window'
    
    # System settings (Linux alternatives)
    if command -v gnome-control-center >/dev/null 2>&1; then
        alias settings='gnome-control-center'
    elif command -v systemsettings5 >/dev/null 2>&1; then
        alias settings='systemsettings5'
    elif command -v unity-control-center >/dev/null 2>&1; then
        alias settings='unity-control-center'
    else
        alias settings='echo "No system settings GUI found"'
    fi
    
    # Slack
    if command -v slack >/dev/null 2>&1; then
        alias slack='slack'
    elif command -v flatpak >/dev/null 2>&1 && flatpak list | grep -q com.slack.Slack; then
        alias slack='flatpak run com.slack.Slack'
    else
        alias slack='echo "Slack not found - install via snap, flatpak, or package manager"'
    fi
    
fi
