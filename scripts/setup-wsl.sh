#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

readonly REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly DOTFILES_DIR="$REPO_DIR/dotfiles"
readonly BACKUP_DIR="$HOME/nl-backups/$(date +%Y%m%d-%H%M%S)"

log() {
  printf '\n==> %s\n' "$1"
}

fail() {
  printf '\nError: %s\n' "$1" >&2
  exit 1
}

[[ "$(uname -s)" == "Linux" ]] || fail "Run this script inside WSL Ubuntu."
[[ "$EUID" -ne 0 ]] || fail "Run as your regular WSL user, not root."

mkdir -p "$HOME/.local/bin" "$HOME/.local/share" "$HOME/.local/opt"
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

for command in curl fish git stow; do
  command -v "$command" >/dev/null 2>&1 ||
    fail "Missing $command. Run setup-windows.ps1 first, or install WSL dependencies manually."
done

if [[ ! -x "$HOME/.local/bin/nvim" ]]; then
  log "Installing the current stable Neovim release"
  case "$(uname -m)" in
    x86_64) nvim_archive="nvim-linux-x86_64.tar.gz" ;;
    aarch64|arm64) nvim_archive="nvim-linux-arm64.tar.gz" ;;
    *) fail "No Neovim release archive is available for $(uname -m)." ;;
  esac

  nvim_tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$nvim_tmp_dir"' EXIT
  curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/$nvim_archive" \
    -o "$nvim_tmp_dir/neovim.tar.gz"
  tar -xzf "$nvim_tmp_dir/neovim.tar.gz" -C "$HOME/.local/opt"
  ln -sfn "$HOME/.local/opt/${nvim_archive%.tar.gz}/bin/nvim" "$HOME/.local/bin/nvim"
fi
[[ -x "$HOME/.local/bin/nvim" ]] || fail "Neovim installation failed."

log "Installing OpenCode"
if ! command -v opencode >/dev/null 2>&1; then
  curl -fsSL https://opencode.ai/install | bash
fi

log "Installing ani-cli"
ANI_CLI_DIR="$HOME/.local/share/ani-cli"
if [[ -d "$ANI_CLI_DIR/.git" ]]; then
  git -C "$ANI_CLI_DIR" pull --ff-only
else
  git clone https://github.com/pystardust/ani-cli.git "$ANI_CLI_DIR"
fi
ln -sfn "$ANI_CLI_DIR/ani-cli" "$HOME/.local/bin/ani-cli"

if command -v mpv.exe >/dev/null 2>&1; then
  cat > "$HOME/.local/bin/mpv" <<'EOF'
#!/usr/bin/env bash
exec mpv.exe "$@"
EOF
  chmod +x "$HOME/.local/bin/mpv"
else
  printf 'Warning: mpv.exe is not on the WSL PATH; ani-cli playback may not work yet.\n' >&2
fi

backup_unmanaged_directory() {
  local target_directory="$1"
  local managed_marker="$2"

  if [[ (-e "$target_directory" || -L "$target_directory") &&
        ! -L "$managed_marker" ]]; then
    mkdir -p "$BACKUP_DIR/.config"
    mv "$target_directory" "$BACKUP_DIR/.config/$(basename "$target_directory")"
    log "Backed up $target_directory to $BACKUP_DIR"
  fi
}

log "Backing up existing configurations"
backup_unmanaged_directory "$HOME/.config/fish" "$HOME/.config/fish/config.fish"
backup_unmanaged_directory "$HOME/.config/nvim" "$HOME/.config/nvim/init.lua"
backup_unmanaged_directory "$HOME/.config/wezterm" "$HOME/.config/wezterm/wezterm.lua"

log "Linking shared Fish, Neovim, and WezTerm configuration"
mkdir -p "$HOME/.config"
stow \
  --dir="$DOTFILES_DIR" \
  --target="$HOME" \
  --no-folding \
  --restow \
  fish nvim wezterm

log "WSL setup completed"
printf 'Open a new WezTerm window or run `exec fish -l` to start using Fish.\n'
printf 'ani-cli requires the player and tools installed by the Windows bootstrap.\n'
