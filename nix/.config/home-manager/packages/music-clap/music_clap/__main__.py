#!/usr/bin/env python3
"""Compute CLAP audio embeddings and optional text similarities.

Usage:
  music-clap [options] [PATH ...]

Description:
  Loads a LAION-CLAP model, extracts embeddings for provided audio files or
  directories, and optionally compares them to text prompts. Results can be
  emitted in human-readable form, JSON, or dumped as .npy vectors.
"""
import argparse
import json
import math
import os
import sys
from pathlib import Path
from typing import Iterable, List, Sequence

import numpy as np
import wget

torch_available = False
try:  # torch might fail to import if CUDA libs missing; defer error until use.
    import torch
    torch_available = True
except Exception as exc:  # pragma: no cover
    torch = None  # type: ignore

try:  # optional faster JSON
    import orjson  # type: ignore
except Exception:  # pragma: no cover
    orjson = None

try:
    from laion_clap import CLAP_Module
except Exception as exc:  # pragma: no cover
    print("[music-clap] laion_clap module not available. Ensure python env includes laion-clap.", file=sys.stderr)
    raise

AUDIO_EXTS = {
    ".mp3",
    ".flac",
    ".wav",
    ".ogg",
    ".m4a",
    ".opus",
    ".aac",
    ".wma",
    ".aiff",
    ".aif",
}
DEFAULT_TEXTS: Sequence[str] = ()


def walk_inputs(paths: Iterable[Path]) -> List[Path]:
    files: List[Path] = []
    for p in paths:
        if p.is_dir():
            for child in sorted(p.rglob("*")):
                if child.is_file() and child.suffix.lower() in AUDIO_EXTS:
                    files.append(child)
        elif p.is_file():
            files.append(p)
    return files


def normalize(vec: np.ndarray) -> np.ndarray:
    norm = float(np.linalg.norm(vec))
    if norm == 0.0:
        return vec
    return vec / norm


def cosine(a: np.ndarray, b: np.ndarray) -> float:
    return float(np.dot(normalize(a), normalize(b)))


def _resolve_checkpoint(args: argparse.Namespace, enable_fusion: bool) -> Path:
    if args.ckpt:
        return Path(os.path.expanduser(args.ckpt)).resolve()

    names = [
        "630k-best.pt",
        "630k-audioset-best.pt",
        "630k-fusion-best.pt",
        "630k-audioset-fusion-best.pt",
    ]
    model_id = args.model_id
    if model_id == -1:
        model_id = 3 if enable_fusion else 1
    url = "https://huggingface.co/lukewys/laion_clap/resolve/main/" + names[model_id]
    cache_root = Path(
        os.environ.get("LAION_CLAP_CACHE")
        or os.environ.get("XDG_CACHE_HOME")
        or (Path.home() / ".cache")
    ) / "laion_clap"
    cache_root.mkdir(parents=True, exist_ok=True)
    target = cache_root / names[model_id]
    if not target.exists():
        tmp = Path(wget.download(url, str(cache_root)))
        if tmp != target:
            tmp.replace(target)
    return target


def load_model(args: argparse.Namespace) -> CLAP_Module:
    if not torch_available:
        raise RuntimeError("PyTorch not available; install torch/torchaudio for laion-clap")
    device = args.device
    if device == "auto":
        device = "cuda:0" if torch.cuda.is_available() else "cpu"
    enable_fusion = args.fusion
    model = CLAP_Module(enable_fusion=enable_fusion, device=device, amodel=args.amodel)
    ckpt = _resolve_checkpoint(args, enable_fusion)
    if not ckpt.exists():
        print(f"[music-clap] checkpoint not available: {ckpt}", file=sys.stderr)
        sys.exit(2)
    model.load_ckpt(ckpt=str(ckpt), model_id=-1, verbose=not args.quiet)
    return model


def dump_embedding(path: Path, embedding: np.ndarray, dump_dir: Path) -> Path:
    dump_dir.mkdir(parents=True, exist_ok=True)
    target = dump_dir / (path.stem + ".npy")
    np.save(target, embedding)
    return target


