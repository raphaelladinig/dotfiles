local lsp_enabled = require("my.features").lsp

local function load()
  if not package.loaded["blink.cmp"] then
    vim.cmd.packadd("blink.cmp")
  end
end

-- Advertise completion capabilities before a language server starts.
if lsp_enabled then
  vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile", "FileType" }, {
    once = true,
    callback = load,
  })
end

local function setup()
  load()
  vim.cmd.packadd("luasnip")
  vim.cmd.packadd("friendly-snippets")

  local sources = { "path", "snippets", "buffer" }
  if lsp_enabled then
    table.insert(sources, 1, "lsp")
  end

  require("blink.cmp").setup({
    keymap = {
      preset = "super-tab",
    },

    appearance = {
      nerd_font_variant = "mono",
    },

    snippets = {
      preset = "luasnip",
    },

    sources = {
      default = sources,
    },

    completion = {
      menu = {
        draw = {
          columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind", gap = 1 } },
        },
      },
      documentation = {
        auto_show = false,
      },
      list = {
        selection = {
          preselect = true,
          auto_insert = false,
        },
      },
    },

    signature = {
      enabled = lsp_enabled,
    },

    cmdline = {
      enabled = true,
      keymap = {
        preset = "inherit",
      },
      completion = {
        menu = {
          auto_show = true,
        },
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
      },
    },

    fuzzy = {
      implementation = "prefer_rust_with_warning",
      prebuilt_binaries = {
        download = false,
      },
    },
  })

  require("luasnip").setup({})
  require("luasnip.loaders.from_vscode").lazy_load()
end

vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
  once = true,
  callback = setup,
})
