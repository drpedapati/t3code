#!/usr/bin/env bash
# Build an unsigned macOS desktop artifact and install it as a sibling of
# "T3 Code (Alpha).app" so local fork builds do not replace the official app.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="/opt/homebrew/bin:${HOME}/.vite-plus/bin:${PATH}"

APP_NAME="${T3_LOCAL_APP_NAME:-T3 Code (Local)}"
APP_DEST="${T3_LOCAL_APP_DEST:-/Applications/${APP_NAME}.app}"
ARCH="${T3_LOCAL_ARCH:-arm64}"
PLATFORM="${T3_LOCAL_PLATFORM:-mac}"
TARGET="${T3_LOCAL_TARGET:-dmg}"

cd "$ROOT"

if [[ ! -x "${HOME}/.vite-plus/bin/vp" ]]; then
  echo "vp is not installed. Install Vite+ first: curl -fsSL https://vite.plus | bash" >&2
  exit 1
fi

echo "==> installing workspace deps"
vp i

echo "==> building unsigned ${PLATFORM}/${TARGET} (${ARCH})"
node scripts/build-desktop-artifact.ts \
  --platform "$PLATFORM" \
  --target "$TARGET" \
  --arch "$ARCH" \
  --verbose

shopt -s nullglob
dmgs=(release/T3-Code-*-"${ARCH}".dmg)
if ((${#dmgs[@]} == 0)); then
  echo "No DMG found under ${ROOT}/release" >&2
  exit 1
fi
# Newest by mtime.
dmg="$(ls -t "${dmgs[@]}" | head -n 1)"
echo "==> using ${dmg}"

mount_point="$(mktemp -d "${TMPDIR:-/tmp}/t3-local-dmg.XXXXXX")"
cleanup() {
  hdiutil detach "$mount_point" -quiet -force 2>/dev/null || true
  rmdir "$mount_point" 2>/dev/null || true
}
trap cleanup EXIT

hdiutil attach "$dmg" -nobrowse -readonly -mountpoint "$mount_point"

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
osascript -e "tell application \"${APP_NAME}\" to quit" >/dev/null 2>&1 || true
# Give the previous instance a moment to exit before replacing the bundle.
sleep 1
rm -rf "$APP_DEST"
mkdir -p "$(dirname "$APP_DEST")"
ditto "$src_app" "$APP_DEST"
# Unsigned local builds trip Gatekeeper on copy; clear quarantine.
xattr -cr "$APP_DEST" 2>/dev/null || true

echo "==> installed ${APP_DEST}"
echo "    official Alpha app is untouched: /Applications/T3 Code (Alpha).app"
