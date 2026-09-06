local nvim_settings = {
  Lua = {
    runtime = { version = "LuaJIT" },
    workspace = {
      library = { vim.env.VIMRUNTIME .. "/lua" },
      checkThirdParty = false,
    },
    diagnostics = { globals = { "vim" } },
  },
}

return {
  root_dir = function(bufnr, on_dir)
    local file = vim.api.nvim_buf_get_name(bufnr)
    for dir in vim.fs.parents(file) do
      if vim.fs.basename(dir) == ".nvim" then
        return on_dir(dir)
      end
    end
    on_dir(vim.fs.root(file, {
      ".emmyrc.json",
      ".luarc.json",
      ".luarc.jsonc",
      ".luacheckrc",
      ".stylua.toml",
      "stylua.toml",
      "selene.toml",
      "selene.yml",
      ".git",
    }))
  end,
  on_init = function(client)
    if client.root_dir and vim.fs.basename(client.root_dir) == ".nvim" then
      client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, nvim_settings.Lua)
    end
  end,
}
