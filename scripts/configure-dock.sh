#!/usr/bin/env bash

set -Eeuo pipefail

readonly DOCKUTIL="/opt/homebrew/bin/dockutil"
readonly BACKUP_DIR="$HOME/nl-backups/dock"

DOCK_APPS=(
  "/Applications/WezTerm.app"
  "/Applications/VSCodium.app"
  "/Applications/Signal.app"
  "/Applications/Safari.app"
  "/System/Applications/Mail.app"
)

log() {
  printf '==> %s\n' "$1"
}

[[ "$(uname -s)" == "Darwin" ]] || {
  printf 'This script supports macOS only.\n' >&2
  exit 1
}

[[ "$EUID" -ne 0 ]] || {
  printf 'Run this script as your normal user, not with sudo.\n' >&2
  exit 1
}

[[ -x "$DOCKUTIL" ]] || {
  printf 'dockutil is not installed at %s.\n' "$DOCKUTIL" >&2
  exit 1
}

mkdir -p "$BACKUP_DIR"

if [[ -f "$HOME/Library/Preferences/com.apple.dock.plist" ]]; then
  cp "$HOME/Library/Preferences/com.apple.dock.plist" \
    "$BACKUP_DIR/com.apple.dock.$(date +%Y%m%d-%H%M%S).plist"
fi

log "Clearing existing Dock applications"

"$DOCKUTIL" --remove all --no-restart

for application in "${DOCK_APPS[@]}"; do
  if [[ -d "$application" ]]; then
    log "Adding $(basename "$application" .app)"
    "$DOCKUTIL" --add "$application" --no-restart
  else
    printf 'Warning: application not found: %s\n' "$application" >&2
  fi
done

defaults write com.apple.dock show-recents -bool false

killall Dock >/dev/null 2>&1 || true

log "Dock configuration completed"
