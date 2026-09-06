return {
  filetypes = { "xml" },
  setup = function()
    if require("my.features").lsp then
      vim.lsp.enable("lemminx")
    end

    if require("my.features").formatting then
      require("conform").formatters_by_ft.xml = { "xmlformat" }
    end
  end,
}
