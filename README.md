# Personal Cross-Platform Setup

Automated setup for my personal Apple Silicon Macs and Windows PCs.

The Mac bootstrap installs applications with Homebrew and configures macOS. The Windows bootstrap installs WezTerm, Firefox, and mpv with WinGet, then sets up Fish, Neovim, OpenCode, and ani-cli in Ubuntu on WSL. Both use the shared Fish, Neovim, and WezTerm configuration.

## Supported systems

- Apple Silicon Mac (`arm64`)
- macOS
- Personal machines using the same iCloud Drive account
- Windows 10/11 with WinGet and Ubuntu on WSL 2

Intel Macs are intentionally unsupported.

Windows uses native WezTerm and Firefox, with Fish and the terminal tools inside WSL. The first WSL installation requires administrator approval, a restart if requested, and one interactive Ubuntu first launch to create the Linux user. Once Ubuntu is initialized, rerunning `setup-windows.ps1` installs packages without prompts.

## What the setup does

Running `personal.sh`:

1. Verifies that the Mac uses Apple Silicon.
2. Checks for the Xcode Command Line Tools.
3. Installs Homebrew when necessary.
4. Adds Homebrew to the Zsh login environment.
5. Installs Rosetta 2 when necessary.
6. Installs Homebrew applications and command-line tools from `Brewfile`.
7. Installs OpenCode and ani-cli.
8. Backs up existing Fish, Neovim, and WezTerm configurations.
9. Links the repository-managed dotfiles with GNU Stow.
10. Checks the iCloud wallpaper directory.
11. Applies my macOS preferences and standard Dock layout.

The script does not install macOS system updates or restart the Mac.

## Windows and WSL setup

Open PowerShell in the repository directory and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1
```

The script silently installs WezTerm, Firefox, and mpv through WinGet. If Ubuntu is not installed, it requests the WSL installation and exits. Complete Ubuntu's one-time first launch and create a Linux user, then rerun the command. The rerun installs WSL dependencies, OpenCode, ani-cli, and links the shared Fish, Neovim, and WezTerm config. Run it again later to refresh the setup.

The repository must be available on a local Windows drive. WezTerm's Windows config directory is linked to the repository; in WSL, GNU Stow links the dotfiles into the Linux home directory. WSL's Windows PATH integration is used to call the Windows `mpv.exe` player from ani-cli.

The first Neovim launch installs its plugins through lazy.nvim. No plugin update or lockfile sync is run during setup.

## New Mac setup

### 1. Sign into iCloud

Sign into the same Apple account used by the other personal Macs and enable iCloud Drive.

The WezTerm wallpaper collection should appear at:

```text
~/Library/Mobile Documents/com~apple~CloudDocs/WezTerm/backdrops
```

In Finder, mark the `backdrops` directory as **Keep Downloaded**.

WezTerm will still work if the wallpapers have not finished syncing, but it may initially use a plain background.

### 2. Install the Xcode Command Line Tools

Open Terminal and run:

```bash
xcode-select --install
```

Finish the installation before continuing.

### 3. Clone the repository

```bash
cd "$HOME"
git clone https://github.com/kill-samurai/nl.git
cd nl
```

Keep the repository at `~/nl`. The managed configuration files link back to this location.

### 4. Run the personal setup

Run the script as the regular macOS user, not with `sudo`:

```bash
./personal.sh
```

Homebrew may request the administrator password during its installation.

## Shell behavior

Zsh remains the macOS login shell.

WezTerm launches Fish from:

```text
/opt/homebrew/bin/fish
```

On Windows, WezTerm's default domain launches Fish in the Ubuntu WSL distribution.

On Apple Silicon, the Fish configuration places `/opt/homebrew/bin` before macOS system binaries. It also adds `~/.local/bin` for tools such as OpenCode and ani-cli. The Homebrew path is only added when present, so the same Fish config works in WSL.

## Applications and tools

The `Brewfile` is the macOS application and tool manifest. `personal.sh` installs OpenCode and ani-cli with their upstream installers. `setup-windows.ps1` is the Windows/WSL install manifest; the platform package IDs differ, while the target apps are documented here.

It currently manages:

- Fish
- GitHub CLI
- GNU Stow
- Neovim
- Node.js
- Latest stable Homebrew Python
- Ripgrep
- Coreutils
- htop
- sshpass
- OpenCode
- ani-cli, mpv, ffmpeg, fzf, and yt-dlp
- WezTerm
- Firefox
- OpenAI Codex
- VSCodium
- Sublime Text
- Brave Browser
- Google Chrome
- Signal
- Spotify
- WhatsApp
- Departure Mono Nerd Font
- JetBrains Mono Nerd Font

To install anything newly added to the Brewfile:

```bash
brew bundle --file="$HOME/nl/Brewfile"
```

## Dotfile management

The repository uses separate Stow packages:

```text
dotfiles/
├── fish/
│   └── .config/fish/
├── nvim/
│   └── .config/nvim/
└── wezterm/
    └── .config/wezterm/
