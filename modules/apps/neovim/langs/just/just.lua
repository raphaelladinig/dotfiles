return {
  filetypes = { "just" },
  setup = function()
    if require("my.features").lsp then
      vim.lsp.enable("just")
    end

    if require("my.features").formatting then
      require("conform").formatters_by_ft.just = { "just" }
    end
  end,
}
