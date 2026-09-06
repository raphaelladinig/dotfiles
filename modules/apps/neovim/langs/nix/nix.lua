return {
  filetypes = { "nix" },
  setup = function()
    if require("my.features").lsp then
      vim.lsp.enable("nixd")
    end

    if require("my.features").formatting then
      require("conform").formatters_by_ft.nix = { "nixfmt" }
    end
  end,
}
