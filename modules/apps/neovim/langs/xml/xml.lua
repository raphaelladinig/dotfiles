local filetypes = { "xml", "xsd", "xsl", "xslt", "svg" }

return {
  filetypes = filetypes,
  setup = function()
    if require("my.features").lsp then
      vim.lsp.enable("lemminx")
    end

    if require("my.features").formatting then
      local formatters_by_ft = require("conform").formatters_by_ft
      for _, ft in ipairs(filetypes) do
        formatters_by_ft[ft] = { "xmlformat" }
      end
    end
  end,
}
