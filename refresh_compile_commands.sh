#!/usr/bin/env bash

# Copyright 2023 Ant Group Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT}"

readonly HEDRON_COMMIT="d7a28301d812aeafa36469343538dbc025cec196"
readonly HEDRON_REMOTE="https://github.com/hedronvision/bazel-compile-commands-extractor.git"
readonly WORKSPACE_BACKUP="$(mktemp)"
readonly BUILD_BACKUP="$(mktemp)"

cleanup() {
    rm -f external

    if [[ -f "${WORKSPACE_BACKUP}" ]]; then
        cp "${WORKSPACE_BACKUP}" WORKSPACE
        rm -f "${WORKSPACE_BACKUP}"
    fi

    if [[ -f "${BUILD_BACKUP}" ]]; then
        cp "${BUILD_BACKUP}" BUILD.bazel
        rm -f "${BUILD_BACKUP}"
    fi
}

trap cleanup EXIT

cp WORKSPACE "${WORKSPACE_BACKUP}"
cp BUILD.bazel "${BUILD_BACKUP}"

rm -rf external
rm -f compile_commands.json
ln -s bazel-out/../../../external external

python3 - <<'PY'
from pathlib import Path

workspace = Path("WORKSPACE")
text = workspace.read_text(encoding="utf-8")

stub_rule = """local_repository(
    name = "hedron_compile_commands",
    path = "third_party/hedron_compile_commands_stub",
)"""

git_rule = """load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "hedron_compile_commands",
    commit = "d7a28301d812aeafa36469343538dbc025cec196",
    remote = "https://github.com/hedronvision/bazel-compile-commands-extractor.git",
)"""

if stub_rule in text:
    text = text.replace(stub_rule, git_rule, 1)
elif 'name = "hedron_compile_commands"' not in text:
    text = text.rstrip() + "\n\n" + git_rule + "\n"

workspace.write_text(text, encoding="utf-8")
PY

if ! grep -q 'load("@hedron_compile_commands//:refresh_compile_commands.bzl", "refresh_compile_commands")' BUILD.bazel; then
    echo "missing refresh_compile_commands load in BUILD.bazel" >&2
    exit 1
fi

if ! grep -q 'name = "refresh_compile_commands"' BUILD.bazel; then
    cat <<'EOF' >> BUILD.bazel

refresh_compile_commands(
    name = "refresh_compile_commands",
    exclude_external_sources = True,
    exclude_headers = "external",
)
EOF
fi

bazel run //:refresh_compile_commands

if [[ ! -f compile_commands.json ]]; then
    echo "missing ${ROOT}/compile_commands.json" >&2
    exit 1
fi

python3 scripts/gen_clangd_compdb.py
