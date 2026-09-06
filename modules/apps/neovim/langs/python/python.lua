return {
  filetypes = { "python" },
  setup = function()
    if require("my.features").lsp then
      vim.lsp.enable("pyright")
    end

    if require("my.features").formatting then
      require("conform").formatters_by_ft.python = { "black" }
    end

    if require("my.features").dap then
      require("dap-python").setup(require("my.python").debugger)
    end
  end,
}
