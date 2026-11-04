local root = assert(vim.env.LUACHECK_TEST_ROOT)
local repo = assert(vim.env.LUACHECK_TEST_REPO)
vim.opt.runtimepath:prepend(assert(vim.env.NVIM_LINT_RTP))
package.loaded["my.features"] = { lsp = false, formatting = false, linting = true }

local function write(path, lines)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile(lines, path)
end

local first = root .. "/project one"
local second = root .. "/project two"
local outside = root .. "/outside"
vim.fn.mkdir(outside, "p")
for _, project in ipairs({ first, second }) do
  local global = project == first and "project_api" or "other_api"
  write(project .. "/globals.lua", { 'return "' .. global .. '"' })
  write(project .. "/.luacheckrc", {
    project == first and 'files["src/*.lua"] = { globals = { "project_api" } }'
      or 'files["src/*.lua"] = { globals = { dofile("globals.lua") } }',
  })
  write(project .. "/src/main.lua", { "-- Contents must come from the unsaved buffer." })
  write(project .. "/other/main.lua", { "-- Same global is undefined outside src/." })
end
write(outside .. "/.luacheckrc", { 'globals = { "cwd_only" }' })
write(root .. "/unconfigured/main.lua", { "-- No project configuration." })
write(root .. "/unconfigured/.nvim/config.lua", { "-- Neovim project config." })
vim.cmd.cd(outside)

local notices = {}
vim.notify = function(message)
  notices[#notices + 1] = message
end
vim.notify_once = vim.notify
local lint = require("lint")
dofile(repo .. "/modules/apps/neovim/langs/lua/lua.lua").setup()
local namespace = lint.get_namespace("luacheck")
local published = {}
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  callback = function(args)
    published[args.buf] = true
  end,
})

local function buffer(path, lines)
  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].filetype = "lua"
  vim.bo[buf].bufhidden = "hide"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  return buf
end

local function start(buf)
  published[buf] = nil
  -- The lint target need not be the visible buffer.
  vim.api.nvim_buf_call(buf, function()
    lint.try_lint()
  end)
end

local function diagnostics(buf)
  assert(
    vim.wait(10000, function()
      return published[buf] and #lint.get_running(buf) == 0
    end, 10),
    "Luacheck did not publish diagnostics for " .. vim.api.nvim_buf_get_name(buf)
  )
  assert(#notices == 0, vim.inspect(notices))
  return vim.diagnostic.get(buf, { namespace = namespace })
end

local function expect(buf, names)
  local expected = {}
  for line, name in ipairs(names) do
    if name then
      expected[#expected + 1] = { name = name, line = line - 1 }
    end
  end
  local actual = diagnostics(buf)
  assert(#actual == #expected, vim.inspect(actual))
  for i, item in ipairs(expected) do
    local diagnostic = actual[i]
    assert(diagnostic.code == "113", vim.inspect(diagnostic))
    assert(diagnostic.message == "accessing undefined variable '" .. item.name .. "'", vim.inspect(diagnostic))
    assert(diagnostic.lnum == item.line and diagnostic.col == 0, vim.inspect(diagnostic))
    assert(diagnostic.severity == vim.diagnostic.severity.WARN, vim.inspect(diagnostic))
    assert(diagnostic.source == "luacheck", vim.inspect(diagnostic))
  end
end

local one = buffer(first .. "/src/main.lua", { "project_api()", "missing_one()" })
local two = buffer(second .. "/src/main.lua", { "other_api()", "missing_two()" })
local none = buffer(root .. "/unconfigured/main.lua", { "project_api()", "other_api()", "cwd_only()" })
local config = buffer(root .. "/unconfigured/.nvim/config.lua", { "vim.print('ok')", "missing_config()" })
local nonmatching = buffer(first .. "/other/main.lua", { "project_api()" })

-- Launch every project before yielding, then switch the visible buffer again.
for _, buf in ipairs({ one, two, none, config, nonmatching }) do
  start(buf)
end
vim.api.nvim_set_current_buf(none)
expect(one, { false, "missing_one" })
expect(two, { false, "missing_two" })
expect(none, { "project_api", "other_api", "cwd_only" })
expect(nonmatching, { "project_api" })
expect(config, { false, "missing_config" })
assert(vim.uv.fs_realpath(vim.fn.getcwd()) == vim.uv.fs_realpath(outside), "Lint changed Neovim's working directory")

vim.api.nvim_buf_set_lines(one, 0, -1, false, { "project_api()" })
start(one)
expect(one, {})
print("Luacheck buffer context regression passed")
