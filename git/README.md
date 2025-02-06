
Git
===

## Installation

Make sure to install the latest git release:

```bash
$ brew install git
```

## Configuration

Load up my git configuration. It includes user.name and user.email defaults, my default global
`.gitignore` file and a few push settings:

```bash
mv ~/.gitconfig ~/.gitconfig_local
ln -s ~/.dotfiles/git/.gitconfig.global ~/.gitconfig
```
