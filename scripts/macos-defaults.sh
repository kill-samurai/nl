#!/usr/bin/env bash

set -Eeuo pipefail

log() {
  printf '==> %s\n' "$1"
}

[[ "$(uname -s)" == "Darwin" ]] || {
  printf 'This script supports macOS only.\n' >&2
  exit 1
}

[[ "$(uname -m)" == "arm64" ]] || {
  printf 'This script supports Apple Silicon only.\n' >&2
  exit 1
}

[[ "$EUID" -ne 0 ]] || {
  printf 'Run this script as your normal user, not with sudo.\n' >&2
  exit 1
}

log "Configuring scrolling and trackpad behavior"

defaults write NSGlobalDomain \
  com.apple.swipescrolldirection -bool false

defaults write com.apple.AppleMultitouchTrackpad \
  Clicking -bool true

defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad \
  Clicking -bool true

defaults write NSGlobalDomain \
  com.apple.mouse.tapBehavior -int 1

defaults -currentHost write NSGlobalDomain \
  com.apple.mouse.tapBehavior -int 1

log "Configuring Finder"

defaults write NSGlobalDomain \
  AppleShowAllExtensions -bool true

defaults write com.apple.finder \
  FinderSpawnTab -bool false

log "Configuring the Dock"

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-time-modifier -float 0.2
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 64

log "Enabling dark mode"

if ! osascript -e \
  'tell application "System Events" to tell appearance preferences to set dark mode to true'; then
  printf 'Warning: dark mode could not be enabled automatically.\n' >&2
fi

killall Finder >/dev/null 2>&1 || true
killall Dock >/dev/null 2>&1 || true

log "macOS preferences applied"
