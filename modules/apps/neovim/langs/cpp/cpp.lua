return {
  filetypes = { "c", "cpp" },
  setup = function()
    if require("my.features").lsp then
      vim.lsp.enable("clangd")
    end

    if require("my.features").formatting then
      require("conform").formatters_by_ft.cpp = { "clang-format" }
      require("conform").formatters_by_ft.c = { "clang-format" }
    end

    if require("my.features").dap then
      local dap = require("dap")

      dap.adapters.lldb = {
        type = "executable",
        command = "lldb-dap",
        name = "lldb",
      }

      dap.configurations.cpp = {
        {
          name = "Launch",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
      }
      dap.configurations.c = dap.configurations.cpp
    end
  end,
}
