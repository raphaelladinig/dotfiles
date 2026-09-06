return {
  filetypes = { "fish" },
  setup = function()
    if require("my.features").lsp then
      vim.lsp.enable("fish_lsp")
    end

    if require("my.features").formatting then
      require("conform").formatters_by_ft.fish = { "fish_indent" }
    end
  end,
}
