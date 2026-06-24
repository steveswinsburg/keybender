#!/usr/bin/env bash

set -euo pipefail

REPO="steveswinsburg/keybender"
ASSET_URL="https://github.com/${REPO}/releases/latest/download/KeyBender.zip"
CHECKSUM_URL="https://github.com/${REPO}/releases/latest/download/KeyBender.zip.sha256"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "KeyBender currently supports macOS only."
  exit 1
fi

for cmd in curl unzip install shasum; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd"
    exit 1
  fi
done

mkdir -p "$INSTALL_DIR"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

if ! curl -fsSL "$ASSET_URL" -o "$tmp_dir/KeyBender.zip"; then
  echo "Failed to download KeyBender from $ASSET_URL"
  echo "Check your network connection and confirm a release binary is available."
  exit 1
fi

if ! curl -fsSL "$CHECKSUM_URL" -o "$tmp_dir/KeyBender.zip.sha256"; then
  echo "Failed to download checksum from $CHECKSUM_URL"
  exit 1
fi

expected_checksum="$(awk '{print $1}' "$tmp_dir/KeyBender.zip.sha256")"
actual_checksum="$(shasum -a 256 "$tmp_dir/KeyBender.zip" | awk '{print $1}')"
if [[ -z "$expected_checksum" || "$expected_checksum" != "$actual_checksum" ]]; then
  echo "Checksum verification failed for downloaded KeyBender.zip"
  exit 1
fi

if ! unzip -q "$tmp_dir/KeyBender.zip" -d "$tmp_dir"; then
  echo "Failed to extract downloaded archive"
  exit 1
fi

if [[ ! -f "$tmp_dir/KeyBender" ]]; then
  echo "Downloaded archive did not contain KeyBender binary"
  exit 1
fi

if [[ ! -w "$INSTALL_DIR" ]]; then
  echo "Install directory is not writable: $INSTALL_DIR"
  echo "Use a writable INSTALL_DIR or run with elevated privileges."
  exit 1
fi

if ! install -m 0755 "$tmp_dir/KeyBender" "$INSTALL_DIR/KeyBender"; then
  echo "Failed to install KeyBender to $INSTALL_DIR (check permissions)"
  exit 1
fi

echo "Installed KeyBender to $INSTALL_DIR/KeyBender"
echo "Run it with: $INSTALL_DIR/KeyBender"
