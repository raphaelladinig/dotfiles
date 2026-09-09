import copy
import csv
import os
import plistlib
import sys
import tempfile
from pathlib import Path


def main():
    path = Path(sys.argv[1])
    with Path(sys.argv[2]).open() as source:
        extensions = list(csv.DictReader(source))
    extension_ids = [row["Chrome extension ID"] for row in extensions]
    if path.is_symlink():
        raise ValueError(f"Refusing to replace symlink: {path}")
    policy = plistlib.loads(path.read_bytes()) if path.exists() else {}
    if not isinstance(policy, dict):
        raise ValueError(f"Expected a plist dictionary: {path}")
    original = copy.deepcopy(policy)
    policy["ExtensionInstallForcelist"] = extension_ids
    for extension in extensions:
        toolbar_pin = extension.get("Toolbar pin")
        if toolbar_pin:
            settings = policy.setdefault("ExtensionSettings", {})
            settings.setdefault(extension["Chrome extension ID"], {})["toolbar_pin"] = toolbar_pin
    if policy == original:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as output:
            temporary = output.name
            plistlib.dump(policy, output)
            os.fchmod(output.fileno(), 0o644)
        os.replace(temporary, path)
    finally:
        if temporary and os.path.exists(temporary):
            os.unlink(temporary)


if __name__ == "__main__":
    main()
