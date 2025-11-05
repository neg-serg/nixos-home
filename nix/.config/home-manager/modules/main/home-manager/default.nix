{ lib, config, pkgs, ... }:
lib.mkMerge [
  {
    programs.home-manager.enable = true; # Let Home Manager install and manage itself.
    # Prefer built-in activation backup over shell aliases.
    # New HM option takes precedence; uses env $HOME_MANAGER_BACKUP_EXT when set.
    home-manager.backupFileExtension = "bck";
    home-manager.backupCommand = "${config.home.homeDirectory}/.local/bin/hm-backup";
  }
  # Small wrapper used by backupCommand: moves the existing path to path.$HOME_MANAGER_BACKUP_EXT
  (config.lib.neg.mkLocalBin "hm-backup" ''#!/usr/bin/env bash
set -euo pipefail

src=${1:?"usage: hm-backup <path>"}
ext="${HOME_MANAGER_BACKUP_EXT:-bck}"
dst="${src}.${ext}"

# Avoid clobbering: append timestamp if destination exists
if [ -e "$dst" ] || [ -L "$dst" ]; then
  ts=$(date +%Y%m%d-%H%M%S)
  dst="${src}.${ext}.${ts}"
fi

mv -- "$src" "$dst"
'' )
]
