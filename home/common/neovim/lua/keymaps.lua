vim.keymap.set("i", "jj", "<ESC>")

vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition)
vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration)
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references)
vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>h", vim.lsp.buf.hover)

vim.keymap.set("n", "<leader>eh", function()
  vim.diagnostic.open_float()
end)
vim.keymap.set("n", "<leader>eq", vim.diagnostic.setloclist)
vim.keymap.set("n", "<leader>ge", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<leader>gE", vim.diagnostic.goto_next)

vim.keymap.set("v", "<space>x", ":lua<CR>")
vim.keymap.set("n", "<space>x", ":.lua<CR>")
