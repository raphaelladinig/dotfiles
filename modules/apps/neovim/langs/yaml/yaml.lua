return {
  filetypes = { "yaml" },
  setup = function()
    if require("my.features").lsp then
      vim.lsp.enable("yamlls")
    end

    if require("my.features").formatting then
      require("conform").formatters_by_ft.yaml = { "prettierd" }
    end
  end,
}
