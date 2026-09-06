require("nvim-surround").setup({})

require("nvim-autopairs").setup({})

require("img-clip").setup({
  custom = {
    {
      trigger = function()
        return vim.b.img_clip_template ~= nil
      end,
      template = function()
        return vim.b.img_clip_template
      end,
    },
  },
})
