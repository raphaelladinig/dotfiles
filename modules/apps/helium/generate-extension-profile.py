import csv
import plistlib
import sys
import uuid
from pathlib import Path


IDENTIFIER = "net.imput.helium.dotfiles.extensions"


def payload(kind, identifier):
    return {
        "PayloadType": kind,
        "PayloadIdentifier": identifier,
        "PayloadUUID": str(uuid.uuid5(uuid.NAMESPACE_URL, identifier)).upper(),
        "PayloadVersion": 1,
    }


def main():
    with Path(sys.argv[1]).open() as source:
        extensions = list(csv.DictReader(source))
    policy = {
        "ExtensionInstallForcelist": [row["Chrome extension ID"] for row in extensions],
        "ExtensionSettings": {
            row["Chrome extension ID"]: {"toolbar_pin": row["Toolbar pin"]}
            for row in extensions
            if row.get("Toolbar pin")
        },
    }
    preferences = payload("com.apple.ManagedClient.preferences", IDENTIFIER + ".preferences")
    preferences["PayloadContent"] = {
        "net.imput.helium": {"Forced": [{"mcx_preference_settings": policy}]}
    }
    profile = payload("Configuration", IDENTIFIER)
    profile.update({
        "PayloadDisplayName": "Helium extensions",
        "PayloadDescription": "Installs the extensions and toolbar pins declared in dotfiles.",
        "PayloadScope": "User",
        "PayloadRemovalDisallowed": False,
        "PayloadContent": [preferences],
    })
    Path(sys.argv[2]).write_bytes(plistlib.dumps(profile))


if __name__ == "__main__":
    main()
