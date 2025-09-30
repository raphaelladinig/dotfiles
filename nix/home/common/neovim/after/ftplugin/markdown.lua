vim.wo.wrap = true
vim.wo.linebreak = true

if not package.loaded["plugins.render-markdown"] then
  require("plugins.render-markdown")
end
