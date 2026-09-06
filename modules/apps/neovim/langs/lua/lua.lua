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
      local luacheck = require("lint").linters.luacheck
      table.insert(luacheck.args, 1, function()
        local file = vim.api.nvim_buf_get_name(0)
        if file:match("/%.nvim/") then
          return "--globals=vim"
        end
        local rc = vim.fs.find(".luacheckrc", {
          path = file ~= "" and vim.fs.dirname(file) or nil,
          upward = true,
        })[1]
        return rc and ("--config=" .. rc) or "--no-config"
      end)

      require("lint").linters_by_ft.lua = { "luacheck" }
    end
  end,
}
