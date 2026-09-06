vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local function setup()
  require("oil").setup({
    watch_for_changes = true,
    view_options = {
      show_hidden = true,
    },
  })

  require("fzf-lua").setup({ "ivy", fzf_colors = true })
  require("fzf-lua").register_ui_select()
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(setup)
  end,
})

vim.keymap.set("n", "<leader><leader>", "<CMD>Oil<CR>")

vim.keymap.set("n", "<leader>ff", "<CMD>FzfLua files<CR>")
vim.keymap.set("n", "<leader>fb", "<CMD>FzfLua buffers<CR>")
vim.keymap.set("n", "<leader>ft", "<CMD>FzfLua tabs<CR>")
vim.keymap.set("n", "<leader>fg", "<CMD>FzfLua live_grep<CR>")
if require("my.features").lsp then
  vim.keymap.set("n", "<leader>fs", "<CMD>FzfLua lsp_document_symbols<CR>")
end
