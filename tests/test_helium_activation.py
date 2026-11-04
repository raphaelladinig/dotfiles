"""Run with python3 -m unittest discover -s tests -p test_helium_activation.py -v."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]
EXTENSION = "eimadpbcbfnmbkopoojfekhnkhdbieeh"
STORES = ("Local Extension Settings", "Sync Extension Settings")


class HeliumActivationTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        expression = r'''
          let
            repo = builtins.getEnv "HELIUM_TEST_REPO";
            flake = builtins.getFlake repo;
            pkgs = flake.darwinConfigurations.caelum.pkgs;
            module = import (repo + "/modules/apps/helium") { den = {}; };
            settings = module.den.aspects.apps.helium.darwin {
              inherit pkgs;
              inherit (pkgs) lib;
              config = {
                system.primaryUser = "helium-test";
                users.users.helium-test.home = "/helium-activation-fixture";
              };
            };
          in pkgs.writeText "helium-activation-fixture.json" (builtins.toJSON {
            activation = settings.system.activationScripts.postActivation.text.content;
            python = "${pkgs.python3.withPackages (ps: [ ps.plyvel ])}/bin/python3";
          })
        '''
        result = subprocess.run(
            ["nix", "build", "--impure", "--no-link", "--print-out-paths", "--expr", expression],
            env={**os.environ, "HELIUM_TEST_REPO": str(REPO)},
            text=True,
            capture_output=True,
        )
        if result.returncode:
            raise RuntimeError(result.stderr)
        fixture = json.loads(Path(result.stdout.strip()).read_text())
        cls.activation = fixture["activation"]
        cls.python = fixture["python"]

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="helium-activation-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.data = self.root / "home/Library/Application Support/net.imput.helium"
        self.profile = self.data / "Default"
        self.profile.mkdir(parents=True)
        self.preferences = self.profile / "Preferences"
        self.local_state = self.data / "Local State"
        self.calls = self.root / "calls"

    def run_activation(self, *, fail_writer=0, app_open=False, repeats=1):
        activation = self.activation.replace("/helium-activation-fixture", str(self.root / "home"))
        activation = activation.replace("/usr/bin/pgrep", "helium_test_pgrep")
        script = r'''
            set -euo pipefail
            id() { printf '501\n'; }
            helium_test_pgrep() { [[ "$HELIUM_APP_OPEN" == 1 ]]; }
            helium_writer_number=0
            launchctl() {
                shift 6
                helium_writer_number=$((helium_writer_number + 1))
                printf '%s\n' "$*" >> "$HELIUM_CALLS"
                if [[ "$helium_writer_number" == "$HELIUM_FAIL_WRITER" ]]; then
                    return 73
                fi
                "$@"
            }
        '''
        script += activation * repeats
        script += '\nprintf "activation continued\\n"\n'
        result = subprocess.run(
            ["bash", "-c", script],
            env={
                **os.environ,
                "HOME": str(self.root / "home"),
                "XDG_CONFIG_HOME": str(self.root / "config"),
                "HELIUM_CALLS": str(self.calls),
                "HELIUM_FAIL_WRITER": str(fail_writer),
                "HELIUM_APP_OPEN": str(int(app_open)),
            },
            text=True,
            capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("activation continued", result.stdout)
        return result

    def database(self, code):
        return subprocess.run(
            [self.python, "-c", code, str(self.profile)],
            text=True,
            capture_output=True,
            check=True,
        ).stdout

    def assert_databases_updated(self):
        self.database(
            f"""
import pathlib, plyvel, sys
for storage in {STORES!r}:
    with plyvel.DB(str(pathlib.Path(sys.argv[1]) / storage / {EXTENSION!r})) as db:
        assert db.get(b'enabledByDefault') == b'false'
        assert db.get(b'schemeVersion') == b'2'
        assert db.get(b'enabledFor') == b'[]'
        assert db.get(b'disabledFor') == b'[]'
