local ok, err = pcall(function()
  local ft = vim.env.DIALECT_FT
  local server = vim.env.DIALECT_SERVER
  local formatter = vim.env.DIALECT_FORMATTER
  local mode = vim.env.DIALECT_MODE
  local features = require("my.features")
  assert(vim.bo.filetype == ft, "unexpected filetype: " .. vim.bo.filetype)
  assert(features.lsp == (mode ~= "no-lsp"), "LSP fixture guard")
  assert(features.formatting == (mode ~= "no-formatting"), "formatting fixture guard")

  assert(vim.lsp.is_enabled(server) == features.lsp, server .. " enabled state")
  if features.lsp then
    assert(
      vim.wait(20000, function()
        return #vim.lsp.get_clients({ bufnr = 0, name = server }) > 0
      end, 50),
      server .. " did not attach"
    )
  else
    assert(#vim.lsp.get_clients({ bufnr = 0 }) == 0, "LSP attached with feature disabled")
  end

  if features.formatting then
    local conform = require("conform")
    assert(vim.deep_equal(conform.formatters_by_ft[ft], { formatter }), ft .. " formatter selection")
    local selected = conform.list_formatters(0)
    assert(#selected == 1 and selected[1].name == formatter and selected[1].available, "formatter unavailable")
  else
    assert(require("conform").formatters_by_ft[ft] == nil, "formatter selected with feature disabled")
  end
  print(server .. (features.lsp and " enabled and attached" or " disabled") .. "; formatting guard passed")
  if ft == "css" then
    for name, servers in pairs({ xml = { "lemminx" }, web = { "cssls", "html", "jsonls", "vtsls" } }) do
      local triggers = require("my.langs." .. name).filetypes
      for _, lsp in ipairs(servers) do
        for _, alias in ipairs(vim.lsp.config[lsp].filetypes) do
          assert(vim.tbl_contains(triggers, alias), lsp .. " missing trigger: " .. alias)
        end
      end
    end
  end
end)
if not ok then
  vim.api.nvim_err_writeln(tostring(err))
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end
