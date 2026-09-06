vim.b.prose_wrap = true
vim.wo[0][0].wrap = true
vim.wo[0][0].linebreak = true
if require("my.features").editing then
  vim.b.img_clip_template = [[
#image("$FILE_PATH")
      ]]
end
vim.b.undo_ftplugin = (vim.b.undo_ftplugin and (vim.b.undo_ftplugin .. " | ") or "")
  .. "unlet! b:prose_wrap b:img_clip_template | setlocal wrap< linebreak<"
