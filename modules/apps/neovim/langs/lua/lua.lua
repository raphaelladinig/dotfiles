return {
  filetypes = { "lua" },
  setup = function()
    if require("my.features").lsp then
      vim.lsp.enable("lua_ls")
    end

    if require("my.features").formatting then
      require("conform").formatters_by_ft.lua = { "stylua" }
    end

    if require("my.features").linting then
      local lint = require("lint")
      local luacheck = lint.linters.luacheck
      -- nvim-lint resolves this factory in the target buffer before spawning.
      lint.linters.luacheck = function()
        local linter = vim.deepcopy(luacheck)
        local file = vim.api.nvim_buf_get_name(0)
        if file ~= "" then
          linter.args = vim.list_extend({ "--filename", file }, linter.args)
        end
        if file:match("/%.nvim/") then
          table.insert(linter.args, 1, "--globals=vim")
        else
          local rc = vim.fs.find(".luacheckrc", {
            path = file ~= "" and vim.fs.dirname(file) or nil,
            upward = true,
          })[1]
          linter.cwd = rc and vim.fs.dirname(rc) or nil
          table.insert(linter.args, 1, rc and ("--config=" .. rc) or "--no-config")
        end
        return linter
      end

      lint.linters_by_ft.lua = { "luacheck" }
    end
  end,
}
