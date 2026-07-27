-- Git mergetool only: no packer / opt plugins — avoids extra splits from your full init.
vim.opt.loadplugins = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.cmd("filetype on")
vim.cmd("syntax on")

dofile(vim.fn.expand("~/.dotfiles/vim/nvim-config/lua/settings.lua"))
dofile(vim.fn.expand("~/.dotfiles/vim/nvim-config/lua/keymap.lua"))

-- Colorscheme: try catppuccin from packer's install path, fall back to built-in
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/site/pack/packer/start/catppuccin")
local ok = pcall(vim.cmd.colorscheme, "catppuccin")
if not ok then
  vim.cmd.colorscheme("habamax")
end
