vim.keymap.set("n", "<leader>ln", function()
  require("lint").try_lint()
end)
