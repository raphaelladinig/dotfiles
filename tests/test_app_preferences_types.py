"""Run with python3 -m unittest discover -s tests -p test_app_preferences_types.py."""

import json
import os
from pathlib import Path
import plistlib
import pwd
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
DEFAULTS = "/usr/bin/defaults"


@unittest.skipUnless(sys.platform == "darwin", "requires macOS defaults")
class AppPreferenceTypesTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.nixpkgs = subprocess.check_output(
            [
                "nix", "eval", "--impure", "--raw", "--expr",
                f"(builtins.getFlake (toString {ROOT})).inputs.nixpkgs-unstable.outPath",
            ],
            cwd=ROOT,
            text=True,
        )

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="app-preference-types-")
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name)
        self.domain = str(self.directory / "preferences")
        self.plist = Path(self.domain + ".plist")
        self.log = self.directory / "mutations.log"

    def seed(self, values):
        self.plist.write_bytes(plistlib.dumps(values))

    def read(self, operation, key):
        return subprocess.check_output(
            [DEFAULTS, operation, self.domain, key], text=True
        ).rstrip("\n")

    def apply(self, preferences, *, app_open=False, fail="", copies=1):
        settings = {
            str(index): {
                "domain": self.domain,
                "processName": "PreferenceFixture",
                "preferences": preferences,
            }
            for index in range(copies)
        }
        fixture = self.directory / "settings.json"
        fixture.write_text(json.dumps(settings))
        expression = f"""
          let
            lib = import {self.nixpkgs}/lib;
          in (lib.evalModules {{
            modules = [
              (import {ROOT}/modules/app-preferences.nix {{}}).den.aspects.app-preferences.darwin
              {{
                options.system.primaryUser = lib.mkOption {{ type = lib.types.str; }};
                options.system.activationScripts.postActivation.text = lib.mkOption {{
                  type = lib.types.lines;
                  default = "";
                }};
                config.system.primaryUser = {json.dumps(pwd.getpwuid(os.getuid()).pw_name)};
                config.dotfiles.appPreferences = builtins.fromJSON (builtins.readFile {fixture});
              }}
            ];
          }}).config.system.activationScripts.postActivation.text
        """
        script = subprocess.check_output(
            ["nix", "eval", "--impure", "--raw", "--expr", expression],
            cwd=ROOT,
            text=True,
        )
        # Keep the generated shell and real defaults; isolate user switching and process detection.
        script = script.replace("/usr/bin/pgrep", "fixture_pgrep")
        harness = r"""
launchctl() {
  [[ "$1" == asuser && "$3" == sudo && "$5" == --set-home && "$6" == -- ]] || return 99
  shift 6
  [[ "$1" == /usr/bin/defaults && "$3" == "$FIXTURE_DOMAIN" ]] || return 99
  if [[ "$2" == write || "$2" == delete ]]; then
    printf '%s\n' "$2" >> "$FIXTURE_LOG"
    [[ "$2" != "$FIXTURE_FAIL" ]] || return 1
  fi
  "$@"
}
fixture_pgrep() {
  [[ "$1" == -x && "$2" == -u && "$4" == PreferenceFixture ]] || return 99
  [[ "$FIXTURE_OPEN" == true ]]
}
"""
        result = subprocess.run(
            ["/bin/bash", "-euo", "pipefail", "-c", harness + script],
            env={
                **os.environ,
                "FIXTURE_DOMAIN": self.domain,
                "FIXTURE_LOG": str(self.log),
                "FIXTURE_FAIL": fail,
                "FIXTURE_OPEN": "true" if app_open else "false",
            },
            text=True,
            capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def mutations(self):
        return self.log.read_text().splitlines() if self.log.exists() else []

    def test_same_text_repairs_every_scalar_type(self):
        values = [(False, "boolean"), (0, "integer"), ("0", "string"), (0.0, "float")]
        for original, original_type in values:
            for desired, desired_type in values:
                if original_type == desired_type:
                    continue
                with self.subTest(original=original_type, desired=desired_type):
                    self.seed({"value": original, "unmanaged": "keep"})
                    self.assertEqual(self.read("read", "value"), "0")
                    self.assertEqual(self.read("read-type", "value"), f"Type is {original_type}")
                    self.apply({"value": desired})
                    self.assertEqual(self.read("read-type", "value"), f"Type is {desired_type}")
                    contents = plistlib.loads(self.plist.read_bytes())
                    self.assertIs(type(contents["value"]), type(desired))
                    self.assertEqual(contents["value"], desired)
                    self.assertEqual(contents["unmanaged"], "keep")

    def test_correct_types_and_values_do_not_write(self):
        preferences = {"boolean": False, "integer": 0, "string": "0"}
        self.seed(preferences)
        before = self.plist.read_bytes()
        self.apply(preferences)
        self.assertEqual(self.mutations(), [])
        self.assertEqual(self.plist.read_bytes(), before)

    def test_fractional_float_and_missing_key(self):
        self.seed({"fraction": "1.250000"})
        self.apply({"fraction": 1.25, "missing": True})
        self.assertEqual(self.read("read-type", "fraction"), "Type is float")
        self.assertEqual(self.read("read", "fraction"), "1.25")
        self.assertEqual(self.read("read-type", "missing"), "Type is boolean")
        self.assertEqual(self.read("read", "missing"), "1")

    def test_changed_value_with_correct_type(self):
        self.seed({"value": 2})
        self.apply({"value": 3})
        self.assertEqual(self.read("read", "value"), "3")
        self.assertEqual(self.mutations(), ["write"])

    def test_escaping(self):
        key = "key ' \" $(false); spaces"
        value = "value ' \" $(false); \\ spaces\nsecond line"
        self.seed({key: "before"})
        self.apply({key: value})
        self.assertEqual(self.read("read", key), value)
        self.log.unlink()
        self.apply({key: value})
        self.assertEqual(self.mutations(), [])

    def test_open_app_skips_type_repair_and_warns_once(self):
        self.seed({"value": "0"})
        before = self.plist.read_bytes()
        result = self.apply({"value": False}, app_open=True, copies=2)
        self.assertEqual(result.stdout.count("Skipping PreferenceFixture preferences:"), 1)
        self.assertEqual(self.mutations(), [])
        self.assertEqual(self.plist.read_bytes(), before)

    def test_failed_write_warns_and_continues(self):
        self.seed({"a": 1, "b": 1})
        result = self.apply({"a": 2, "b": 2}, fail="write")
        self.assertEqual(result.stderr.count("Could not apply"), 2)
        self.assertEqual(self.mutations(), ["write", "write"])
        self.assertEqual(plistlib.loads(self.plist.read_bytes()), {"a": 1, "b": 1})

    def test_failed_type_removal_warns_without_writing(self):
        self.seed({"value": False})
        result = self.apply({"value": 0}, fail="delete")
        self.assertIn("Could not apply", result.stderr)
        self.assertEqual(self.mutations(), ["delete"])
        self.assertEqual(self.read("read-type", "value"), "Type is boolean")


if __name__ == "__main__":
    unittest.main()
