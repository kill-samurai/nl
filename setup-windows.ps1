#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'

function Install-WingetPackage {
    param([Parameter(Mandatory)][string] $Id)

    Write-Host "==> Installing $Id"
    & winget install --id $Id --exact --silent `
        --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "winget failed to install $Id (exit code $LASTEXITCODE)."
    }
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget is required. Install or update App Installer, then rerun this script.'
}

$repoDir = (Resolve-Path (Join-Path $PSScriptRoot '.')).Path

Install-WingetPackage -Id 'wez.wezterm'
Install-WingetPackage -Id 'Mozilla.Firefox'
Install-WingetPackage -Id 'shinchiro.mpv'

$wezTermSource = Join-Path $repoDir 'dotfiles\wezterm\.config\wezterm'
$wezTermTarget = Join-Path $HOME '.config\wezterm'
$wezTermConfigDir = Split-Path $wezTermTarget -Parent
New-Item -ItemType Directory -Force -Path $wezTermConfigDir | Out-Null

if (Test-Path $wezTermTarget) {
    $target = Get-Item $wezTermTarget -Force
    $isExpectedJunction = $target.LinkType -eq 'Junction' -and
        $target.Target -eq $wezTermSource

    if (-not $isExpectedJunction) {
        $backupDir = Join-Path $HOME ("nl-backups\wezterm\{0}" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
        New-Item -ItemType Directory -Force -Path (Split-Path $backupDir -Parent) | Out-Null
        Move-Item -LiteralPath $wezTermTarget -Destination $backupDir
        Write-Host "==> Backed up existing WezTerm config to $backupDir"
    }
}

if (-not (Test-Path $wezTermTarget)) {
    New-Item -ItemType Junction -Path $wezTermTarget -Target $wezTermSource | Out-Null
}

$ubuntu = wsl --list --quiet 2>$null | ForEach-Object { ($_ -replace "`0", '').Trim() } |
    Where-Object { $_ -eq 'Ubuntu' }

if (-not $ubuntu) {
    Write-Host '==> Installing Ubuntu for WSL (this may require administrator approval and a restart).'
    & wsl --install --distribution Ubuntu --no-launch
    if ($LASTEXITCODE -ne 0) {
        throw "WSL Ubuntu installation failed (exit code $LASTEXITCODE)."
    }

    Write-Host @'
Ubuntu has been installed. Complete its one-time first launch and create your Linux user,
then rerun this script to finish the unattended package and dotfile setup.
'@
    exit 0
}

$wslUser = (& wsl --distribution Ubuntu -- whoami).Trim()
if ($LASTEXITCODE -ne 0 -or $wslUser -eq 'root') {
    throw 'Complete Ubuntu first launch and create a regular Linux user, then rerun this script.'
}

$wslRepoDir = (& wsl --distribution Ubuntu -- wslpath -u -a $repoDir).Trim()
if ($LASTEXITCODE -ne 0 -or -not $wslRepoDir) {
    throw 'Could not resolve the repository path inside Ubuntu WSL.'
}

Write-Host '==> Installing WSL command-line dependencies'
& wsl --distribution Ubuntu --user root -- bash -lc `
    'apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends build-essential ca-certificates curl ffmpeg fish fzf git grep nodejs npm python3 stow tar yt-dlp'
if ($LASTEXITCODE -ne 0) {
    throw "Installing Ubuntu packages failed (exit code $LASTEXITCODE)."
}

Write-Host '==> Setting up OpenCode, ani-cli, Fish, and Neovim dotfiles in WSL'
& wsl --distribution Ubuntu -- bash "$wslRepoDir/scripts/setup-wsl.sh"
if ($LASTEXITCODE -ne 0) {
    throw "WSL user setup failed (exit code $LASTEXITCODE)."
}

Write-Host '==> Windows and WSL setup completed'
