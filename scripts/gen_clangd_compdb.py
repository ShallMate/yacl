#!/usr/bin/env python3

import json
import os
import pathlib
import sys


SOURCE_SUFFIXES = {".cc", ".cpp", ".c", ".cxx"}
HEADER_SUFFIXES = {".h", ".hh", ".hpp", ".hxx", ".inc", ".ipp", ".tcc"}
INCLUDE_FLAGS = ("-I", "-isystem", "-iquote")


def _is_under(path: pathlib.Path, root: pathlib.Path) -> bool:
    try:
        path.relative_to(root)
        return True
    except ValueError:
        return False


def _normalize_include_path(path_raw, directory: pathlib.Path):
    path = pathlib.Path(str(path_raw))
    if path.is_absolute():
        abs_path = path
    else:
        candidate = directory / path
        if path.parts and path.parts[0] == "external":
            candidate = directory / "bazel-out" / ".." / ".." / ".." / path
        abs_path = candidate.resolve()

    # Bazel's glog system package symlinks include -> /usr/include.
    # Keeping that explicit -isystem /usr/include in front of libstdc++
    # breaks `#include_next <stdlib.h>` in clangd parsing.
    if str(abs_path) == "/usr/include":
        return None

    return str(abs_path)


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

        if a in INCLUDE_FLAGS and i + 1 < len(args):
            abs_path = _normalize_include_path(args[i + 1], directory)
            if abs_path is not None:
                sanitized.append(a)
                sanitized.append(abs_path)
            i += 2
            continue

        matched_flag = next(
            (flag for flag in INCLUDE_FLAGS if a.startswith(flag) and a != flag),
            None,
        )
        if matched_flag is not None:
            abs_path = _normalize_include_path(a[len(matched_flag) :], directory)
            if abs_path is not None:
                sanitized.append(matched_flag)
                sanitized.append(abs_path)
            i += 1
            continue

        sanitized.append(a)
        i += 1

    return sanitized


def _logical_abs_path(path: pathlib.Path, directory: pathlib.Path) -> pathlib.Path:
    if path.is_absolute():
        return path

    # Preserve workspace-local symlink paths such as bazel-out/ while still
    # normalizing ".." segments for filtering and deduplication.
    return pathlib.Path(os.path.abspath(directory / path))


def _is_interesting_file(path: pathlib.Path) -> bool:
    suffix = path.suffix.lower()
    return suffix in SOURCE_SUFFIXES or suffix in HEADER_SUFFIXES or suffix == ""


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

        file_path = pathlib.Path(file_field)
        if not _is_interesting_file(file_path):
            continue

        # Convert to an absolute path for filtering decisions, but keep
        # workspace-visible symlink paths (e.g. bazel-out/) intact so clangd can
        # match files opened through those paths.
        directory = pathlib.Path(str(e.get("directory", workspace)))
        abs_p = _logical_abs_path(file_path, directory)

        # Keep workspace files, external/bazel-generated files reachable through
        # workspace symlinks, and installed headers in /usr/local/include.
        # System headers under /usr/include are intentionally omitted because
        # they are numerous and not useful for workspace diagnostics.
        if str(abs_p).startswith("/usr/include/"):
            continue
        if not (
            _is_under(abs_p, workspace) or str(abs_p).startswith("/usr/local/include/")
        ):
            continue

        file_key = str(abs_p)
        if file_key in seen_files:
            continue
        seen_files.add(file_key)

        copied = dict(e)
        copied["file"] = str(abs_p)
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
