import json
import sys
from pathlib import Path

import plyvel


def chunk_key(key, index):
    suffix = ""
    while index:
        index, digit = divmod(index, 36)
        suffix = "0123456789abcdefghijklmnopqrstuvwxyz"[digit] + suffix
    return key + b"_" + (suffix or "0").encode()


def migrate_site_lists(database, sync):
    settings = {b"schemeVersion": b"2"}
    only_listed = json.loads(database.get(b"applyToListedOnly") or b"false")
    lists = {
        b"enabledFor": b"siteList" if only_listed else b"siteListEnabled",
        b"disabledFor": None if only_listed else b"siteList",
    }
    for key, legacy_key in lists.items():
        if database.get(key) is not None:
            continue
        value = json.loads(database.get(legacy_key) or b"null") if legacy_key else None
        if isinstance(value, dict) and "__meta_split_count" in value:
            value = json.loads(
                "".join(
                    json.loads(database.get(chunk_key(legacy_key, index)))
                    for index in range(value["__meta_split_count"])
                )
            )
        serialized = json.dumps(
            value if value is not None else [], separators=(",", ":")
        ).encode()
        # Match Dark Reader's sync quota and base-36 chunk keys.
        if sync and len(key) + len(serialized) > 8192:
            size = 8192 - len(key) - 3
            chunks = [
                serialized[start : start + size]
                for start in range(0, len(serialized), size)
            ]
            for index, chunk in enumerate(chunks):
                settings[chunk_key(key, index)] = json.dumps(chunk.decode()).encode()
            serialized = json.dumps({"__meta_split_count": len(chunks)}).encode()
        settings[key] = serialized
    return settings


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
            version = json.loads(database.get(b"schemeVersion") or b"0") or 0
            if int(version) < 2:
                # Preserve list meanings before enforcing the new mode.
                settings.update(
                    migrate_site_lists(database, storage == "Sync Extension Settings")
                )
            with database.write_batch(sync=True) as batch:
                for key, value in settings.items():
                    if database.get(key) != value:
                        batch.put(key, value)


if __name__ == "__main__":
    main()
