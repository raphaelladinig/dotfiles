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
    default = { "lsp", "path", "snippets", "buffer" },
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
    enabled = true,
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
