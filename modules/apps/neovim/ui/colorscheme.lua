require("catppuccin").setup({
  flavour = "auto",
  background = {
    light = "latte",
    dark = "mocha",
  },
  color_overrides = {
    mocha = {
      base = "#000000",
    },
  },
})

vim.cmd.colorscheme("catppuccin")
