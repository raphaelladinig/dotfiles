vim.wo.wrap = true
vim.wo.linebreak = true

if not package.loaded["plugins.typst-preview"] then
  require("plugins.typst-preview")
end
