# Neovim Configuration Guide
## Installation Script ( installer.py)
One-time setup script

Installs dependencies (ripgrep, fzf, etc.)

Sets up Packer (plugin manager)

Installs initial plugins

Only needed for fresh installations

## Configuration Structure
```
.
├── nvim-config/
│   ├── init.lua            # Main entry point
│   └── lua/               # Configuration modules
│       ├── lsp/           # Language server and completion settings
│       └── plugins/       # Plugin configurations
│           ├── editor/    # Editor enhancement plugins (autopairs, surround, etc.)
│           ├── syntax/    # Syntax-related plugins (treesitter)
│           └── ui/        # User interface plugins (themes, statusline, etc.)
└── nvim.backup/          # Backup of previous configuration
```

## Making Changes
### Modify Core Settings (settings.lua)
Core Neovim settings can be found in `lua/settings.lua`. This file contains basic editor configurations like line numbers, indentation, and other fundamental settings.

### Add/Remove Plugins
Plugin management is handled in `lua/packer-config.lua`. To add or remove plugins:
1. Edit `packer-config.lua`
2. Add new plugins using `use` statements
3. For plugin-specific settings, add configuration files in:
   - `lua/plugins/editor/` for editing features
   - `lua/plugins/syntax/` for syntax-related plugins
   - `lua/plugins/ui/` for interface components

### Change Key Mappings
Keybindings are centralized in `lua/keymap.lua`. Modify this file to:
- Add new key mappings
- Change existing shortcuts
- Remove unwanted bindings

### Applying Changes
1. Save the file
2. Either:
   - Reload Neovim ( :source % if editing current file)
   - Or quit and restart Neovim
3. For new plugins:
4. Run :PackerSync
5. Wait for installation
6. Run :PackerCompile

## Common Customization Areas
### Change Theme
UI themes and visual settings can be modified in:
- `lua/visual.lua` for general visual settings
- `lua/plugins/ui/` for specific UI component configurations
- Look for relevant theme files like `darkman.lua` or modify statusline settings in `feline.lua`

### LSP Settings
Language Server Protocol settings are managed in the `lua/lsp/` directory:
- `init.lua` for general LSP configuration
- `cmp.lua` for completion settings
- Add or modify language servers and their specific settings here

### Custom Functions
Custom functionality can be added in several places:
- `lua/autocommands.lua` for automatic actions
- `lua/utils.lua` if it exists, for utility functions
- Create new files in appropriate subdirectories of `lua/plugins/` for plugin-specific customizations
## Debugging
- Check :checkhealth in Neovim
- Look at :messages for errors
- Use print() for debugging Lua code
- Check :lua print(vim.inspect(variable)) to inspect variables

## Reloading Configuration
### Without Restarting
```lua
:source %          " Reload current file
:source $MYVIMRC   " Reload entire configuration
```

### For Plugin Changes
```lua
:PackerSync    " When adding/removing plugins
:PackerCompile " After syncing
```
