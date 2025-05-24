vim.opt.showtabline = 0

require("lualine").setup({
  options = {
    section_separators = "",
    component_separators = "|",
  },
  sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      {
        "filename",
        path = 1,
      },
      "diagnostics",
      "diff",
    },
    lualine_x = {
      "location",
    },
    lualine_y = {},
    lualine_z = {},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      {
        "filename",
        path = 1,
      },
      "diagnostics",
      "diff",
    },
    lualine_x = {
      "location",
    },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {
    lualine_c = {
      "tabs",
      "buffers",
    },
    lualine_x = {
      "branch",
    },
  },
})
