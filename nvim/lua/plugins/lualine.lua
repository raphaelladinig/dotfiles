return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
    opts = {
			options = {
				theme = "auto",
				section_separators = "",
				component_separators = "|",
				globalstatus = true,
				disabled_filetypes = {
					"alpha",
				},
			},
			sections = {
				lualine_a = {
					"mode",
				},
				lualine_b = {},
				lualine_c = {
					"diagnostics",
				},
				lualine_x = {
					"branch",
					"diff",
				},
				lualine_y = {
					"progress",
				},
				lualine_z = {
					"location",
				},
			},
    }
}
