return {
  filetypes = { "typst" },
  setup = function()
    vim.cmd.packadd("typst-preview.nvim")

    if require("my.features").lsp then
      vim.lsp.enable("tinymist")
    end

    if require("my.features").formatting then
      require("conform").formatters_by_ft.typst = { "typstyle" }
    end
  end,
}
