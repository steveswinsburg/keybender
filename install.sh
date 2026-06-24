#!/usr/bin/env bash

set -euo pipefail

REPO="steveswinsburg/keybender"
ASSET_URL="https://github.com/${REPO}/releases/latest/download/KeyBender.zip"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "KeyBender currently supports macOS only."
  exit 1
fi

mkdir -p "$INSTALL_DIR"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

curl -fsSL "$ASSET_URL" -o "$tmp_dir/KeyBender.zip"
unzip -q "$tmp_dir/KeyBender.zip" -d "$tmp_dir"
install -m 0755 "$tmp_dir/KeyBender" "$INSTALL_DIR/KeyBender"

echo "Installed KeyBender to $INSTALL_DIR/KeyBender"
echo "Run it with: $INSTALL_DIR/KeyBender"