```

Stow creates individual symlinks inside `~/.config`.

For example:

```text
~/.config/fish/config.fish
    -> ~/nl/dotfiles/fish/.config/fish/config.fish
```

Editing a managed file through `~/.config` therefore edits the repository copy directly.

After changing a configuration:

```bash
cd "$HOME/nl"
git status
git add dotfiles
git commit -m "Update configuration"
git push
```

## Private configuration

The following Fish files are intentionally excluded from Git:

```text
~/.config/fish/conf.d/ssh.fish
~/.config/fish/conf.d/local.fish
```

Use these files for machine-local settings and private SSH commands.

Never commit passwords, tokens, API keys, private keys, or commands containing embedded credentials.

## WezTerm wallpapers

Wallpapers are not stored in Git because the collection is too large.

WezTerm reads them directly from iCloud Drive:

```text
~/Library/Mobile Documents/com~apple~CloudDocs/WezTerm/backdrops
```

On Windows, put optional wallpapers in `dotfiles/wezterm/.config/wezterm/backdrops`. The directory is ignored by Git. WezTerm works without wallpapers on either platform.

The wallpaper rotation interval is configured in:

```text
dotfiles/wezterm/.config/wezterm/events/wallpaper-rotation.lua
```

## Dock layout

The setup replaces the existing Dock application layout with:

1. WezTerm
2. VSCodium
3. Signal
4. Safari
5. Mail

Finder and Trash remain managed by macOS. Downloads and recent applications are removed.

The previous Dock preferences file is backed up before the Dock is changed.

## Backups

When unmanaged configuration directories already exist, they are moved to:

```text
~/nl-backups/YYYYMMDD-HHMMSS/.config/
```

Dock preference backups are stored in:

```text
~/nl-backups/dock/
```

Review backups manually before deleting them.

## Running the setup again

The bootstrap is designed to be rerunnable:

```bash
cd "$HOME/nl"
git pull --ff-only
./personal.sh
```

Re-running it:

- Installs missing Brewfile dependencies.
- Refreshes the Stow symlinks.
- Reapplies macOS preferences.
- Resets the Dock to the standard layout.
- Preserves machine-local `ssh.fish` and `local.fish` files.

## Repository components

| Path | Purpose |
| --- | --- |
| `personal.sh` | Main personal Mac bootstrap |
| `Brewfile` | Homebrew applications and command-line tools |
| `setup-windows.ps1` | Unattended WinGet and WSL bootstrap (after first WSL user setup) |
| `scripts/setup-wsl.sh` | WSL OpenCode, ani-cli, and dotfile setup |
| `scripts/macos-defaults.sh` | macOS preferences |
| `scripts/configure-dock.sh` | Standard macOS Dock layout |
| `dotfiles/` | Fish, Neovim, and WezTerm configuration |

## Legacy scripts

The older work-machine and standalone WezTerm scripts have not yet been migrated to this new setup. Do not pipe them directly from GitHub into a shell.
