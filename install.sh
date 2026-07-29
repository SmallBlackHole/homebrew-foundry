#!/usr/bin/env bash
# Foundry DevPack installer bootstrap (Linux).
#
# Thin bootstrap: download the signed native binary from the microsoft/foundry-toolkit release,
# verify its checksum offline, then hand off to it. The binary does all the actual provisioning.
# Published behind: https://aka.ms/foundry-devpack.sh
set -euo pipefail

# --- release coordinates ---
REPO="microsoft/foundry-toolkit"          # repo hosting the signed release assets
VERSION="0.0.6"
SHA256_LINUX_X64="547fb12083d381e6c7de6e2dbf7d059ecad3de441d38939ba3a54ba684d80b8e"
SHA256_LINUX_ARM64="8085f59777a02fb93e7b199d2f65198b98314e11917df3ba3f3bc95d2f0a99b1"

TAG="devpack-installer-${VERSION}"

# --- detect architecture ---
uname_m="$(uname -m)"
case "$uname_m" in
  x86_64 | amd64)  rid="linux-x64";   sha="$SHA256_LINUX_X64" ;;
  aarch64 | arm64) rid="linux-arm64"; sha="$SHA256_LINUX_ARM64" ;;
  *) echo "error: unsupported architecture '$uname_m' (need x86_64 or aarch64)" >&2; exit 1 ;;
esac

asset="foundry-devpack-${rid}"
url="https://github.com/${REPO}/releases/download/${TAG}/${asset}"

# --- prerequisites ---
command -v curl >/dev/null 2>&1 || { echo "error: 'curl' is required" >&2; exit 1; }

# --- download ---
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
bin="${tmp}/foundry-devpack"
echo "Downloading ${asset} (${VERSION})..."
curl -fsSL "$url" -o "$bin"

# --- verify checksum (baked in, offline) ---
if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$bin" | awk '{print $1}')"
elif command -v shasum >/dev/null 2>&1; then
  actual="$(shasum -a 256 "$bin" | awk '{print $1}')"
else
  echo "error: need 'sha256sum' or 'shasum' to verify the download" >&2; exit 1
fi
if [ "$actual" != "$sha" ]; then
  echo "error: checksum mismatch for ${asset}" >&2
  echo "  expected: $sha" >&2
  echo "  actual:   $actual" >&2
  exit 1
fi

# --- run (forwarding any extra args) ---
chmod +x "$bin"
echo "Running the Foundry DevPack installer..."
exec "$bin" install --channel curl "$@"
