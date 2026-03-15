#!/usr/bin/env python3

import json
import pathlib
import sys


def _is_under(path: pathlib.Path, root: pathlib.Path) -> bool:
    try:
        path.relative_to(root)
        return True
    except ValueError:
        return False


def _sanitize_arguments(args, directory: pathlib.Path):
    if not isinstance(args, list):
        return args

    sanitized = []
    i = 0
    while i < len(args):
        a = args[i]
        # Drop gcc-only warning flags and strict Werror for clangd parsing.
        if a in (
            "-Werror",
            "-Wunused-but-set-parameter",
            "-Wno-free-nonheap-object",
        ):
            i += 1
            continue

        if a in ("-I", "-isystem", "-iquote") and i + 1 < len(args):
            p_raw = args[i + 1]
            p = pathlib.Path(str(p_raw))
            abs_p = p if p.is_absolute() else (directory / p).resolve()

            # Bazel's glog system package symlinks include -> /usr/include.
            # Keeping that explicit -isystem /usr/include in front of libstdc++
            # breaks `#include_next <stdlib.h>` in clangd parsing.
            if str(abs_p) == "/usr/include":
                i += 2
                continue

            sanitized.append(a)
            sanitized.append(p_raw)
            i += 2
            continue

        sanitized.append(a)
        i += 1

    return sanitized


def main() -> int:
    workspace = pathlib.Path(__file__).resolve().parents[1]
    src = workspace / "compile_commands.json"
    out_dir = workspace / ".vscode"
    out = out_dir / "compile_commands.json"

    if not src.exists():
        print(f"missing {src}", file=sys.stderr)
        return 1

    with src.open("r", encoding="utf-8") as f:
        entries = json.load(f)

    filtered = []
    seen_files = set()

    for e in entries:
        file_field = str(e.get("file", ""))
        if not file_field:
            continue

        if file_field.startswith("external/"):
            continue
        if file_field.startswith("/usr/include/"):
            continue
        suffix = pathlib.Path(file_field).suffix.lower()
        if suffix not in {".cc", ".cpp", ".c", ".cxx"}:
            continue

        # Resolve to absolute path for filtering decisions.
        p = pathlib.Path(file_field)
        if p.is_absolute():
            abs_p = p
        else:
            directory = pathlib.Path(str(e.get("directory", workspace)))
            abs_p = (directory / p).resolve()

        # Drop system/external headers and anything outside workspace.
        if str(abs_p).startswith("/usr/include/"):
            continue
        if not _is_under(abs_p, workspace):
            continue
        if _is_under(abs_p, workspace / "external"):
            continue
        if _is_under(abs_p, workspace / "third_party"):
            continue

        file_key = str(abs_p)
        if file_key in seen_files:
            continue
        seen_files.add(file_key)

        copied = dict(e)
        copied["arguments"] = _sanitize_arguments(
            list(e.get("arguments", [])), pathlib.Path(str(e.get("directory", workspace)))
        )
        filtered.append(copied)

    out_dir.mkdir(parents=True, exist_ok=True)
    with out.open("w", encoding="utf-8") as f:
        json.dump(filtered, f)

    print(
        f"wrote {out} with {len(filtered)} entries "
        f"(from {len(entries)} source entries)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
