#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../../scripts/lib/common.sh"

installed() { [[ $(dpkg-query -W -f='${Status}' "$1" 2>/dev/null || true) == 'install ok installed' ]]; }
missing=()
while IFS= read -r package; do
    [[ -z "$package" || "$package" == \#* ]] && continue
    installed "$package" || missing+=("$package")
done < "$DOTFILES_ROOT/platforms/linux/apt/packages.txt"

if ((${#missing[@]})); then
    sudo apt-get update
    available=()
    for package in "${missing[@]}"; do
        candidate=$(LC_ALL=C apt-cache policy "$package" | awk '/Candidate:/ { print $2 }')
        if [[ -n "$candidate" && "$candidate" != '(none)' ]]; then
            available+=("$package")
        else
            case "$package" in
                gh|git-delta|just|lazygit|zoxide) log "Using upstream release for $package." ;;
                *) die "No apt candidate for required package $package. Check your distribution repositories." ;;
            esac
        fi
    done
    ((${#available[@]} == 0)) || sudo apt-get install -y --no-upgrade "${available[@]}"
fi

mkdir -p "$HOME/.local/bin"
for pair in bat:batcat fd:fdfind; do
    name=${pair%%:*}; packaged=${pair#*:}
    if ! command -v "$name" >/dev/null 2>&1 && command -v "$packaged" >/dev/null 2>&1; then
        ln -sfn "$(command -v "$packaged")" "$HOME/.local/bin/$name"
    fi
done
[[ -x "$HOME/.local/bin/nvim" ]] || bash "$DOTFILES_ROOT/common/bin/update-neovim"

case "$(uname -m)" in
    x86_64|amd64) go_arch=amd64; rust_arch=x86_64; delta_target=x86_64-unknown-linux-musl; lazygit_arch=x86_64; min_arch=amd64 ;;
    arm64|aarch64) go_arch=arm64; rust_arch=aarch64; delta_target=aarch64-unknown-linux-gnu; lazygit_arch=arm64; min_arch=arm64 ;;
    *) die "Upstream Linux binaries support x86_64 and arm64." ;;
esac
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT
latest_asset() {
    curl --fail --silent --show-error --retry 3 "https://api.github.com/repos/$1/releases/latest" |
        jq -er --arg pattern "$2" '[.assets[] | select(.name | test($pattern; "i")) | .browser_download_url][0] // error("release asset missing")'
}
install_binary() {
    local repo="$1" pattern="$2" binary="$3" url dest binary_path
    command -v "$binary" >/dev/null 2>&1 && return 0
    url=$(latest_asset "$repo" "$pattern")
    dest="$temp_dir/$binary"
    mkdir -p "$dest"
    download "$url" "$dest/archive"
    if [[ "$url" == *.zip ]]; then unzip -q "$dest/archive" -d "$dest"; else tar -xzf "$dest/archive" -C "$dest"; fi
    binary_path=$(find "$dest" -type f -name "$binary" -print -quit)
    [[ -n "$binary_path" ]] || die "$repo archive does not contain $binary."
    install -m 0755 "$binary_path" "$HOME/.local/bin/$binary"
}
install_binary cli/cli "^gh_.*_linux_${go_arch}\\.tar\\.gz$" gh
install_binary jesseduffield/lazygit "^lazygit_.*_linux_${lazygit_arch}\\.tar\\.gz$" lazygit
install_binary dandavison/delta "^delta-.*-${delta_target}\\.tar\\.gz$" delta
install_binary casey/just "^just-.*-${rust_arch}-unknown-linux-musl\\.tar\\.gz$" just
install_binary ajeetdsouza/zoxide "^zoxide-.*-${rust_arch}-unknown-linux-musl\\.tar\\.gz$" zoxide
install_binary x-motemen/ghq "^ghq_linux_${go_arch}\\.zip$" ghq

if ! installed min && ! installed min-browser; then
    url=$(latest_asset minbrowser/min "^min-[0-9.]+-${min_arch}\\.deb$")
    download "$url" "$temp_dir/min.deb"
    chmod a+rx "$temp_dir"
    chmod a+r "$temp_dir/min.deb"
    sudo apt-get install -y "$temp_dir/min.deb"
fi
