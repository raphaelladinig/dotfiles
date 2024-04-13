vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.termguicolors = true
vim.opt.wrap = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.scrolloff = 10
vim.opt.updatetime = 50
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 0
vim.opt.showmode = false
vim.opt.mouse = "a"
vim.opt.mousemodel = "extend"
vim.opt.virtualedit = "block"
vim.opt.ignorecase = true
vim.opt.spelllang = "en,de"

vim.cmd[[
augroup CursorLine
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
augroup END
]]
