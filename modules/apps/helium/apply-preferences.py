import json
import os
import sys
import tempfile
from pathlib import Path


def merge(target, settings):
    for key, value in settings.items():
        if isinstance(value, dict):
            if not isinstance(target.get(key), dict):
                target[key] = {}
            merge(target[key], value)
        else:
            target[key] = value


def main():
    path = Path(sys.argv[1])
    settings = json.loads(Path(sys.argv[2]).read_text())
    if path.is_symlink():
        raise ValueError(f"Refusing to replace symlink: {path}")
    original = path.read_text() if path.exists() else "{}"
    preferences = json.loads(original)
    if not isinstance(preferences, dict):
        raise ValueError(f"Expected a JSON object: {path}")
    merge(preferences, settings)
    if preferences == json.loads(original):
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as output:
            temporary = output.name
            json.dump(preferences, output, separators=(",", ":"))
            output.write("\n")
        os.replace(temporary, path)
    finally:
        if temporary and os.path.exists(temporary):
            os.unlink(temporary)


if __name__ == "__main__":
    main()
