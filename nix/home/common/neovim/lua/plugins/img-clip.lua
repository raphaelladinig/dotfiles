require("img-clip").setup({
  filetypes = {
    typst = {
      template = [[
#align(center)[
  #image("$FILE_PATH", width: 80%)
]
      ]],
    },
  },
})
