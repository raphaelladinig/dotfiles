require("oil").setup({
  view_options = {
    show_hidden = true,
  },
})

vim.keymap.set("n", "<leader><leader>", "<CMD>Oil<CR>")
