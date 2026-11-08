#!/usr/bin/env python3
"""Check platform deployment and migration without touching the real home directory."""

import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import tempfile
import unittest
import uuid

ROOT = Path(__file__).resolve().parents[1]


class ChezmoiSmokeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotc-test-")
        self.tmp = Path(self.temp.name)
        self.home = self.tmp / "home"
        self.home.mkdir()
        self.config = self.tmp / "chezmoi.toml"
        self.config.write_text('[data]\nemail="test@example.com"\nname="Test"\ngithubUser="test"\n')
        self.env = os.environ.copy()
        self.env.update({
            "HOME": str(self.home),
            "XDG_CONFIG_HOME": str(self.home / ".config"),
            "XDG_DATA_HOME": str(self.home / ".local/share"),
            "XDG_STATE_HOME": str(self.home / ".local/state"),
            "XDG_CACHE_HOME": str(self.home / ".cache"),
        })

    def tearDown(self):
        self.temp.cleanup()

    def chezmoi(self, repo, *args, system=None):
        command = [
            "chezmoi", "--source", str(repo), "--destination", str(self.home),
            "--config", str(self.config), "--cache", str(self.tmp / "cache"),
            "--persistent-state", str(self.tmp / "state"),
        ]
        if system:
            command += ["--override-data", json.dumps({"chezmoi": {"os": system, "osRelease": {"id": "ubuntu"}}})]
        return subprocess.run(command + list(args), env=self.env, text=True, capture_output=True, check=True)

    def test_platform_files_and_nvim_sources_match(self):
        for system in ("darwin", "linux", "windows"):
            with self.subTest(system=system):
                shutil.rmtree(self.home)
                self.home.mkdir()
                self.chezmoi(ROOT, "apply", "--exclude=scripts", "--force", system=system)
                nvim = self.home / ("AppData/Local/nvim" if system == "windows" else ".config/nvim")
                for source in (ROOT / "modules/nvim").rglob("*"):
                    if source.is_file():
                        self.assertEqual((nvim / source.relative_to(ROOT / "modules/nvim")).read_bytes(), source.read_bytes())
                self.assertEqual((self.home / ".config/fish/config.fish").is_file(), system != "windows")
                self.assertEqual((self.home / ".config/powershell/profile.ps1").is_file(), system == "windows")
                self.assertEqual((self.home / ".config/herdr/config.toml").is_file(), system == "darwin")
                self.chezmoi(ROOT, "verify", "--exclude=scripts", system=system)

    @unittest.skipIf(os.name == "nt", "POSIX symlink migration")
    def test_backup_and_replace_old_neovim_symlink_once(self):
        repo = self.tmp / "repo with space"
        shutil.copytree(ROOT, repo, ignore=shutil.ignore_patterns(".git", "__pycache__", ".DS_Store"))
        subprocess.run(["git", "init", "--quiet", str(repo)], check=True, capture_output=True)
        (repo / "scripts/setup.sh").write_text('#!/usr/bin/env bash\nprintf "%s\\n" "$DOTFILES_INSTALL_CODEX" > "$HOME/setup-ran"\n')
        old = self.tmp / "old-nvim"
        (old / "lua/plugins").mkdir(parents=True)
        (old / "lua/plugins/personal.lua").write_text("old settings\n")
        (old / "init.lua").write_text("old init\n")
        (self.home / ".config").mkdir()
        (self.home / ".config/nvim").symlink_to(old, target_is_directory=True)

        self.chezmoi(repo, "apply", "--force")
        target = self.home / ".config/nvim"
        self.assertFalse(target.is_symlink())
        self.assertTrue((target / ".dotc-managed").is_file())
        self.assertEqual((self.home / "setup-ran").read_text().strip(), "false")
        self.assertFalse((target / "lua/plugins/personal.lua").exists())
        self.assertEqual((old / "lua/plugins/personal.lua").read_text(), "old settings\n")
        backups = list((self.home / ".local/state/dotc/backups").glob("nvim-*/nvim/lua/plugins/personal.lua"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), "old settings\n")

        self.chezmoi(repo, "apply", "--force")
        self.assertEqual(len(list((self.home / ".local/state/dotc/backups").glob("nvim-*"))), 1)

    @unittest.skipUnless(os.name == "nt", "Windows migration")
    def test_backup_and_replace_old_windows_neovim(self):
        repo = self.tmp / "repo with space"
        shutil.copytree(ROOT, repo, ignore=shutil.ignore_patterns(".git", "__pycache__", ".DS_Store"))
        subprocess.run(["git", "init", "--quiet", str(repo)], check=True, capture_output=True)
        (repo / "scripts/setup.ps1").write_text("Set-Content -Path (Join-Path $env:USERPROFILE 'setup-ran') -Value $env:DOTFILES_INSTALL_CODEX\n")
        local = self.home / "AppData/Local"
        old = local / "nvim/lua/plugins"
        old.mkdir(parents=True)
        (old / "personal.lua").write_text("old settings\n")
        self.env.update({"LOCALAPPDATA": str(local), "USERPROFILE": str(self.home)})

        self.chezmoi(repo, "apply", "--force")
        target = local / "nvim"
        self.assertTrue((target / ".dotc-managed").is_file())
        self.assertEqual((self.home / "setup-ran").read_text().strip(), "false")
        self.assertFalse((target / "lua/plugins/personal.lua").exists())
        backups = list((local / "dotc/backups").glob("nvim-*/lua/plugins/personal.lua"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), "old settings\n")
        self.chezmoi(repo, "apply", "--force")
        self.assertEqual(len(list((local / "dotc/backups").glob("nvim-*"))), 1)

    @unittest.skipUnless(shutil.which("fish"), "Fish is not installed")
    def test_fish_reconciliation_is_idempotent(self):
        functions = self.home / ".config/fish/functions"
        functions.mkdir(parents=True)
        plugins = (ROOT / "modules/fish/fish_plugins").read_text().splitlines()
        (functions / "fisher.fish").write_text(
            'function fisher\n if test "$argv[1]" = list\n  printf "%s\\n" '
            + " ".join(plugins)
            + '\n else\n  echo unexpected_update >&2\n  return 1\n end\nend\n'
        )
        for name in ("nvm", "tide", "fzf_configure_bindings"):
            (functions / (name + ".fish")).write_text("function " + name + "\nend\n")
        self.env["DOTFILES_ROOT"] = str(ROOT)
        subprocess.run(["fish", str(ROOT / "scripts/install-fish-plugins.fish")],
                       env=self.env, text=True, capture_output=True, check=True)

    def test_readme_documents_pinned_versions(self):
        readme = (ROOT / "README.md").read_text()
        for line in (ROOT / "config/versions.env").read_text().splitlines():
            if line and not line.startswith("#"):
                self.assertIn(line.split("=", 1)[1], readme)

    @unittest.skipIf(os.name == "nt", "Unix toolchain installer")
    def test_locked_toolchains_do_not_redownload_when_present(self):
        versions = dict(line.split("=", 1) for line in (ROOT / "config/versions.env").read_text().splitlines()
                        if line and not line.startswith("#"))
        system = {"Darwin": "darwin", "Linux": "linux"}[platform.system()]
        arch = {"arm64": "arm64", "aarch64": "arm64", "x86_64": "x64", "amd64": "x64"}[platform.machine().lower()]
        node = self.home / ".local/share/nodejs" / ("node-v" + versions["NODE_VERSION"] + "-" + system + "-" + arch) / "bin/node"

        def executable(path, body):
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("#!/bin/sh\n" + body + "\n")
            path.chmod(0o755)

        executable(node, 'printf "v%s\\n" "' + versions["NODE_VERSION"] + '"')
        executable(self.home / ".local/bin/npm", 'printf "%s\\n" "' + versions["NPM_VERSION"] + '"')
        executable(self.home / ".local/bin/pnpm", 'printf "%s\\n" "' + versions["PNPM_VERSION"] + '"')
        executable(self.home / ".bun/bin/bun", 'printf "%s\\n" "' + versions["BUN_VERSION"] + '"')
        executable(self.home / ".cargo/bin/rustup", 'printf "%s\\n" "$*" >> "$HOME/rustup.log"')
        executable(self.home / ".local/bin/curl", 'echo unexpected-download >&2; exit 1')
        (self.home / ".nvm").mkdir()
        (self.home / ".nvm/nvm.sh").write_text('nvm() { printf "%s\\n" "' + versions["NVM_UNIX_VERSION"] + '"; }\n')
        for package in ("commitizen", "cz-git"):
            (self.home / ".local/lib/node_modules" / package).mkdir(parents=True)

        for _ in range(2):
            subprocess.run(["bash", str(ROOT / "scripts/install-toolchains.sh")], env=self.env,
                           text=True, capture_output=True, check=True)
        self.assertEqual((self.home / ".local/opt/node").resolve(), node.parent.parent.resolve())
        self.assertIn(versions["RUST_VERSION"], (self.home / "rustup.log").read_text())

    @unittest.skipUnless(os.name != "nt" and shutil.which("tmux"), "tmux is unavailable")
    def test_tmux_configuration_loads_in_a_separate_server(self):
        target = self.home / ".config/tmux"
        target.parent.mkdir(parents=True)
        shutil.copytree(ROOT / "modules/tmux", target)
        name = "dotc-test-" + uuid.uuid4().hex[:10]
        self.env.update({"TERM": "xterm-256color", "SHELL": "/bin/sh"})

        def tmux(*args):
            return subprocess.run(["tmux", "-L", name] + list(args), env=self.env,
                                  text=True, capture_output=True, check=True)

        try:
            tmux("-f", str(target / "tmux.conf"), "new-session", "-d", "-s", "test", "sleep 30")
            self.assertEqual(tmux("show-options", "-g", "prefix").stdout.strip(), "prefix C-t")
        finally:
            subprocess.run(["tmux", "-L", name, "kill-server"], env=self.env, capture_output=True)

    def test_init_persists_source_and_optional_settings(self):
        self.config.write_text('[data]\nemail="test@example.com"\nname="Test"\ngithubUser="test"\ninstallCodex=true\n')
        self.chezmoi(ROOT, "init", "--apply", "--exclude=scripts", "--force")
        self.assertIn("installCodex = true", self.config.read_text())
        result = subprocess.run(
            ["chezmoi", "--config", str(self.config), "execute-template", "{{ .chezmoi.workingTree }}"],
            env=self.env, text=True, capture_output=True, check=True,
        )
        self.assertEqual(Path(result.stdout.strip()).resolve(), ROOT.resolve())


if __name__ == "__main__":
    unittest.main()
