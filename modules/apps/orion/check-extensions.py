import csv
import io
import json
import plistlib
import sys
from pathlib import Path


def main():
    inventory = Path(sys.argv[1]).read_text()
    directory = Path(sys.argv[2])
    expected = [
        (row["Extension"], row["Firefox extension ID"])
        for row in csv.DictReader(io.StringIO(inventory))
    ]

    installed = set()
    try:
        with (directory / "extensions.plist").open("rb") as source:
            extensions = plistlib.load(source)["extensions"]
        for key in extensions:
            manifest = json.loads((directory / key / "manifest.json").read_text())
            for field in ("browser_specific_settings", "applications"):
                extension_id = manifest.get(field, {}).get("gecko", {}).get("id")
                if extension_id:
                    installed.add(extension_id)
    except FileNotFoundError:
        pass
    except (OSError, ValueError, KeyError, TypeError, AttributeError, plistlib.InvalidFileException) as error:
        print(f"Could not fully check Orion extensions: {error}")

    missing = [name for name, extension_id in expected if extension_id not in installed]
    if missing:
        print("\nOrion extensions need manual installation: " + ", ".join(missing))
        print(inventory)


if __name__ == "__main__":
    main()
