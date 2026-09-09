import csv
import sys
from pathlib import Path


def main():
    with Path(sys.argv[1]).open() as source:
        expected = list(csv.DictReader(source))
    directory = Path(sys.argv[2])
    try:
        missing = [
            row for row in expected
            if not any((directory / row["Chrome extension ID"]).glob("*/manifest.json"))
        ]
    except OSError as error:
        print(f"Could not fully check Helium extensions: {error}")
        return

    if missing:
        print("\nHelium extensions need manual installation:")
        for row in missing:
            print(f"{row['Extension']}: https://chromewebstore.google.com/detail/{row['Chrome extension ID']}")


if __name__ == "__main__":
    main()