"""
        )

    def test_invalid_json_preserved_and_later_writers_run(self):
        invalid_values = (b'{broken\n', b'[1, 2]\n', b'null\n', b'"string"\n', b'42\n')
        for path in (self.preferences, self.local_state):
            for original in invalid_values:
                with self.subTest(path=path.name, original=original):
                    self.preferences.write_text('{"unmanaged":true}')
                    self.local_state.write_text('{"unmanaged":true}')
                    self.calls.unlink(missing_ok=True)
                    path.write_bytes(original)
                    result = self.run_activation()
                    self.assertEqual(path.read_bytes(), original)
                    self.assertIn(str(path), result.stderr)
                    self.assertIn("run `just switch` again", result.stderr)
                    self.assertEqual(len(self.calls.read_text().splitlines()), 3)
                    other = self.local_state if path == self.preferences else self.preferences
                    merged = json.loads(other.read_text())
                    self.assertTrue(merged["unmanaged"])
                    self.assertIn("browser", merged)
                    self.assert_databases_updated()

    def test_each_command_failure_continues_to_next_writer(self):
        for writer, path in enumerate((self.preferences, self.local_state, self.profile), 1):
            with self.subTest(writer=writer):
                self.calls.unlink(missing_ok=True)
                result = self.run_activation(fail_writer=writer)
                self.assertIn(str(path), result.stderr)
                self.assertIn("run `just switch` again", result.stderr)
                self.assertEqual(len(self.calls.read_text().splitlines()), 3)

    def test_symlinks_are_preserved(self):
        target = self.root / "original.json"
        target.write_bytes(b'{"unmanaged":true}\n')
        self.preferences.symlink_to(target)
        self.local_state.symlink_to(target)
        result = self.run_activation()
        self.assertIn("Refusing to replace symlink", result.stderr)
        self.assertTrue(self.preferences.is_symlink())
        self.assertTrue(self.local_state.is_symlink())
        self.assertEqual(target.read_bytes(), b'{"unmanaged":true}\n')
        self.assert_databases_updated()

    def test_locked_database_is_preserved(self):
        code = f"""
import pathlib, plyvel, sys
path = pathlib.Path(sys.argv[1]) / {STORES[0]!r} / {EXTENSION!r}
path.parent.mkdir(parents=True)
with plyvel.DB(str(path), create_if_missing=True) as db:
    db.put(b'preserve', b'contents', sync=True)
    print('locked', flush=True)
    sys.stdin.readline()
    assert dict(db) == {{b'preserve': b'contents'}}
"""
        with subprocess.Popen(
            [self.python, "-c", code, str(self.profile)],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        ) as holder:
            try:
                self.assertEqual(holder.stdout.readline().strip(), "locked")
                database = self.profile / STORES[0] / EXTENSION
                # LevelDB rotates diagnostic logs before checking its lock.
                def contents():
                    return {
                        p.name: (p.stat().st_ino, p.read_bytes())
                        for p in database.iterdir()
                        if p.name not in ("LOG", "LOG.old")
                    }

                before = contents()
                for _ in range(2):
                    result = self.run_activation()
                    self.assertIn("Could not apply Helium Dark Reader", result.stderr)
                    self.assertIn("LOCK", result.stderr)
                    self.assertEqual(contents(), before)
            finally:
                _, error = holder.communicate("release\n", timeout=10)
            self.assertEqual(holder.returncode, 0, error)
        self.assertIn("browser", json.loads(self.local_state.read_text()))
        self.run_activation()
        self.assert_databases_updated()
        self.database(
            f"""
import pathlib, plyvel, sys
with plyvel.DB(str(pathlib.Path(sys.argv[1]) / {STORES[0]!r} / {EXTENSION!r})) as db:
    assert db.get(b'preserve') == b'contents'
"""
        )

    def test_successful_merge_and_idempotence(self):
        self.preferences.write_text('{"unmanaged":true,"helium":{"keep":7}}')
        self.local_state.write_text('{"unmanaged":true}')
        self.run_activation()
        self.assertEqual(json.loads(self.preferences.read_text())["helium"]["keep"], 7)
        self.assertTrue(json.loads(self.local_state.read_text())["unmanaged"])
        self.assert_databases_updated()
        before = [(path.read_bytes(), path.stat().st_mtime_ns) for path in (self.preferences, self.local_state)]
        self.run_activation()
        self.assertEqual(
            [(path.read_bytes(), path.stat().st_mtime_ns) for path in (self.preferences, self.local_state)], before
        )
        self.assert_databases_updated()

    def test_open_app_skips_all_writers_with_one_reminder(self):
        result = self.run_activation(app_open=True, repeats=2)
        self.assertEqual(result.stdout.count("Skipping Helium preferences"), 1)
        self.assertFalse(self.calls.exists())
        self.assertFalse(self.preferences.exists())
        self.assertFalse(self.local_state.exists())


if __name__ == "__main__":
    unittest.main()
