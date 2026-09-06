return {
  filetypes = { "sh", "bash" },
  setup = function()
    if require("my.features").lsp then
      vim.lsp.enable("bashls")
    end

    if require("my.features").formatting then
      require("conform").formatters_by_ft.sh = { "shfmt" }
      require("conform").formatters_by_ft.bash = { "shfmt" }
    end
  end,
}
