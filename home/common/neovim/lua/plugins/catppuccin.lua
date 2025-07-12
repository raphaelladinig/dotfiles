require("catppuccin").setup({
  flavour = "mocha",
  color_overrides = {
    mocha = {
      base = "#000000",
    },
  },
})

vim.cmd.colorscheme("catppuccin")
