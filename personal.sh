#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BREW_BIN="/opt/homebrew/bin/brew"
readonly DOTFILES_DIR="$REPO_DIR/dotfiles"
readonly BACKUP_DIR="$HOME/nl-backups/$(date +%Y%m%d-%H%M%S)"

DOTFILE_PACKAGES=(
  fish
  nvim
  wezterm
)

log() {
  printf '\n==> %s\n' "$1"
}

fail() {
  printf '\nError: %s\n' "$1" >&2
  exit 1
}

handle_error() {
  printf '\nSetup failed on line %s while running: %s\n' \
    "$1" "$2" >&2
}

trap 'handle_error "$LINENO" "$BASH_COMMAND"' ERR

validate_system() {
  [[ "$(uname -s)" == "Darwin" ]] ||
    fail "This setup supports macOS only."

  [[ "$(uname -m)" == "arm64" ]] ||
    fail "This setup supports Apple Silicon Macs only."

  [[ "$EUID" -ne 0 ]] ||
    fail "Run this script as your normal user, not with sudo."

  [[ -f "$REPO_DIR/Brewfile" ]] ||
    fail "Brewfile not found in $REPO_DIR."

  [[ -d "$DOTFILES_DIR" ]] ||
    fail "Dotfiles directory not found in $REPO_DIR."
}

ensure_command_line_tools() {
  if ! xcode-select -p >/dev/null 2>&1; then
    log "Requesting Xcode Command Line Tools"
    xcode-select --install

    fail "Finish installing the Command Line Tools, then rerun this script."
  fi
}

ensure_homebrew() {
  if [[ ! -x "$BREW_BIN" ]]; then
    log "Installing Homebrew"

    /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  eval "$("$BREW_BIN" shellenv)"
}

configure_zsh_path() {
  local shellenv_line='eval "$(/opt/homebrew/bin/brew shellenv)"'

  touch "$HOME/.zprofile"

  if ! grep -Fqx "$shellenv_line" "$HOME/.zprofile"; then
    printf '\n%s\n' "$shellenv_line" >>"$HOME/.zprofile"
  fi
}

ensure_rosetta() {
  if ! pkgutil --pkg-info \
    com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
    log "Installing Rosetta 2"
    softwareupdate --install-rosetta --agree-to-license
  fi
}

install_packages() {
  log "Installing Homebrew packages"
  brew bundle --file="$REPO_DIR/Brewfile"
}

backup_unmanaged_directory() {
  local target_directory="$1"
  local managed_marker="$2"

  if [[ (-e "$target_directory" || -L "$target_directory") &&
        ! -L "$managed_marker" ]]; then
    mkdir -p "$BACKUP_DIR/.config"

    mv "$target_directory" \
      "$BACKUP_DIR/.config/$(basename "$target_directory")"

    log "Backed up $target_directory"
  fi
}

backup_existing_dotfiles() {
  backup_unmanaged_directory \
    "$HOME/.config/fish" \
    "$HOME/.config/fish/config.fish"

  backup_unmanaged_directory \
    "$HOME/.config/nvim" \
    "$HOME/.config/nvim/init.lua"

  backup_unmanaged_directory \
    "$HOME/.config/wezterm" \
    "$HOME/.config/wezterm/wezterm.lua"
}

restore_local_fish_files() {
  local filename
  local backup_file

  mkdir -p "$HOME/.config/fish/conf.d"

  for filename in ssh.fish local.fish; do
    backup_file="$BACKUP_DIR/.config/fish/conf.d/$filename"

    if [[ -f "$backup_file" ]]; then
      cp -p "$backup_file" "$HOME/.config/fish/conf.d/$filename"
    fi
  done
}

link_dotfiles() {
  log "Linking dotfiles"

  mkdir -p "$HOME/.config"

  stow \
    --dir="$DOTFILES_DIR" \
    --target="$HOME" \
    --no-folding \
    --restow \
    "${DOTFILE_PACKAGES[@]}"

  restore_local_fish_files
}

check_icloud_wallpapers() {
  local icloud_root="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
  local wallpapers="$icloud_root/WezTerm/backdrops"

  if [[ -d "$icloud_root" ]]; then
    mkdir -p "$wallpapers"
  else
    printf '\nWarning: iCloud Drive is not currently available.\n'
    printf 'WezTerm will work, but wallpapers may not load yet.\n'
  fi
}

main() {
  validate_system
  ensure_command_line_tools
  ensure_homebrew
  configure_zsh_path
  ensure_rosetta
  install_packages
  backup_existing_dotfiles
  link_dotfiles
  check_icloud_wallpapers
  "$REPO_DIR/scripts/macos-defaults.sh"
  "$REPO_DIR/scripts/configure-dock.sh"

  log "Personal Mac setup completed successfully"
}



main "$@"
