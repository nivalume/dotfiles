#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

mkdir -p "$HOME/.local/bin"
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

if [[ ! -x "$HOME/.local/bin/uv" ]]; then
    download https://astral.sh/uv/install.sh "$temp_dir/uv.sh"
    UV_INSTALL_DIR="$HOME/.local/bin" UV_NO_MODIFY_PATH=1 sh "$temp_dir/uv.sh"
fi

if [[ ! -x "$HOME/miniforge3/bin/conda" ]]; then
    case "$(uname -s)" in
        Darwin) conda_os=MacOSX ;;
        Linux) conda_os=Linux ;;
        *) die "Unsupported Miniforge operating system." ;;
    esac
    case "$(uname -s):$(uname -m)" in
        Darwin:arm64|Darwin:aarch64) conda_arch=arm64 ;;
        Linux:arm64|Linux:aarch64) conda_arch=aarch64 ;;
        Darwin:x86_64|Linux:x86_64) conda_arch=x86_64 ;;
        *) die "Unsupported Miniforge architecture: $(uname -m)" ;;
    esac
    installer="Miniforge3-${conda_os}-${conda_arch}.sh"
    download "https://github.com/conda-forge/miniforge/releases/latest/download/$installer" "$temp_dir/miniforge.sh"
    bash "$temp_dir/miniforge.sh" -b -p "$HOME/miniforge3"
fi
"$HOME/miniforge3/bin/conda" config --set auto_activate_base false
