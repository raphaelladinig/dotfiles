require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    nix = { "alejandra" },
    typst = { "typstyle" },
    markdown = { "prettierd" },
    cpp = { "clang-format" },
    c = { "clang-format" },
    python = { "black" },
    sh = { "beautysh" },
    bash = { "beautysh" },
    css = { "prettierd" },
    html = { "prettierd" },
    javascript = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    json = { "prettierd" },
    jsonc = { "prettierd" },
    cs = { "csharpier" },
    rust = { "rustfmt" },
  },
})

vim.keymap.set({ "n", "v" }, "<leader>mp", function()
  require("conform").format()
end)
