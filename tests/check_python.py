"""Compile repository Python in memory and run focused regression tests."""

import os
from pathlib import Path
import unittest


def main():
    root = Path(__file__).resolve().parent.parent
    os.environ["PYTHONDONTWRITEBYTECODE"] = "1"
    sources = sorted(
        path
        for directory in (root / "modules", root / "tests")
        for path in directory.rglob("*.py")
    )
    for path in sources:
        compile(path.read_bytes(), str(path), "exec")
    print(f"Python syntax passed ({len(sources)} files)", flush=True)
    suite = unittest.defaultTestLoader.discover(str(root / "tests"))
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
