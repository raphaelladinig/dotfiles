assert(vim.v.errmsg == "", vim.v.errmsg)
assert(vim.v.vim_did_enter == 1, "VimEnter did not run")
assert(package.loaded["oil"] and package.loaded["fzf-lua"] and package.loaded["ibl"], "VimEnter setup did not run")
assert(vim.o.statusline:find("lualine", 1, true), "statusline setup did not run")
assert(vim.g.mapleader == " ", "repository settings did not load")
assert(vim.o.number and not vim.o.swapfile, "editor settings did not load")

local features = require("my.features")
assert(features.lsp and features.formatting and features.treesitter, "generated feature flags are missing")
local formatters = require("conform").formatters_by_ft
assert(formatters.lua == nil, "Lua setup should wait for a matching buffer")

for _, language in ipairs({
  { file = "smoke.lua", ft = "lua", server = "lua_ls", formatter = "stylua", text = "return 1" },
  { file = "smoke.py", ft = "python", server = "pyright", formatter = "black", text = "value = 1" },
  { file = "smoke.nix", ft = "nix", server = "nixd", formatter = "nixfmt", text = "{ value = 1; }" },
}) do
  vim.fn.writefile({ language.text }, language.file)
  vim.cmd.edit(language.file)
  assert(vim.bo.filetype == language.ft, "filetype detection failed: " .. language.ft)
  assert(vim.lsp.is_enabled(language.server), "LSP setup failed: " .. language.server)
  assert(vim.fn.executable(vim.lsp.config[language.server].cmd[1]) == 1, "declared language server is missing")
  assert(vim.deep_equal(formatters[language.ft], { language.formatter }), "formatter setup failed: " .. language.ft)
  assert(vim.fn.executable(language.formatter) == 1, "declared formatter is missing")
  assert(vim.treesitter.get_parser(0), "bundled parser is missing: " .. language.ft)
  assert(vim.v.errmsg == "", vim.v.errmsg)
end

vim.api.nvim_exec_autocmds("InsertEnter", {})
assert(package.loaded["blink.cmp"] and package.loaded["luasnip"], "lazy completion did not load")
assert(#require("dap").configurations.python > 0, "Python debugger setup did not run")
vim.wait(200, function()
  return false
end)
assert(vim.v.errmsg == "", vim.v.errmsg)
assert(#_G.smoke_errors == 0, table.concat(_G.smoke_errors, "\n"))
print("Neovim smoke passed (Lua, Python, Nix, completion, parsers, DAP)")
