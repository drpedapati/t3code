# Local fork helpers. Official Alpha stays at /Applications/T3 Code (Alpha).app
# Daily upstream: `make sync` then `make release`.

VP := $(HOME)/.vite-plus/bin/vp
export PATH := /opt/homebrew/bin:$(HOME)/.vite-plus/bin:$(PATH)

APP_NAME := T3 Code (Dev)
APP_DEST ?= /Applications/$(APP_NAME).app
UPSTREAM ?= https://github.com/pingdotgg/t3code.git

.DEFAULT_GOAL := help
.PHONY: help sync deps build release open uninstall

help:
	@echo "make sync       Fetch and merge upstream/main (pingdotgg/t3code)"
	@echo "make deps       Install workspace dependencies (vp i)"
	@echo "make build      Unsigned macOS DMG for this machine"
	@echo "make release    Deps + unsigned DMG + install to $(APP_DEST) + open"
	@echo "make open       Launch $(APP_DEST)"
	@echo "make uninstall  Remove $(APP_DEST) (Alpha is left alone)"

sync:
	@git remote get-url upstream >/dev/null 2>&1 || git remote add upstream $(UPSTREAM)
	git fetch upstream main
	git merge --no-edit upstream/main

deps:
	$(VP) i

build:
	T3CODE_DESKTOP_SKIP_PUBLISH=1 \
	node scripts/build-desktop-artifact.ts --platform mac --target dmg --arch arm64

release:
	bash scripts/install-local-macos.sh
	$(MAKE) open

open:
	@test -d "$(APP_DEST)" || (echo "Missing $(APP_DEST). Run make release first." >&2; exit 1)
	open "$(APP_DEST)"

uninstall:
	@pkill -f "$(APP_DEST)/Contents/MacOS/" >/dev/null 2>&1 || true
	rm -rf "$(APP_DEST)"
	@echo "Removed $(APP_DEST)"
