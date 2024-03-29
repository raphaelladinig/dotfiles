return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-buffer",
        "onsails/lspkind.nvim",
    },
    config = function()
        local cmp = require("cmp")

        cmp.setup({
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            window = {
                completion = {
                    border = "rounded",
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
                    zindex = 1001,
                    scrolloff = 0,
                    col_offset = 0,
                    side_padding = 1,
                    scrollbar = false,
                },
                documentation = {
                    border = "rounded",
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
                    zindex = 1001,
                    scrolloff = 0,
                    col_offset = 0,
                    side_padding = 1,
                    scrollbar = false,
                },
            },
            mapping = cmp.mapping.preset.insert({
                ["<S-TAB>"] = cmp.mapping.select_prev_item(),
                ["<TAB>"] = cmp.mapping.select_next_item(),
                ["<C-SPACE>"] = cmp.mapping.complete(),
                ["<C-e"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
            }),
            formatting = {
                fields = { "kind", "abbr", "menu" },
                format = function(entry, vim_item)
                    local kind = require("lspkind").cmp_format({
                        mode = "symbol",
                        maxwidth = 50,
                        menu = {
                            nvim_lsp = "[LSP]",
                            luasnip = "[LuaSnip]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                        },
                    })(entry, vim_item)

                    local strings = vim.split(kind.kind, "%s", { trimempty = true })
                    kind.kind = (strings[1] or "") .. " "

                    return kind
                end,
            },
        })
    end,
}
