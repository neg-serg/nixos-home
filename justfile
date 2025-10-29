_hm_justfile := "nix/.config/home-manager/justfile"
_hm_dir := "nix/.config/home-manager"
nvim_dir := "nvim/.config/nvim"

fmt:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} fmt

check:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} check

lint:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} lint

hm-neg:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} hm-neg

hm-lite:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} hm-lite

clean-caches:
    just --justfile {{_hm_justfile}} --working-directory {{_hm_dir}} clean-caches

# Lint: ensure executables have shebang or recognizable extension
shebang-lint:
    bash -eu -o pipefail -c '
    fail=0
    while IFS= read -r -d "" f; do
    # Skip VCS and encrypted secrets
    case "$f" in */.git/*|*/secrets/crypted/*) continue;; esac
    first=$(head -n1 "$f" | tr -d "\r") || first=""
    # zsh completions must start with #compdef, allow those
    case "$first" in "#compdef"*) continue;; esac
    # Recognized by extension (identifies interpreter), or has shebang
    ext="${f##*.}"
    if [ "${first#\#!}" != "$first" ]; then
    continue
    fi
    case "$ext" in sh|bash|zsh|py|py3|nu|mjs) continue;; esac
    echo "Missing shebang and unknown extension: $f"
    fail=1
    done < <(find . -type f -perm -u=x -print0)
    if [ "$fail" -ne 0 ]; then
    echo "Shebang lint failed" >&2; exit 1; fi
    echo "Shebang lint OK"
    '

# Zsh syntax check (exclude git/secrets); checks *.zsh and zsh-shebang executables in bin/
zsh-syntax:
    bash -eu -o pipefail -c '
    fail=0
    # 1) All .zsh files under shell/.config/zsh
    if find shell/.config/zsh -type f -name "*.zsh" -print -quit 2>/dev/null | grep -q .; then
    while IFS= read -r -d "" f; do
    case "$f" in */.git/*|*/secrets/crypted/*) continue;; esac
    if ! zsh -n "$f"; then echo "zsh syntax error: $f" >&2; fail=1; fi
    done < <(find shell/.config/zsh -type f -name "*.zsh" -print0)
    fi
    # 2) Executables in bin/ with zsh shebang
    if [ -d bin ]; then
    while IFS= read -r -d "" f; do
    first=$(head -n1 "$f" | tr -d "\r") || first=""
    case "$first" in "#!"*zsh*)
    if ! zsh -n "$f"; then echo "zsh syntax error: $f" >&2; fail=1; fi ;;
    esac
    done < <(find bin -type f -perm -u=x -print0)
    fi
    if [ "$fail" -ne 0 ]; then exit 1; fi
    echo "Zsh syntax OK"
    '

# Run Neovim health checks headlessly
nvim-health:
    bash -eu -o pipefail -c '
    if ! command -v nvim >/dev/null 2>&1; then echo "Neovim not found (nvim)" >&2; exit 1; fi
    if [ "${USE_REPO_NVIM:-0}" = 1 ]; then
    export XDG_CONFIG_HOME="$PWD/nvim/.config"
    echo "Using repo Neovim config: $XDG_CONFIG_HOME"
    fi
    nvim --headless "+checkhealth" +qa
    '

# Optional: Lua lint for Neovim config via luacheck (if installed)
nvim-luacheck:
    bash -eu -o pipefail -c '
    if ! command -v luacheck >/dev/null 2>&1; then echo "luacheck not installed" >&2; exit 1; fi
    if [ ! -d "{{nvim_dir}}" ]; then echo "{{nvim_dir}} not found" >&2; exit 1; fi
    luacheck {{nvim_dir}} --codes --no-color
    '

# Optional: Lua static analysis via selene (if installed)
nvim-selene:
    bash -eu -o pipefail -c '
    if ! command -v selene >/dev/null 2>&1; then echo "selene not installed" >&2; exit 1; fi
    if [ ! -d "{{nvim_dir}}" ]; then echo "{{nvim_dir}} not found" >&2; exit 1; fi
    selene {{nvim_dir}}
    '

# Aggregate Neovim lint (runs what is available)
nvim-lint:
    -just nvim-luacheck || true
    -just nvim-selene || true

# Aggregate bin checks
bin-lint:
    just shebang-lint
    just zsh-syntax

# Prepare SteamVR for non-root use under Nix/Wayland
# - Grants CAP_SYS_NICE to vrcompositor and vrserver
# - Bypasses pkexec path in vrsetup.sh if vrcompositor already has caps
# - Forces Qt xcb platform for vrmonitor to avoid Wayland plugin crash
steamvr-fix:
    bash -eu -o pipefail -c '
    bases=( "$HOME/.local/share/Steam" "$HOME/.steam/steam" "$HOME/.steam/root" "$HOME/Steam" )
    found=()
    for b in "${bases[@]}"; do
      vr="$b/steamapps/common/SteamVR"
      if [ -x "$vr/bin/linux64/vrcompositor" ]; then found+=("$vr"); fi
    done
    if [ "${#found[@]}" -eq 0 ]; then
      echo "SteamVR not found under: ${bases[*]}" >&2; exit 1
    fi
    echo "SteamVR locations: ${found[*]}"

    for VR in "${found[@]}"; do
      L64="$VR/bin/linux64"
      BIN="$VR/bin"

      echo "[caps] Granting CAP_SYS_NICE to vrcompositor/vrserver in: $L64"
      if ! command -v setcap >/dev/null 2>&1; then echo "setcap not found" >&2; exit 1; fi
      sudo -n true 2>/dev/null || true
      sudo setcap 'cap_sys_nice+ep' "$L64/vrcompositor" "$L64/vrserver" || {
        echo "Warning: setcap failed, continuing" >&2
      }
      getcap -v "$L64/vrcompositor" "$L64/vrserver" || true

      # Patch launcher to call vrcompositor directly (avoid pkexec path)
      if [ -f "$L64/vrcompositor-launcher.sh" ] \
         && grep -q 'exec "$ROOT/vrcompositor-launcher"' "$L64/vrcompositor-launcher.sh"; then
        cp -a "$L64/vrcompositor-launcher.sh" "$L64/vrcompositor-launcher.sh.bak.$(date +%s)"
        sed -i 's|exec "$ROOT/vrcompositor-launcher" "$@"|exec "$ROOT/vrcompositor" "$@"|' "$L64/vrcompositor-launcher.sh"
        echo "[patch] vrcompositor-launcher.sh -> direct vrcompositor"
      fi

      # Patch vrsetup.sh to skip pkexec when vrcompositor already has caps
      VRS="$BIN/vrsetup.sh"
      if [ -f "$VRS" ] && ! grep -q 'skipping launcher setcap' "$VRS"; then
        TS=$(date +%s)
        cp -a "$VRS" "$VRS.bak.$TS"
        awk '
          BEGIN{inf=0}
          $0 ~ /^function SteamVRLauncherSetup\(\)/ { print; inf=1; next }
          inf==1 && $0 ~ /^\{/ {
            print;
            print "\t# Short-circuit: if vrcompositor already has CAP_SYS_NICE, skip pkexec/setcap on launcher";
            print "\tif [[ \"$(getcap $STEAMVR_TOOLSDIR/bin/linux64/vrcompositor 2>/dev/null)\" == *\"cap_sys_nice\"* ]]; then";
            print "\t\tlog \"vrcompositor has cap_sys_nice; skipping launcher setcap.\"";
            print "\t\treturn 0";
            print "\tfi";
            inf=2; next
          }
          { print }
        ' "$VRS.bak.$TS" > "$VRS.tmp"
        mv "$VRS.tmp" "$VRS" && chmod +x "$VRS"
        echo "[patch] vrsetup.sh -> short-circuit pkexec path"
      fi

      # Patch vrstartup.sh to use XCB platform (Wayland plugin missing in logs)
      VRT="$BIN/vrstartup.sh"
      if [ -f "$VRT" ] && ! grep -q '^export QT_QPA_PLATFORM=xcb' "$VRT"; then
        TS=$(date +%s)
        cp -a "$VRT" "$VRT.bak.$TS"
        awk '
          BEGIN{ins=0}
          {
            print $0
            if (ins==0 && $0 ~ /^VRBINDIR=/) {
              print "\n# Force Qt to use X11 (xcb) to avoid Wayland plugin issues";
              print "export QT_QPA_PLATFORM=xcb";
              ins=1
            }
          }
        ' "$VRT.bak.$TS" > "$VRT.tmp"
        mv "$VRT.tmp" "$VRT" && chmod +x "$VRT"
        echo "[patch] vrstartup.sh -> export QT_QPA_PLATFORM=xcb"
      fi

      # Prefer dGPU for Vulkan (multi-GPU: fix DRM lease mismatch)
      VRENV="$VR/bin/vrenv.sh"
      if [ -f "$VRENV" ] && ! grep -q '^export DRI_PRIME=1' "$VRENV"; then
        TS=$(date +%s)
        cp -a "$VRENV" "$VRENV.bak.$TS"
        awk '
          BEGIN{ins=0}
          { print $0 }
          /^export VRCOMPOSITOR_LD_LIBRARY_PATH=/ && ins==0 {
            print "# Prefer discrete GPU for Vulkan (helps DRM lease on multi-GPU)";
            print "export DRI_PRIME=1";
            # Do not force VK_ICD_FILENAMES blindly; users can set it manually if needed
            ins=1
          }
        ' "$VRENV.bak.$TS" > "$VRENV.tmp"
        mv "$VRENV.tmp" "$VRENV" && chmod +x "$VRENV"
        echo "[patch] vrenv.sh -> export DRI_PRIME=1"
      fi
    done

    echo "Done. Restart Steam, then launch SteamVR."
    '

# Restore original vrcompositor-launcher.sh if needed
steamvr-restore-launcher:
    bash -eu -o pipefail -c '
    bases=( "$HOME/.local/share/Steam" "$HOME/.steam/steam" "$HOME/.steam/root" "$HOME/Steam" )
    restored=0
    for b in "${bases[@]}"; do
      L64="$b/steamapps/common/SteamVR/bin/linux64"
      f="$L64/vrcompositor-launcher.sh"
      if [ -f "$f" ]; then
        bak=$(ls -1t "$f".bak.* 2>/dev/null | head -n1 || true)
        if [ -n "$bak" ] && [ -f "$bak" ]; then
          cp -a "$bak" "$f"
          chmod +x "$f"
          echo "Restored: $f from $bak"
          restored=1
        fi
      fi
    done
    if [ "$restored" -eq 0 ]; then echo "No backups found to restore"; fi
    '

# Run Steam with a clean Vulkan env for VR (disables overlays)
steamvr-run:
    bash -eu -o pipefail -c '
    export MANGOHUD=0 ENABLE_VKBASALT=0 VK_INSTANCE_LAYERS="" VK_LAYER_PATH=""
    # Prefer X11 for SDL mirror windows if needed; comment out to keep Wayland
    # export SDL_VIDEODRIVER=x11
    # If you have multiple DRM cards and HMD on card1, consider:
    # export WLR_DRM_DEVICES="/dev/dri/card1:/dev/dri/card0"
    exec steam
    '
