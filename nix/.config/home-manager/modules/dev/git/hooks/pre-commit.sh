#!/usr/bin/env bash
set -euo pipefail
# Repo root configured in HM (dotfilesRoot)
repo="${config_repo:-$HOME/.dotfiles}/nix/.config/home-manager"
# Run flake checks for HM (format docs, evals, etc.)
(cd "$repo" && nix flake check -L)
# Format the repo via treefmt (Nix, shell, Python, etc.)
(cd "$repo" && nix fmt)
# Sanity: reject whitespace errors in staged diff
git diff --check
# Stage any formatter changes
git add -u
