import json
import os
import runpy
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock


SCRIPT = Path(__file__).resolve().parents[1] / "modules/apps/helium/apply-preferences.py"


class HeliumPreferenceTypesTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        self.target = self.directory / "Preferences"
        self.settings = self.directory / "settings.json"

    def apply(self):
        with mock.patch.object(sys, "argv", [str(SCRIPT), str(self.target), str(self.settings)]):
            runpy.run_path(str(SCRIPT), run_name="__main__")

    def prepare(self, existing, desired):
        self.target.write_text(json.dumps(existing))
        self.settings.write_text(json.dumps(desired))

    def snapshot(self, path):
        stat = path.stat()
        return path.read_bytes(), stat.st_mtime_ns, stat.st_ino

    def test_integer_values_are_corrected_to_booleans(self):
        for existing, desired in ((0, False), (1, True)):
            with self.subTest(existing=existing, desired=desired):
                self.prepare({"enabled": existing}, {"enabled": desired})
                self.apply()
                actual = json.loads(self.target.read_text())["enabled"]
                self.assertIs(actual, desired)

    def test_list_values_keep_json_types(self):
        for existing, desired, indexes, expected in (
            ([0], [False], (0,), False),
            ([1], [True], (0,), True),
            ([{"enabled": 1}], [{"enabled": True}], (0, "enabled"), True),
            ([[0]], [[False]], (0, 0), False),
        ):
            with self.subTest(existing=existing):
                self.prepare({"items": existing}, {"items": desired})
                self.apply()
                actual = json.loads(self.target.read_text())["items"]
                for index in indexes:
                    actual = actual[index]
                self.assertIs(actual, expected)

    def test_nested_and_list_values_keep_json_types_and_unmanaged_settings(self):
        existing = {
            "helium": {"services": {"enabled": 1, "custom": "keep"}, "ext_proxy": 0},
            "items": [{"enabled": 1}, [0, 1]],
            "unmanaged": [1, 0, {"keep": True}],
        }
        desired = {
            "helium": {"services": {"enabled": True}, "ext_proxy": False},
            "items": [{"enabled": True}, [False, True]],
        }
        self.prepare(existing, desired)
        self.apply()
        actual = json.loads(self.target.read_text())
        self.assertIs(actual["helium"]["services"]["enabled"], True)
        self.assertIs(actual["helium"]["ext_proxy"], False)
        self.assertIs(actual["items"][0]["enabled"], True)
        self.assertIs(actual["items"][1][0], False)
        self.assertIs(actual["items"][1][1], True)
        self.assertEqual(actual["helium"]["services"]["custom"], "keep")
        self.assertEqual(actual["unmanaged"], existing["unmanaged"])

    def test_matching_content_preserves_bytes_and_mtime(self):
        self.target.write_text(
            '{\n  "unmanaged": 42, "helium": {"ext_proxy": false, "enabled": true},\n'
            '  "items": [{"b": false, "a": true}]\n}\n'
        )
        self.settings.write_text(json.dumps({
            "helium": {"enabled": True, "ext_proxy": False},
            "items": [{"a": True, "b": False}],
        }))
        os.utime(self.target, ns=(1_000_000_000, 1_000_000_000))
        before = self.snapshot(self.target)
        with mock.patch("os.replace") as replace:
            self.apply()
        replace.assert_not_called()
        self.assertEqual(self.snapshot(self.target), before)

    def test_changed_content_is_atomically_replaced(self):
        self.prepare({"enabled": 1}, {"enabled": True})
        before = self.snapshot(self.target)
        real_replace = os.replace

        def replace(source, destination):
            self.assertEqual(Path(source).parent, self.target.parent)
            self.assertEqual(destination, self.target)
            self.assertEqual(self.snapshot(self.target), before)
            self.assertIs(json.loads(Path(source).read_text())["enabled"], True)
            real_replace(source, destination)

        with mock.patch("os.replace", side_effect=replace) as replaced:
            self.apply()
        replaced.assert_called_once()
        self.assertNotEqual(self.target.stat().st_ino, before[2])
        self.assertIs(json.loads(self.target.read_text())["enabled"], True)
        self.assertEqual(set(self.directory.iterdir()), {self.target, self.settings})

    def test_failed_replace_preserves_original_and_removes_temporary_file(self):
        self.prepare({"enabled": 1}, {"enabled": True})
        before = self.snapshot(self.target)
        with mock.patch("os.replace", side_effect=OSError("replace failed")):
            with self.assertRaises(OSError):
                self.apply()
        self.assertEqual(self.snapshot(self.target), before)
        self.assertEqual(set(self.directory.iterdir()), {self.target, self.settings})

    def test_malformed_and_non_object_json_remain_untouched(self):
        for content in ('{"broken":', "[]", "null", "true", "0", '"text"'):
            for invalid in (self.target, self.settings):
                with self.subTest(content=content, invalid=invalid.name):
                    self.prepare({"enabled": 1}, {"enabled": True})
                    invalid.write_text(content)
                    before = self.snapshot(self.target), self.snapshot(self.settings)
                    with self.assertRaises((ValueError, AttributeError)):
                        self.apply()
                    self.assertEqual(
                        (self.snapshot(self.target), self.snapshot(self.settings)), before
                    )
                    self.assertEqual(set(self.directory.iterdir()), {self.target, self.settings})

    def test_symlink_targets_remain_untouched(self):
        self.settings.write_text('{"enabled":true}')
        for exists in (True, False):
            with self.subTest(referent_exists=exists):
                referent = self.directory / "referent.json"
                if exists:
                    referent.write_text('{"enabled":1}')
                self.target.symlink_to(referent)
                before = self.snapshot(referent) if exists else None
                with self.assertRaisesRegex(ValueError, "symlink"):
                    self.apply()
                self.assertTrue(self.target.is_symlink())
                self.assertEqual(self.target.readlink(), referent)
                self.assertEqual(self.snapshot(referent) if exists else None, before)
                self.assertEqual(referent.exists(), exists)
                self.target.unlink()
                if exists:
                    referent.unlink()


if __name__ == "__main__":
    unittest.main()
