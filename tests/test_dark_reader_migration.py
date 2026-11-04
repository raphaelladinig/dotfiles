import copy
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

import plyvel

WRITER = (
    Path(__file__).resolve().parents[1] / "modules/apps/helium/apply-dark-reader.py"
)
EXTENSION_ID = "eimadpbcbfnmbkopoojfekhnkhdbieeh"
STORAGES = ("Local Extension Settings", "Sync Extension Settings")


def encode(value):
    return json.dumps(value, separators=(",", ":")).encode()


def read_list(store, key):
    value = store.get(key, [])
    if isinstance(value, dict) and "__meta_split_count" in value:
        value = json.loads(
            "".join(
                store[f"{key}_{base36(i)}"] for i in range(value["__meta_split_count"])
            )
        )
    return value


def base36(index):
    suffix = ""
    while index:
        index, digit = divmod(index, 36)
        suffix = "0123456789abcdefghijklmnopqrstuvwxyz"[digit] + suffix
    return suffix or "0"


class DarkReaderMigrationTests(unittest.TestCase):
    def check_migration(self, local, sync, expected):
        originals = (local, sync)
        with tempfile.TemporaryDirectory() as temporary:
            profile = Path(temporary) / "Default"
            paths = [profile / storage / EXTENSION_ID for storage in STORAGES]
            for path, original in zip(paths, originals):
                if original is None:
                    continue
                path.parent.mkdir(parents=True)
                with plyvel.DB(str(path), create_if_missing=True) as database:
                    for key, value in original.items():
                        database.put(key.encode(), encode(value))
                    database.put(b"unrelated-opaque-entry", b"\x00\xff")

            def run_writer():
                subprocess.run(
                    [sys.executable, "-B", str(WRITER), str(profile)], check=True
                )
                stores = []
                for path in paths:
                    with plyvel.DB(str(path), create_if_missing=False) as database:
                        stores.append(dict(database))
                return stores

            stores = run_writer()
            self.assertEqual(run_writer(), stores, "second run changed storage")
            decoded = []
            for store, original, lists in zip(stores, originals, expected):
                if original is not None:
                    self.assertEqual(store[b"unrelated-opaque-entry"], b"\x00\xff")
                original = original or {}
                for key, value in original.items():
                    if key not in ("schemeVersion", "enabledByDefault"):
                        self.assertEqual(store[key.encode()], encode(value), key)
                settings = {
                    key.decode(): json.loads(value)
                    for key, value in store.items()
                    if key != b"unrelated-opaque-entry"
                }
                self.assertGreaterEqual(settings["schemeVersion"], 2)
                if (
                    isinstance(original.get("schemeVersion"), int)
                    and original["schemeVersion"] >= 2
                ):
                    self.assertEqual(
                        settings["schemeVersion"], original["schemeVersion"]
                    )
                self.assertIs(settings["enabledByDefault"], False)
                self.assertEqual(read_list(settings, "enabledFor"), lists[0])
                self.assertEqual(read_list(settings, "disabledFor"), lists[1])
                decoded.append(settings)

            # Optional integration proof runs Dark Reader's actual startup code.
            source = os.environ.get("DARK_READER_SOURCE")
            if source:
                result = subprocess.run(
                    [
                        "node",
                        str(Path(__file__).with_name("dark_reader_startup.mjs")),
                        source,
                    ],
                    input=json.dumps(decoded),
                    text=True,
                    capture_output=True,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                active = json.loads(result.stdout)
                selected = 1 if (local or {}).get("syncSettings", True) else 0
                self.assertIs(active["enabledByDefault"], False)
                self.assertEqual(active["enabledFor"], expected[selected][0])
                self.assertEqual(active["disabledFor"], expected[selected][1])

    def legacy(self, only=False):
        return {
            "schemeVersion": 1,
            "applyToListedOnly": only,
            "siteList": ["listed.example"],
            "siteListEnabled": ["enabled.example"],
            "theme": {"brightness": 85},
            "syncSettings": False,
        }

    def test_legacy_default_on_keeps_both_lists(self):
        legacy = self.legacy()
        self.check_migration(
            legacy, legacy, [(["enabled.example"], ["listed.example"])] * 2
        )

    def test_legacy_listed_only_uses_original_mode(self):
        legacy = self.legacy(True)
        self.check_migration(legacy, legacy, [(["listed.example"], [])] * 2)

    def test_modern_lists_and_future_version_are_untouched(self):
        for version in (2, 3):
            with self.subTest(version=version):
                modern = self.legacy()
                modern.update(
                    schemeVersion=version,
                    enabledByDefault=True,
                    enabledFor=["modern.example"],
                    disabledFor=[],
                )
                self.check_migration(modern, modern, [(["modern.example"], [])] * 2)

    def test_missing_version_uses_original_mode(self):
        for only in (False, True):
            with self.subTest(only=only):
                legacy = self.legacy(only)
                del legacy["schemeVersion"]
                lists = (
                    (["listed.example"], [])
                    if only
                    else (["enabled.example"], ["listed.example"])
                )
                self.check_migration(legacy, legacy, [lists] * 2)

    def test_fresh_and_empty_schema_survive_startup(self):
        for settings in (
            None,
            {},
            {"schemeVersion": 0},
            {"schemeVersion": None},
            {"schemeVersion": ""},
        ):
            with self.subTest(settings=settings):
                self.check_migration(settings, settings, [([], [])] * 2)

    def test_missing_mode_defaults_to_original_default_on(self):
        legacy = self.legacy()
        del legacy["applyToListedOnly"]
        self.check_migration(
            legacy, legacy, [(["enabled.example"], ["listed.example"])] * 2
        )

    def test_mixed_versions_migrate_each_store_independently(self):
        legacy = self.legacy()
        modern = {
            "schemeVersion": 2,
            "enabledFor": ["modern.example"],
            "disabledFor": ["off.example"],
        }
        for local, sync, expected in (
            (
                legacy,
                self.legacy(True),
                [(["enabled.example"], ["listed.example"]), (["listed.example"], [])],
            ),
            (
                legacy,
                modern,
                [
                    (["enabled.example"], ["listed.example"]),
                    (["modern.example"], ["off.example"]),
                ],
            ),
            (
                modern,
                legacy,
                [
                    (["modern.example"], ["off.example"]),
                    (["enabled.example"], ["listed.example"]),
                ],
            ),
            ({}, modern, [([], []), (["modern.example"], ["off.example"])]),
            (modern, {}, [(["modern.example"], ["off.example"]), ([], [])]),
        ):
            for sync_settings in (False, True):
                with self.subTest(local=local, sync=sync, sync_settings=sync_settings):
                    self.check_migration(
                        dict(local, syncSettings=sync_settings), sync, expected
                    )

    def test_existing_modern_fields_win_even_with_legacy_version(self):
        for key in ("enabledFor", "disabledFor"):
            with self.subTest(key=key):
                settings = self.legacy()
                settings[key] = []
                expected = (
                    ([], ["listed.example"])
                    if key == "enabledFor"
                    else (["enabled.example"], [])
                )
                self.check_migration(settings, settings, [expected] * 2)

    def test_split_sync_lists_are_migrated_and_modern_chunks_preserved(self):
        sites = [f"site-{i}.example" for i in range(800)]
        serialized = json.dumps(sites)
        split = {
            "schemeVersion": 1,
            "applyToListedOnly": False,
            "siteListEnabled": {"__meta_split_count": 2},
            "siteListEnabled_0": serialized[:8000],
            "siteListEnabled_1": serialized[8000:],
            "siteList": ["off.example"],
        }
        modern = copy.deepcopy(split)
        modern.update(
            schemeVersion=2, enabledFor=modern["siteListEnabled"], disabledFor=[]
        )
        modern["enabledFor_0"] = modern["siteListEnabled_0"]
        modern["enabledFor_1"] = modern["siteListEnabled_1"]
        self.check_migration({}, split, [([], []), (sites, ["off.example"])])
        self.check_migration({}, modern, [([], []), (sites, [])])


if __name__ == "__main__":
    unittest.main()
