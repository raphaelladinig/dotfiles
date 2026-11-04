"""Run with python3 -B -m unittest discover -s tests -p test_keepassxc_activation.py."""

import configparser
import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]


class KeePassXCActivationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        expression = """
          let
            flake = builtins.getFlake (toString ./.);
            pkgs = flake.inputs.nixpkgs-unstable.legacyPackages.${builtins.currentSystem};
            config = flake.darwinConfigurations.caelum.config;
          in pkgs.writeText "keepassxc-activation-fixture.json" (builtins.toJSON {
            activation = config.home-manager.users.${config.system.primaryUser}
              .home.activation.configureKeePassXCSettings.data;
            homeManagerShell = "${flake.inputs.home-manager}/lib/bash/home-manager.sh";
            bash = "${pkgs.bash}/bin/bash";
          })
        """
        result = subprocess.run(
            ["nix", "build", "--impure", "--no-link", "--json", "--expr", expression],
            cwd=REPO,
            text=True,
            capture_output=True,
            check=True,
        )
        fixture = json.loads(Path(json.loads(result.stdout)[0]["outputs"]["out"]).read_text())
        cls.activation = fixture["activation"]
        cls.bash = fixture["bash"]
        cls.home_manager_shell = fixture["homeManagerShell"]
        cls.helper_path = re.search(
            r"/nix/store/[a-z0-9]+-configure-keepassxc-settings", cls.activation
        ).group()
        cls.helper = Path(cls.helper_path).read_text()
        cls.crudini = re.search(r"/nix/store/[^\s]+/bin/crudini", cls.helper).group()

    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="keepassxc-test-")
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.home = self.root / "home"
        self.home.mkdir()
        self.config_dir = self.home / "Library/Application Support/KeePassXC"
        self.config_file = self.config_dir / "keepassxc.ini"
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.log = self.root / "commands"
        self.temporary_log = self.root / "temporary-files"
        self.addCleanup(self.remove_temporary_files)
        self.original = "# keep this comment\n[Custom]\nUnmanaged=preserved\n[GUI]\nShowTrayIcon=true\n"
        self.helper_under_test = self.helper

        for name, real in {
            "mktemp": "/usr/bin/mktemp",
            "cp": "/bin/cp",
            "cmp": "/usr/bin/cmp",
            "crudini": self.crudini,
            "mkdir": "/bin/mkdir",
            "install": "/usr/bin/install",
            "mv": "/bin/mv",
        }.items():
            wrapper = self.bin / name
            wrapper.write_text(
                f"#!{self.bash}\nset -eu\n"
                f"name={shlex.quote(name)}\nreal={shlex.quote(real)}\n"
                'printf "%s\\n" "$name" >> "$TEST_COMMANDS"\n'
                'failure="$name"\n'
                'if [[ "$name" == mktemp && "$1" != -t ]]; then failure=stage; fi\n'
                'if [[ "$TEST_FAIL" == "$failure" ]]; then\n'
                '  if [[ "$name" == cp || "$name" == install ]]; then\n'
                '    printf "partial write\\n" > "${@: -1}"\n'
                '  fi\n'
                '  echo "injected $failure failure" >&2\n'
                '  if [[ "$name" == cmp ]]; then exit 2; fi\n'
                '  exit 1\n'
                'fi\n'
                'if [[ "$name" == mktemp ]]; then\n'
                '  temporary="$("$real" "$@")"\n'
                '  printf "%s\\n" "$temporary" >> "$TEST_TEMPORARIES"\n'
                '  printf "%s\\n" "$temporary"\n'
                'else\n'
                '  exec "$real" "$@"\n'
                'fi\n'
            )
            wrapper.chmod(0o700)
            self.helper_under_test = self.helper_under_test.replace(
                real, shlex.quote(str(wrapper))
            )

        pgrep = self.bin / "pgrep"
        pgrep.write_text(f'#!{self.bash}\nexit "$TEST_APP_STATUS"\n')
        pgrep.chmod(0o700)
        self.activation_under_test = self.activation.replace(
            "/usr/bin/pgrep", shlex.quote(str(pgrep))
        )

    def temporary_files(self):
        if self.temporary_log.exists():
            return [Path(path) for path in self.temporary_log.read_text().splitlines()]
        return []

    def remove_temporary_files(self):
        for path in self.temporary_files():
            path.unlink(missing_ok=True)

    def write_original(self):
        self.config_dir.mkdir(parents=True, exist_ok=True)
        self.config_file.write_text(self.original)

    def commands(self):
        return self.log.read_text().splitlines() if self.log.exists() else []

    def activate(self, failure="", app_open=False, dry_run=False):
        helper = self.root / "apply-settings"
        helper.write_text(self.helper_under_test)
        helper.chmod(0o700)
        script = self.activation_under_test.replace(self.helper_path, shlex.quote(str(helper)))
        environment = {
            **os.environ,
            "HOME": str(self.home),
            "PATH": f"{self.bin}:/usr/bin:/bin",
            "NO_COLOR": "1",
            "TEST_FAIL": failure,
            "TEST_APP_STATUS": "0" if app_open else "1",
            "TEST_COMMANDS": str(self.log),
            "TEST_TEMPORARIES": str(self.temporary_log),
        }
        environment.pop("DRY_RUN", None)
        if dry_run:
            environment["DRY_RUN"] = "1"
        result = subprocess.run(
            [self.bash, "-c", "set -eu\nsource " + shlex.quote(self.home_manager_shell)
             + "\n" + script + '\nprintf "ACTIVATION_CONTINUED\\n"\n'],
            env=environment,
            text=True,
            capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("ACTIVATION_CONTINUED", result.stdout)
        for path in self.temporary_files():
            self.assertFalse(path.exists(), f"temporary file leaked: {path}")
        return result

    def assert_warning(self, result):
        self.assertIn("Warning: could not update KeePassXC settings", result.stderr)

    def test_malformed_ini_warns_and_continues(self):
        self.original = "[General\nExisting=value\n"
        self.write_original()
        result = self.activate()
        self.assert_warning(result)
        self.assertIn("Error parsing", result.stderr)
        self.assertEqual(self.config_file.read_text(), self.original)
        self.assertNotIn("install", self.commands())

    def test_failed_prerequisites_preserve_original(self):
        for failure in ("mktemp", "cp", "crudini", "cmp", "mkdir", "stage", "install", "mv"):
            with self.subTest(failure=failure):
                self.write_original()
                self.log.unlink(missing_ok=True)
                result = self.activate(failure=failure)
                self.assert_warning(result)
                self.assertEqual(self.config_file.read_text(), self.original)
                if failure not in ("install", "mv"):
                    self.assertNotIn("install", self.commands())
                if failure == "cp":
                    self.assertNotIn("crudini", self.commands())

    def test_unreadable_merge_input_prevents_install(self):
        self.write_original()
        self.helper_under_test = re.sub(
            r"< /nix/store/[^\s]+-keepassxc-settings",
            "< " + shlex.quote(str(self.root / "missing-managed-settings")),
            self.helper_under_test,
        )
        result = self.activate()
        self.assert_warning(result)
        self.assertEqual(self.config_file.read_text(), self.original)
        self.assertNotIn("crudini", self.commands())
        self.assertNotIn("install", self.commands())

    def test_non_file_destinations_warn_and_continue(self):
        self.config_dir.mkdir(parents=True)
        for kind in ("directory", "fifo"):
            with self.subTest(kind=kind):
                if kind == "directory":
                    self.config_file.mkdir()
                else:
                    os.mkfifo(self.config_file)
                result = self.activate()
                self.assert_warning(result)
                self.assertIn("Refusing to replace non-file", result.stderr)
                self.assertNotIn("install", self.commands())
                if kind == "directory":
                    self.assertTrue(self.config_file.is_dir())
                    self.config_file.rmdir()
                else:
                    self.assertTrue(self.config_file.is_fifo())

    def test_dangling_symlink_read_failure_preserves_link(self):
        self.config_dir.mkdir(parents=True)
        self.config_file.symlink_to(self.root / "missing-settings")
        result = self.activate()
        self.assert_warning(result)
        self.assertTrue(self.config_file.is_symlink())
        self.assertNotIn("crudini", self.commands())
        self.assertNotIn("install", self.commands())

    def test_valid_merge_preserves_unmanaged_settings_and_is_idempotent(self):
        self.write_original()
        result = self.activate()
        self.assertEqual(result.stderr, "")
        merged = self.config_file.read_text()
        self.assertIn("# keep this comment", merged)
        settings = configparser.ConfigParser()
        settings.read_string(merged)
        self.assertEqual(settings["Custom"]["Unmanaged"], "preserved")
        self.assertFalse(settings.getboolean("GUI", "ShowTrayIcon"))
        self.assertTrue(settings.getboolean("Browser", "Enabled"))
        self.assertEqual(self.config_file.stat().st_mode & 0o777, 0o600)
        before = self.config_file.stat()
        self.log.unlink()
        self.activate()
        self.assertEqual(self.config_file.stat().st_ino, before.st_ino)
        self.assertEqual(self.config_file.stat().st_mtime_ns, before.st_mtime_ns)
        self.assertNotIn("install", self.commands())

    def test_missing_destination_is_created(self):
        self.activate()
        self.assertTrue(self.config_file.is_file())
        self.assertEqual(self.config_file.stat().st_mode & 0o777, 0o600)

    def test_symlink_target_is_preserved_on_failure_and_success(self):
        self.config_dir.mkdir(parents=True)
        target = self.root / "linked-settings"
        target.write_text(self.original)
        self.config_file.symlink_to(target)
        result = self.activate(failure="install")
        self.assert_warning(result)
        self.assertTrue(self.config_file.is_symlink())
        self.assertEqual(target.read_text(), self.original)
        self.activate()
        self.assertFalse(self.config_file.is_symlink())
        self.assertEqual(target.read_text(), self.original)
        self.assertIn("Unmanaged=preserved", self.config_file.read_text())

    def test_open_app_skips_all_settings_work(self):
        self.write_original()
        result = self.activate(app_open=True)
        self.assertIn("quit KeePassXC", result.stdout)
        self.assertEqual(self.config_file.read_text(), self.original)
        self.assertEqual(self.commands(), [])

    def test_dry_run_never_writes_destination(self):
        for existing in (False, True):
            with self.subTest(existing=existing):
                if existing:
                    self.write_original()
                result = self.activate(dry_run=True)
                self.assertEqual(result.stderr, "")
                self.assertEqual(self.commands(), [])
                if existing:
                    self.assertEqual(self.config_file.read_text(), self.original)
                else:
                    self.assertFalse(self.config_dir.exists())


if __name__ == "__main__":
    unittest.main()
