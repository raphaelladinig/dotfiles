vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.markdown_recommended_style = 0

vim.o.exrc = true
vim.o.clipboard = "unnamedplus"
vim.o.wrap = false
vim.o.termguicolors = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.hlsearch = false
vim.o.incsearch = true
vim.o.scrolloff = 10
vim.o.updatetime = 50
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.shiftwidth = 0
vim.o.mouse = "a"
vim.o.mousemodel = "extend"
vim.o.virtualedit = "block"
vim.o.ignorecase = true
vim.o.signcolumn = "yes"
vim.opt.shortmess:append("I")

vim.diagnostic.config({ virtual_text = true })
