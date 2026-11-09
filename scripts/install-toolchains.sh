#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"
load_versions

mkdir -p "$HOME/.local/bin" "$HOME/.local/share/nodejs" "$HOME/.local/opt" "$HOME/.nvm"
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

current_nvm=""
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    current_nvm=$(unset NPM_CONFIG_PREFIX; export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh" --no-use; nvm --version) || true
fi
if [[ "$current_nvm" != "$NVM_UNIX_VERSION" ]]; then
    mkdir -p "$HOME/.nvm"
    download "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_UNIX_VERSION}/install.sh" "$temp_dir/nvm.sh"
    PROFILE=/dev/null NVM_DIR="$HOME/.nvm" NODE_VERSION='' bash "$temp_dir/nvm.sh"
    [[ -s "$HOME/.nvm/nvm.sh" ]] || die "NVM installation failed."
fi

if ! command -v rustup >/dev/null 2>&1; then
    download https://sh.rustup.rs "$temp_dir/rustup.sh"
    sh "$temp_dir/rustup.sh" -y --no-modify-path --default-toolchain none
fi
rustup toolchain install "$RUST_VERSION" --profile minimal --component rustfmt --component clippy --component rust-analyzer --component rust-src
rustup default "$RUST_VERSION"

case "$(uname -s)" in
    Darwin) node_os=darwin; node_ext=tar.gz ;;
    Linux) node_os=linux; node_ext=tar.xz ;;
    *) die "Unsupported Node.js operating system." ;;
esac
case "$(uname -m)" in
    x86_64|amd64) node_arch=x64 ;;
    arm64|aarch64) node_arch=arm64 ;;
    *) die "Unsupported Node.js architecture: $(uname -m)" ;;
esac

node_platform="$node_os-$node_arch"
node_archive="node-v${NODE_VERSION}-${node_platform}.${node_ext}"
node_home="$HOME/.local/share/nodejs/node-v${NODE_VERSION}-${node_platform}"
if [[ ! -x "$node_home/bin/node" ]] || [[ $("$node_home/bin/node" --version) != "v$NODE_VERSION" ]]; then
    base_url="https://nodejs.org/dist/v${NODE_VERSION}"
    download "$base_url/$node_archive" "$temp_dir/$node_archive"
    download "$base_url/SHASUMS256.txt" "$temp_dir/SHASUMS256.txt"
    awk -v file="$node_archive" '$2 == file { print }' "$temp_dir/SHASUMS256.txt" > "$temp_dir/checksum"
    [[ -s "$temp_dir/checksum" ]] || die "No SHA-256 checksum found for $node_archive"
    if command -v shasum >/dev/null 2>&1; then
        (cd "$temp_dir" && shasum -a 256 -c checksum)
    else
        (cd "$temp_dir" && sha256sum -c checksum)
    fi
    tar -xf "$temp_dir/$node_archive" -C "$temp_dir"
    rm -rf "$node_home"
    mv "$temp_dir/node-v${NODE_VERSION}-${node_platform}" "$node_home"
fi

# Refuse to replace a directory that was not created as our managed Node link.
node_current="$HOME/.local/opt/node"
[[ ! -e "$node_current" || -L "$node_current" ]] || die "$node_current is not a symlink; move it aside first."
ln -sfn "$node_home" "$node_current"
export NPM_CONFIG_PREFIX="$HOME/.local"

if [[ ! -x "$HOME/.local/bin/npm" ]] || [[ $("$HOME/.local/bin/npm" --version) != "$NPM_VERSION" ]]; then
    "$node_current/bin/npm" install --global --no-audit --no-fund "npm@$NPM_VERSION"
fi
if ! command -v pnpm >/dev/null 2>&1 || [[ $(pnpm --version) != "$PNPM_VERSION" ]]; then
    "$HOME/.local/bin/npm" install --global --no-audit --no-fund "pnpm@$PNPM_VERSION"
fi
if [[ ! -d "$HOME/.local/lib/node_modules/commitizen" || ! -d "$HOME/.local/lib/node_modules/cz-git" ]]; then
    "$HOME/.local/bin/npm" install --global --no-audit --no-fund commitizen cz-git
fi
if [[ ! -x "$HOME/.bun/bin/bun" ]] || [[ $("$HOME/.bun/bin/bun" --version) != "$BUN_VERSION" ]]; then
    download https://bun.com/install "$temp_dir/bun.sh"
    BUN_INSTALL="$HOME/.bun" bash "$temp_dir/bun.sh" "bun-v$BUN_VERSION"
fi
