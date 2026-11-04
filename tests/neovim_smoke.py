"""Run the generated Home Manager editor config without user state."""

import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile


def main():
    with tempfile.TemporaryDirectory(prefix="nvim-check-", dir="/tmp") as temporary:
        root = Path(temporary)
        environment = {"PATH": os.environ["PATH"], "TERM": "xterm-256color", "LANG": "C"}
        for variable, directory in {
            "HOME": "home",
            "XDG_CONFIG_HOME": "config",
            "XDG_CONFIG_DIRS": "config-dirs",
            "XDG_DATA_HOME": "data",
            "XDG_DATA_DIRS": "data-dirs",
            "XDG_STATE_HOME": "state",
            "XDG_CACHE_HOME": "cache",
            "XDG_RUNTIME_DIR": "runtime",
            "TMPDIR": "tmp",
        }.items():
            path = root / directory
            path.mkdir(mode=0o700)
            environment[variable] = str(path)
        generated = Path(sys.argv[1])
        shutil.copytree(generated / ".config/nvim", root / "config/nvim")
        shutil.copytree(generated / ".local/share/nvim", root / "data/nvim", symlinks=True)
        work = root / "work"
        work.mkdir()
        smoke = Path(__file__).with_suffix(".lua")
        capture_errors = (
            "lua vim.lsp.config('*', { detached = false }); "
            "_G.smoke_errors = {}; local notify = vim.notify; "
            "vim.notify = function(message, level, opts) "
            "if level == vim.log.levels.ERROR then "
            "table.insert(_G.smoke_errors, tostring(message)) end; "
            "notify(message, level, opts) end"
        )
        command = (
            "lua vim.api.nvim_create_autocmd('VimEnter', { once = true, "
            "callback = function() vim.schedule(function() "
            "local ok, err = xpcall(function() dofile("
            + json.dumps(str(smoke))
            + ") end, debug.traceback); "
            "if not ok then vim.api.nvim_err_writeln(err); vim.cmd('cquit 1') "
            "else vim.cmd('qa!') end end) end })"
        )
        process = subprocess.Popen(
            ["nvim", "--headless", "-i", "NONE", "--cmd", capture_errors, "-c", command],
            cwd=work,
            env=environment,
            start_new_session=True,
        )
        try:
            return process.wait(timeout=60)
        finally:
            # LSP children can outlive Neovim and recreate caches during cleanup.
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            process.wait()


if __name__ == "__main__":
    raise SystemExit(main())
