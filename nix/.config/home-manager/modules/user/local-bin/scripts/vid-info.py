#!/usr/bin/env python3

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
sys.path.insert(0, '@LIBPP@')
sys.path.insert(0, '@LIBCOLORED@')

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
            w = stream.get('width')
            h = stream.get('height')
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
