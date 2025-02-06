#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Print with color
print_message() {
    echo -e "${WHITE}--- ${CYAN}$1 ${WHITE}---${NC}"
}

# Error handling
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS and package manager
detect_package_manager() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command_exists brew; then
            print_message "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error_exit "Failed to install Homebrew"
        fi
        echo "brew"
    elif command_exists apt-get; then
        echo "apt-get"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists pacman; then
        echo "pacman"
    else
        error_exit "No supported package manager found"
    fi
}

# Install dependencies based on OS
install_dependencies() {
    print_message "Installing dependencies"
    
    PKG_MANAGER=$(detect_package_manager)
    
    case $PKG_MANAGER in
        "brew")
            brew install neovim ripgrep fzf lazygit || error_exit "Failed to install dependencies"
            ;;
        "apt-get")
            sudo apt-get update
            sudo apt-get install -y neovim ripgrep fzf lazygit || error_exit "Failed to install dependencies"
            ;;
        "dnf")
            sudo dnf install -y neovim ripgrep fzf lazygit || error_exit "Failed to install dependencies"
            ;;
        "pacman")
            sudo pacman -Sy neovim ripgrep fzf lazygit || error_exit "Failed to install dependencies"
            ;;
    esac
}

# Setup Neovim configuration directories
setup_directories() {
    print_message "Setting up Neovim configuration directories"
    
    NVIM_CONFIG_DIR="$HOME/.config/nvim"
    NVIM_DATA_DIR="$HOME/.local/share/nvim"
    
    # Backup existing configuration
    if [ -d "$NVIM_CONFIG_DIR" ]; then
        mv "$NVIM_CONFIG_DIR" "${NVIM_CONFIG_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create necessary directories
    mkdir -p "$NVIM_CONFIG_DIR"
    mkdir -p "$NVIM_DATA_DIR"
}

# Install Packer (plugin manager)
install_packer() {
    print_message "Installing Packer.nvim"
    
    PACKER_DIR="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
    
    if [ ! -d "$PACKER_DIR" ]; then
        git clone --depth 1 https://github.com/wbthomason/packer.nvim "$PACKER_DIR" || error_exit "Failed to clone Packer"
    fi
}

# Copy configuration files
copy_config_files() {
    print_message "Copying configuration files"
    
    # Get the script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Create nvim config directory if it doesn't exist
    mkdir -p "$HOME/.config/nvim"
    
    # Symlink all Lua files and directories
    ln -s "$SCRIPT_DIR/nvim-config/init.lua" "$HOME/.config/nvim/" || error_exit "Failed to link init.lua"
    ln -s "$SCRIPT_DIR/nvim-config/lua" "$HOME/.config/nvim/" || error_exit "Failed to link lua directory"
        
    # Verify the copy
    if [ ! "$(ls -A "$HOME/.config/nvim")" ]; then
        error_exit "Failed to copy configuration files - destination directory is empty"
    fi
    
    print_message "Configuration files copied successfully"
}

# Install plugins
install_plugins() {
    print_message "Installing Neovim plugins"
    
    # Install plugins headlessly
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' || error_exit "Failed to install plugins"
    
    # Compile packer
    nvim --headless -c 'PackerCompile' -c 'q' || error_exit "Failed to compile plugins"
}

# Main installation process
main() {
    print_message "Starting Neovim configuration installation"
    
    install_dependencies
    setup_directories
    install_packer
    copy_config_files
    install_plugins
    
    print_message "Installation complete! 🎉"
    echo -e "${GREEN}Please restart your terminal and run 'nvim' to start using your new setup.${NC}"
}

# Run the installer
main
