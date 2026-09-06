-- macOS temporary paths can exceed the Unix socket path limit inside Nix shells.
if vim.fn.has("macunix") == 1 and not vim.env.XDG_RUNTIME_DIR then
  local runtime_dir = assert(vim.uv.fs_mkdtemp("/tmp/nvim.XXXXXX"))
  vim.env.XDG_RUNTIME_DIR = runtime_dir
  vim.api.nvim_create_autocmd("VimLeavePre", {
    once = true,
    callback = function()
      vim.fn.delete(runtime_dir, "rf")
    end,
  })
end

vim.loader.enable()

require("my.settings")

local function module_names(dir)
  local files = vim.api.nvim_get_runtime_file("lua/my/" .. dir .. "/*.lua", true)
  table.sort(files)
  local names = {}
  for _, file in ipairs(files) do
    table.insert(names, "my." .. dir .. "." .. vim.fn.fnamemodify(file, ":t:r"))
  end
  return names
end

local function load_modules(dir)
  for _, name in ipairs(module_names(dir)) do
    require(name)
  end
end

-- Lang modules return { filetypes, setup }; setup runs once, on the first
-- buffer of a matching filetype.
local function load_langs_lazily()
  local setup_by_ft = {}
  for _, name in ipairs(module_names("langs")) do
    local lang = require(name)
    local pending = true
    local function setup_once()
      if pending then
        lang.setup()
        pending = false
      end
    end
    for _, ft in ipairs(lang.filetypes) do
      setup_by_ft[ft] = setup_once
    end
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("my.langs", {}),
    callback = function(args)
      local setup = setup_by_ft[args.match]
      if setup then
        setup()
      end
    end,
  })
end

load_modules("ui")
load_modules("plugins")
load_langs_lazily()
