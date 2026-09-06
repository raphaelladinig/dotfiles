local function setup()
  require("lualine").setup({
    options = {
      theme = "auto",
      section_separators = "",
      component_separators = "|",
      always_show_tabline = true,
    },
    sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        {
          "filename",
          path = 1,
        },
        {
          "diagnostics",
          symbols = { error = "E", warn = "W", info = "I", hint = "H" },
        },
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
        {
          "diagnostics",
          symbols = { error = "E", warn = "W", info = "I", hint = "H" },
        },
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
        {
          "tabs",
          mode = 2,
        },
      },
      lualine_x = {
        "branch",
      },
    },
  })
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(setup)
  end,
})
