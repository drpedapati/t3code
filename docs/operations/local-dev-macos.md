# Local macOS Dev app

This is a private-fork runbook. It does not apply to upstream T3 Code releases.

## Purpose

Build and install `T3 Code (Dev)` beside the official Nightly or Alpha app.
The Dev app has its own bundle identity, `t3code-dev://` URL scheme, Electron
profile, and T3 state directory, so it does not share runtime state with the
official app.

| Item | Dev value |
| --- | --- |
| App bundle | `/Applications/T3 Code (Dev).app` |
| Bundle ID | `com.t3tools.t3code.dev` |
| URL scheme | `t3code-dev://` |
| T3 state | `~/.t3/dev` |
| Electron user data | `~/Library/Application Support/t3code-dev` |

## Build

Run this on an Apple Silicon Mac with Vite+ and Rust installed:

```sh
make build
```

The artifact is written to `release/T3-Code-<version>-arm64.dmg`. Local builds
do not publish to the GitHub updater channel.

## Replace an installed Dev app

Do not replace Nightly or Alpha. Quit Dev by its bundle ID, keep the prior
bundle as a rollback copy, then install and ad-hoc sign the new bundle:

```sh
osascript -e 'tell application id "com.t3tools.t3code.dev" to quit'
mv "/Applications/T3 Code (Dev).app" \
  "/Applications/T3 Code (Dev).app.previous-$(date +%Y%m%d-%H%M%S)"
```

Mount the new DMG, copy its `.app` bundle to
`/Applications/T3 Code (Dev).app`, then run:

```sh
xattr -cr "/Applications/T3 Code (Dev).app"
codesign --force --deep --sign - "/Applications/T3 Code (Dev).app"
open "/Applications/T3 Code (Dev).app"
```

Verify the new bundle before deleting the rollback copy:

```sh
/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' \
  "/Applications/T3 Code (Dev).app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' \
  "/Applications/T3 Code (Dev).app/Contents/Info.plist"
```

## Verified deployment

On 2026-08-26, version `0.0.34` was built and installed on `macbook14` as
`T3 Code (Dev)`. The prior `0.0.33` bundle was retained as a rollback copy.

## Fork boundary

Use this local build path only. The upstream release and relay workflows are
for the hosted product; do not trigger them for a personal Mac installation.
