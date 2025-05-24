require("avante_lib").load()
require("avante").setup({
  provider = "gemini",
  behaviour = {
    auto_suggestions = false,
  },
  hints = {
    enabled = false,
  },
  gemini = {
    model = "gemini-2.5-pro-preview-05-06",
  },
})
