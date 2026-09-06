vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost", "BufEnter" }, {
  callback = function()
    require("lint").try_lint()
  end,
})
