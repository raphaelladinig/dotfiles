vim.g.markdown_recommended_style = 0

return {
  filetypes = { "markdown" },
  setup = function()
    if require("my.features").lsp then
      vim.lsp.enable("marksman")
    end

    if require("my.features").formatting then
      require("conform").formatters_by_ft.markdown = { "prettierd" }
    end
  end,
}
