set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

steamvr-fix:
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
      if [ -f "$L64/vrcompositor-launcher.sh" ] \
         && grep -q 'exec "$ROOT/vrcompositor-launcher"' "$L64/vrcompositor-launcher.sh"; then
        cp -a "$L64/vrcompositor-launcher.sh" "$L64/vrcompositor-launcher.sh.bak.$(date +%s)"
        sed -i 's|exec "$ROOT/vrcompositor-launcher" "$@"|exec "$ROOT/vrcompositor" "$@"|' "$L64/vrcompositor-launcher.sh"
        echo "[patch] vrcompositor-launcher.sh -> direct vrcompositor"
      fi
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
            ins=1
          }
        ' "$VRENV.bak.$TS" > "$VRENV.tmp"
        mv "$VRENV.tmp" "$VRENV" && chmod +x "$VRENV"
        echo "[patch] vrenv.sh -> export DRI_PRIME=1"
      fi
    done
    echo "Done. Restart Steam, then launch SteamVR."

steamvr-restore-launcher:
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

steamvr-run:
    export MANGOHUD=0 ENABLE_VKBASALT=0 VK_INSTANCE_LAYERS="" VK_LAYER_PATH=""
    exec steam
