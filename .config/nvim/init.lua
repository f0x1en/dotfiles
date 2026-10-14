vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.termguicolors = true
vim.cmd.colorscheme("campbell")

require("config.options")
require("config.lazy")
require("config.keymaps")
