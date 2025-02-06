# JDG Dotfiles
My dotfiles and configs

Inspired by [Sheharyar Naseer](https://github.com/sheharyarn/dotfiles) and [Kent C. Dodds](https://github.com/kentcdodds/dotfiles).

## Quickstart
### If setting up a new machine
- Run the following, and the script should handle everything
```shell
curl https://raw.githubusercontent.com/joshuagraber/dotfiles/HEAD/.macos | bash
```

### If adding to an existing machine
- Clone the repository into `~/.dotfiles`
```shell
git clone https://github.com/joshuagraber/dotfiles ~/.dotfiles
```

- Pick and choose setup for particular dotfiles: 

zsh: 
```shell
brew install zsh
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
ln -s "${HOME}/.dotfiles/zsh/.zshrc" "${HOME}/.zshrc"
ln -s "${HOME}/.dotfiles/zsh/simple-load.sh" "${HOME}/.zshenv"
```
git
```shell
brew install git
mv ~/.gitconfig ~/.gitconfig_local
ln -s ~/.dotfiles/git/.gitconfig.global ~/.gitconfig
```
vim
```shell
brew install neovim
sudo bash ${HOME}/.dotfiles/vim/installer.sh
```
vlc
```shell
brew install --cask vlc
ln -s ~/.dotfiles/vlc/vlcrc ~/Library/Preferences/org.videolan.vlc/vlcrc
```

