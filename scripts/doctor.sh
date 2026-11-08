#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"
load_versions
failed=0

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        printf '%-16s %s\n' "$1" "$(command -v "$1")"
    else
        printf '%-16s MISSING\n' "$1" >&2
        failed=1
    fi
}
check_version() {
    local name="$1" expected="$2" actual
    if ! command -v "$name" >/dev/null 2>&1; then check_command "$name"; return; fi
    actual=$("$name" --version | head -n 1)
    printf '%-16s %s (expected %s)\n' "$name" "$actual" "$expected"
    [[ "$actual" == "$expected" || "$actual" == "v$expected" ]] || failed=1
}

for name in git fish nvim gh ghq lazygit delta zoxide just fzf rg fd uv conda; do check_command "$name"; done
check_version node "$NODE_VERSION"
check_version npm "$NPM_VERSION"
check_version pnpm "$PNPM_VERSION"
check_version bun "$BUN_VERSION"
if command -v rustup >/dev/null 2>&1; then
    rustup run "$RUST_VERSION" rustc --version || failed=1
else
    check_command rustup
fi
exit "$failed"
