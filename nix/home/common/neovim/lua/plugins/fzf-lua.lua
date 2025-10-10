require("fzf-lua").setup({ "ivy" })

vim.keymap.set("n", "<leader>f", "<CMD>FzfLua files<CR>")
vim.keymap.set("n", "<leader>b", "<CMD>FzfLua buffers<CR>")
vim.keymap.set("n", "<leader>g", "<CMD>FzfLua live_grep<CR>")
vim.keymap.set("n", "<leader>s", "<CMD>FzfLua lsp_document_symbols<CR>")
