{ lib, config, pkgs, ... }:
with lib;
mkIf (config.features.gui.enable or false) (lib.mkMerge [
  # Centralize simple local wrappers under ~/.local/bin, inline to avoid early config.lib recursion in hm‑eval
  {
    # Shim: swayimg actions helper — forward to legacy script if present
    home.file.".local/bin/swayimg-actions.sh" = {
      executable = true;
      force = true;
      text = ''#!/usr/bin/env bash
        set -euo pipefail
        if [ -x "$HOME/bin/swayimg-actions.sh" ]; then
          exec "$HOME/bin/swayimg-actions.sh" "$@"
        fi
        echo "swayimg-actions.sh shim: missing $HOME/bin/swayimg-actions.sh" >&2
        exit 127
      '';
    };
  }
  {
    # Shim: clipboard menu
    home.file.".local/bin/clip" = {
      executable = true;
      force = true;
      text = ''#!/usr/bin/env bash
        set -euo pipefail
        if [ -x "$HOME/bin/clip" ]; then
          exec "$HOME/bin/clip" "$@"
        fi
        # Fallback: cliphist + rofi + wl-copy
        if command -v cliphist >/dev/null 2>&1 && command -v rofi >/dev/null 2>&1 && command -v wl-copy >/dev/null 2>&1; then
          cliphist list | rofi -dmenu -matching fuzzy -i -p "Clipboard" -theme clip | cliphist decode | wl-copy || true
          exit 0
        fi
        echo "clip shim: missing $HOME/bin/clip and no fallback tools available" >&2
        exit 127
      '';
    };
  }
  {
    # Shim: rofi-lutris (menu)
    home.file.".local/bin/rofi-lutris" = {
      executable = true;
      force = true;
      text = ''#!/usr/bin/env bash
        set -euo pipefail
        if [ -x "$HOME/bin/rofi-lutris" ]; then
          exec "$HOME/bin/rofi-lutris" "$@"
        fi
        echo "rofi-lutris shim: missing $HOME/bin/rofi-lutris" >&2
        exit 127
      '';
    };
  }
  {
    # Shim: player control/launcher
    home.file.".local/bin/pl" = {
      executable = true;
      force = true;
      text = ''#!/usr/bin/env bash
        set -euo pipefail
        if [ -x "$HOME/bin/pl" ]; then
          exec "$HOME/bin/pl" "$@"
        fi
        # Best-effort fallback to playerctl/wpctl
        sub=${1:-}
        case "$sub" in
          cmd)
            shift || true
            case "${1:-}" in
              play-pause|pause|play|next|previous)
                exec playerctl "${1}"
                ;;
            esac
            ;;
          vol)
            shift || true
            case "${1:-}" in
              mute)
                exec wpctl set-mute @DEFAULT_AUDIO_SINK@ 1
                ;;
              unmute)
                exec wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
                ;;
            esac
            ;;
        esac
        # Fallback: pass through to playerctl
        if command -v playerctl >/dev/null 2>&1; then
          exec playerctl "$@"
        fi
        echo "pl shim: missing $HOME/bin/pl and no usable fallback" >&2
        exit 127
      '';
    };
  }
  {
    # Shim: wallpaper helper
    home.file.".local/bin/wl" = {
      executable = true;
      force = true;
      text = ''#!/usr/bin/env bash
        set -euo pipefail
        if [ -x "$HOME/bin/wl" ]; then
          exec "$HOME/bin/wl" "$@"
        fi
        echo "wl shim: missing $HOME/bin/wl" >&2
        exit 127
      '';
    };
  }
  {
    # Shim: music rename helper
    home.file.".local/bin/music-rename" = {
      executable = true;
      force = true;
      text = ''#!/usr/bin/env bash
        set -euo pipefail
        if [ -x "$HOME/bin/music-rename" ]; then
          exec "$HOME/bin/music-rename" "$@"
        fi
        echo "music-rename shim: missing $HOME/bin/music-rename" >&2
        exit 127
      '';
    };
  }
  {
    # Shim: unlock helper
    home.file.".local/bin/unlock" = {
      executable = true;
      force = true;
      text = ''#!/usr/bin/env bash
        set -euo pipefail
        if [ -x "$HOME/bin/unlock" ]; then
          exec "$HOME/bin/unlock" "$@"
        fi
        echo "unlock shim: missing $HOME/bin/unlock" >&2
        exit 127
      '';
    };
  }
  {
    # Shim: pic-notify (dunst script)
    home.file.".local/bin/pic-notify" = {
      executable = true;
      force = true;
      text = ''#!/usr/bin/env bash
        set -euo pipefail
        if [ -x "$HOME/bin/pic-notify" ]; then
          exec "$HOME/bin/pic-notify" "$@"
        fi
        # Dunst script compatibility: ignore silently if missing
        exit 0
      '';
    };
  }
  {
    # Shim: pic-dirs-list used by pic-dirs-runner service
    home.file.".local/bin/pic-dirs-list" = {
      executable = true;
      force = true;
      text = ''#!/usr/bin/env bash
        set -euo pipefail
        if [ -x "$HOME/bin/pic-dirs-list" ]; then
          exec "$HOME/bin/pic-dirs-list" "$@"
        fi
        echo "pic-dirs-list shim: missing $HOME/bin/pic-dirs-list" >&2
        exit 127
      '';
    };
  }
    home.file.".local/bin/sx" = {
      executable = true;
      force = true;
      text = (builtins.readFile ../../media/images/sx.sh);
    };
  }
  {
    home.file.".local/bin/sxivnc" = {
      executable = true;
      force = true;
      text = (builtins.readFile ../../media/images/sxivnc.sh);
    };
  }
  {
    # Shim: pypr-client -> pypr (Pyprland CLI)
    home.file.".local/bin/pypr-client" = {
      executable = true;
      force = true;
      text = ''#!/usr/bin/env bash
        set -euo pipefail
        exec ${lib.getExe' pkgs.pyprland "pypr"} "$@"'';
    };
  }
  {
    # Minimal editor shim: `v` opens files in Neovim
    home.file.".local/bin/v" = {
      executable = true;
      force = true;
      text = ''#!/usr/bin/env bash
        set -euo pipefail
        exec ${lib.getExe' pkgs.neovim "nvim"} "$@"'';
    };
  }
  {
    home.file.".local/bin/vid-info" = {
      executable = true;
      force = true;
      text = let
        sp = pkgs.python3.sitePackages;
        libpp = "${pkgs.neg.pretty_printer}/${sp}";
        libcolored = "${pkgs.python3Packages.colored}/${sp}";
      in ''#!/usr/bin/env python3

""" Video info pretty-printer.

Usage:
    vid-info FILES ...

Description:
    Prints a one-line summary per file (via ffprobe):
    - resolution (WxH), duration, size (MiB), overall bitrate (kbps),
      frame rate (fps), audio sample rate (kHz) and bitrate (kbps).

Options:
    FILES   input video files

Created by :: Neg
email :: <serg.zorg@gmail.com>
year :: 2022

"""

# Ensure packaged libraries are on sys.path (no env required)
import sys
sys.path.insert(0, '${libpp}')
sys.path.insert(0, '${libcolored}')

import os
import subprocess
import json
import math
import datetime
from enum import Enum
import shutil

from neg_pretty_printer import PrettyPrinter


class SizeUnit(Enum):
    """ Enum for size units """
    BYTES = 1
    KIB = 2
    MIB = 3
    GIB = 4
    TIB = 5


def convert_unit(size_in_bytes, unit):
    """ Convert the size from bytes to other units like KB, MB or GB"""
    if unit == SizeUnit.KIB:
        return size_in_bytes / 0x400
    if unit == SizeUnit.MIB:
        return size_in_bytes / (0x400 * 0x400)
    if unit == SizeUnit.GIB:
        return size_in_bytes / (0x400 * 0x400 * 0x400)
    if unit == SizeUnit.TIB:
        return size_in_bytes / (0x400 * 0x400 * 0x400 * 0x400)
    return size_in_bytes


def media_info(filename: str):
    """Extract media info by filename via ffprobe (JSON)."""
    if not shutil.which("ffprobe"):
        print("[vid-info] missing ffprobe in PATH", file=sys.stderr)
        return
    try:
        proc = subprocess.run(
            [
                "ffprobe",
                "-v",
                "error",
                "-show_format",
                "-show_streams",
                "-print_format",
                "json",
                str(filename),
            ],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
    except subprocess.CalledProcessError as e:
        print(f"[vid-info] ffprobe failed for {filename}: {e.stderr.strip()}", file=sys.stderr)
        return

    try:
        ret = json.loads(proc.stdout)
    except Exception as e:
        print(f"[vid-info] bad ffprobe JSON for {filename}: {e}", file=sys.stderr)
        return

    pp = PrettyPrinter
    out, vid_frame_rate = "", ""
    audio_bitrate, audio_sample_rate = "", ""
    if not ret.get('streams', []):
        return
    for stream in ret.get('streams', []):
        if stream.get('codec_type') == 'video':
            w = stream.get('width'); h = stream.get('height')
            if w and h:
                out += pp.wrap(f"{w}x{h}")
            afr = stream.get('avg_frame_rate') or ""
            try:
                num, den = afr.split('/') if '/' in afr else (afr, '1')
                num_f = float(num)
                den_f = float(den)
                if den_f:
                    vid_frame_rate = round(num_f / den_f)
            except Exception:
                pass
        if stream.get('codec_type') == 'audio':
            br = stream.get('bit_rate')
            if br:
                try:
                    audio_bitrate = math.floor(convert_unit(float(br), SizeUnit.KIB))
                except Exception:
                    audio_bitrate = ""
            sr = stream.get('sample_rate')
            try:
                if sr:
                    audio_sample_rate = float(sr) / 1000
            except Exception:
                audio_sample_rate = ""

    file_format = ret['format']

    out += pp.wrap(str(datetime.timedelta(
        seconds=math.floor(float(file_format['duration']))
    )))

    size = math.floor(convert_unit(float(file_format['size']), SizeUnit.MIB))
    out += pp.size(str(size), 'MIB')

    video_bitrate = math.floor(convert_unit(
        float(file_format['bit_rate']), SizeUnit.KIB
    ))
    out += pp.size(str(video_bitrate), 'kbps', pref='vidbrate')
    if vid_frame_rate:
        out += pp.wrap(str(vid_frame_rate), postfix='fps')

    if audio_sample_rate != "":
        out += pp.size(str(audio_sample_rate), 'K', pref="")
    if str(audio_bitrate):
        out += pp.size(str(audio_bitrate), 'kbps', pref='audbrate')

    print(out)


def main():
    """ Entry point """
    # Prefer docopt, but allow fallback to argv if not available
    try:
        from docopt import docopt  # type: ignore
        cmd_args = docopt(__doc__, version='1.0')
        files = cmd_args['FILES']
    except Exception:
        files = sys.argv[1:]

    pp = PrettyPrinter
    print_cwd, dir_name = False, ""

    for fname in files:
        if not os.path.exists(fname):
            continue
        if os.path.dirname(fname):
            dir_name = os.path.dirname(fname)
        elif print_cwd:
            dir_name = os.getcwd()

        dir_name_out = ""
        if dir_name and dir_name != '.':
            dir_name_out = pp.fancy_file(dir_name)
        input_name = os.path.basename(fname)
        print(f"{pp.prefix()}{dir_name_out}{pp.fancy_file(input_name)}")
        media_info(fname)


if __name__ == '__main__':
    main()
'';
    };
  }
])