def emit_json(data: dict) -> None:
    payload = orjson.dumps(data).decode("utf-8") if orjson else json.dumps(data, ensure_ascii=False)
    print(payload)


def emit_human(entry: dict, top_text: int) -> None:
    path = entry.get("path", "<unknown>")
    print(path)
    if "embedding_path" in entry:
        print(f"  stored: {entry['embedding_path']}")
    matches = entry.get("text_matches", [])
    if matches:
        limit = matches if top_text < 1 else matches[:top_text]
        for item in limit:
            print(f"  {item['score']:.3f}\t{item['text']}")


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser(description="Extract CLAP embeddings for audio files")
    ap.add_argument("paths", nargs="*", help="audio files or directories")
    ap.add_argument("--text", action="append", dest="texts", help="text prompt to compare against (repeatable)")
    ap.add_argument("--top", type=int, default=5, help="top-N text matches to display per track")
    ap.add_argument("--dump", type=Path, help="directory to store embeddings as .npy")
    ap.add_argument("--json", action="store_true", help="emit JSON per track")
    ap.add_argument("--device", default="auto", help="torch device (default: auto)")
    ap.add_argument("--amodel", default="HTSAT-tiny", help="audio encoder architecture (default: HTSAT-tiny)")
    ap.add_argument("--fusion", action="store_true", help="enable fusion model variant")
    ap.add_argument("--model-id", type=int, default=-1, help="pretrained checkpoint id to download (default: 3 fusion / 1 non-fusion)")
    ap.add_argument("--ckpt", type=str, help="path to a custom checkpoint (skips download)")
    ap.add_argument(
        "--torch-threads",
        type=int,
        default=None,
        help="set torch.set_num_threads (higher values utilise more CPU cores)",
    )
    ap.add_argument(
        "--torch-inter-op-threads",
        type=int,
        default=None,
        help="set torch.set_num_interop_threads for inter-operator parallelism",
    )
    ap.add_argument("--include-embedding", action="store_true", help="include embedding vector in output (JSON only)")
    ap.add_argument("--quiet", action="store_true", help="suppress model load logging")
    return ap.parse_args()


def main() -> int:
    args = parse_args()
    inputs = [Path(p).expanduser() for p in args.paths]
    if not inputs:
        print("[music-clap] no inputs provided", file=sys.stderr)
        return 1
    files = walk_inputs(inputs)
    if not files:
        print("[music-clap] no audio files found", file=sys.stderr)
        return 1

    if torch_available:
        if args.torch_threads:
            torch.set_num_threads(max(1, args.torch_threads))
        if args.torch_inter_op_threads:
            torch.set_num_interop_threads(max(1, args.torch_inter_op_threads))

    model = load_model(args)

    text_prompts = args.texts or list(DEFAULT_TEXTS)
    text_embeds = None
    if text_prompts:
        text_embeds = model.get_text_embedding(text_prompts, use_tensor=False)
        text_embeds = np.asarray(text_embeds)

    for audio_path in files:
        try:
            result = model.get_audio_embedding_from_filelist([str(audio_path)], use_tensor=False)
            if isinstance(result, np.ndarray):
                audio_embed = result[0]
            else:
                audio_embed = np.asarray(result)[0]
        except Exception as exc:
            print(f"[music-clap] failed processing {audio_path}: {exc}", file=sys.stderr)
            continue
        entry: dict = {"path": str(audio_path)}
        if args.dump:
            target = dump_embedding(audio_path, audio_embed, args.dump)
            entry["embedding_path"] = str(target)
        if args.include_embedding and args.json:
            entry["embedding"] = audio_embed.tolist()
        if text_embeds is not None:
            matches = []
            for j, prompt in enumerate(text_prompts):
                score = cosine(audio_embed, text_embeds[j])
                matches.append({"text": prompt, "score": score})
            matches.sort(key=lambda x: x["score"], reverse=True)
            entry["text_matches"] = matches
        if args.json:
            emit_json(entry)
        else:
            emit_human(entry, args.top)
    return 0


if __name__ == "__main__":  # pragma: no cover
    raise SystemExit(main())
