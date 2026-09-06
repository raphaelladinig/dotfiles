vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.no_plugin_maps = true
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.o.clipboard = "unnamedplus"
vim.o.wrap = false
vim.o.linebreak = false

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("my.wrapping", {}),
  callback = function()
    local prose = vim.b.prose_wrap == true
    vim.wo[0][0].wrap = prose
    vim.wo[0][0].linebreak = prose
  end,
})

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
vim.o.swapfile = false

vim.opt.title = true
vim.opt.shortmess:append("I")
vim.opt.autoread = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

vim.diagnostic.config({ virtual_text = true })

local exrc_root = vim.fs.root(vim.fn.getcwd(), ".nvim")
if exrc_root then
  local exrc_dir = exrc_root .. "/.nvim"
  if vim.secure.read(exrc_dir) then
    vim.opt.runtimepath:append(exrc_dir)
    local exrc = exrc_dir .. "/init.lua"
    if vim.uv.fs_stat(exrc) then
      assert(loadfile(exrc))()
    end
  end
end
