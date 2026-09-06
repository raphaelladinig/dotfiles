require("conform").setup({
  format_on_save = function(bufnr)
    return {
      timeout_ms = vim.b[bufnr].format_timeout_ms or 500,
      lsp_format = require("my.features").lsp and "fallback" or "never",
    }
  end,
})

vim.keymap.set({ "n", "v" }, "<leader>c", function()
  require("conform").format()
end)
