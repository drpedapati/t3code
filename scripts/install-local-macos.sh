#!/usr/bin/env bash
# Build an unsigned macOS desktop artifact and install it as a sibling of
# "T3 Code (Alpha).app" so local fork builds do not replace the official app.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="/opt/homebrew/bin:${HOME}/.vite-plus/bin:${PATH}"

APP_NAME="T3 Code (Dev)"
APP_DEST="${T3_LOCAL_APP_DEST:-/Applications/${APP_NAME}.app}"
ARCH="${T3_LOCAL_ARCH:-arm64}"
PLATFORM="${T3_LOCAL_PLATFORM:-mac}"
TARGET="${T3_LOCAL_TARGET:-dmg}"

# Packaged Dev uses a distinct bundle ID, Dock name, user data, and URL scheme.
# Local releases never publish to GitHub's updater channel.
export T3CODE_DESKTOP_SKIP_PUBLISH="${T3CODE_DESKTOP_SKIP_PUBLISH:-1}"

cd "$ROOT"

if [[ ! -x "${HOME}/.vite-plus/bin/vp" ]]; then
  echo "vp is not installed. Install Vite+ first: curl -fsSL https://vite.plus | bash" >&2
  exit 1
fi
if ! command -v cargo >/dev/null; then
  echo "cargo is required for the desktop resource monitor. Install with: brew install rust" >&2
  exit 1
fi

echo "==> installing workspace deps"
vp i

echo "==> building unsigned ${PLATFORM}/${TARGET} (${ARCH}) as ${APP_NAME}"
node scripts/build-desktop-artifact.ts \
  --platform "$PLATFORM" \
  --target "$TARGET" \
  --arch "$ARCH"

shopt -s nullglob
dmg="$(ls -t release/T3-Code-*-"${ARCH}".dmg 2>/dev/null | head -n 1 || true)"
if [[ -z "$dmg" || ! -f "$dmg" ]]; then
  echo "No DMG found under ${ROOT}/release" >&2
  exit 1
fi
echo "==> using ${dmg}"

mount_point="$(mktemp -d "${TMPDIR:-/tmp}/t3-local-dmg.XXXXXX")"
cleanup() {
  hdiutil detach "$mount_point" -quiet -force 2>/dev/null || true
  rmdir "$mount_point" 2>/dev/null || true
}
trap cleanup EXIT

hdiutil attach "$dmg" -nobrowse -readonly -noverify -mountpoint "$mount_point" >/dev/null

src_app=""
for candidate in "$mount_point"/*.app; do
  src_app="$candidate"
  break
done
if [[ -z "$src_app" || ! -d "$src_app" ]]; then
  echo "No .app bundle inside ${dmg}" >&2
  exit 1
fi

echo "==> installing ${src_app} -> ${APP_DEST}"
if pgrep -f "${APP_DEST}/Contents/MacOS/" >/dev/null 2>&1; then
  pkill -f "${APP_DEST}/Contents/MacOS/" >/dev/null 2>&1 || true
  sleep 1
fi
rm -rf "$APP_DEST"
mkdir -p "$(dirname "$APP_DEST")"
ditto "$src_app" "$APP_DEST"
xattr -cr "$APP_DEST" 2>/dev/null || true
# Ad-hoc sign so Gatekeeper treats this as a local build, not an unsigned download.
codesign --force --deep --sign - "$APP_DEST" >/dev/null

echo "==> installed ${APP_DEST}"
echo "    official Alpha app is untouched: /Applications/T3 Code (Alpha).app"
