import sys
from pathlib import Path

import plyvel


def main():
    profile = Path(sys.argv[1])
    extension_id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"
    for storage in ("Local Extension Settings", "Sync Extension Settings"):
        path = profile / storage / extension_id
        if path.is_symlink():
            raise ValueError(f"Refusing to open symlink: {path}")
        path.parent.mkdir(parents=True, exist_ok=True)
        with plyvel.DB(str(path), create_if_missing=True) as database:
            settings = {b"enabledByDefault": b"false"}
            # Fresh installs migrate the legacy setting before reading the new one.
            version = database.get(b"schemeVersion")
            if version is None or int(version) < 2:
                settings[b"applyToListedOnly"] = b"true"
            with database.write_batch(sync=True) as batch:
                for key, value in settings.items():
                    if database.get(key) != value:
                        batch.put(key, value)


if __name__ == "__main__":
    main()
