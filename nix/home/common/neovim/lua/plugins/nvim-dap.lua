local dap = require("dap")

vim.keymap.set("n", "<leader>dc", function()
  dap.continue()
end)
vim.keymap.set("n", "<leader>do", function()
  dap.step_over()
end)
vim.keymap.set("n", "<leader>di", function()
  dap.step_into()
end)
vim.keymap.set("n", "<leader>dI", function()
  dap.step_into()
end)
vim.keymap.set("n", "<leader>db", function()
  dap.toggle_breakpoint()
end)

dap.adapters.lldb = {
  type = "executable",
  command = "lldb-dap",
  name = "lldb",
}

dap.configurations.cpp = {
  {
    name = "default",
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
