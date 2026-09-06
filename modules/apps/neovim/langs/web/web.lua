return {
  filetypes = {
    "css",
    "scss",
    "html",
    "javascript",
    "typescript",
    "typescriptreact",
    "javascriptreact",
    "json",
    "jsonc",
  },
  setup = function()
    if require("my.features").lsp then
      vim.lsp.enable("cssls")
      vim.lsp.enable("html")
      vim.lsp.enable("jsonls")
      vim.lsp.enable("vtsls")
    end

    if require("my.features").formatting then
      local formatters_by_ft = require("conform").formatters_by_ft
      formatters_by_ft.css = { "prettierd" }
      formatters_by_ft.scss = { "prettierd" }
      formatters_by_ft.html = { "prettierd" }
      formatters_by_ft.javascript = { "prettierd" }
      formatters_by_ft.javascriptreact = { "prettierd" }
      formatters_by_ft.typescript = { "prettierd" }
      formatters_by_ft.typescriptreact = { "prettierd" }
      formatters_by_ft.json = { "prettierd" }
      formatters_by_ft.jsonc = { "prettierd" }
    end
  end,
}
