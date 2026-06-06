"""Small CMake-to-CcInfo import rule for heavy external libraries.

The rule intentionally behaves like a generated prebuilt: dependents consume a
stable CcInfo made of generated headers and static archives, while the CMake
action still has the upstream source tree and build options as inputs. If either
changes, Bazel reruns this action and refreshes the generated import.
"""

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")

def _dq(value):
    return "\"" + value.replace("\\", "\\\\").replace("\"", "\\\"").replace("`", "\\`") + "\""

def _cmake_defs(cache_entries):
    args = []
    for key in sorted(cache_entries.keys()):
        args.append("-D{}={}".format(key, _dq(cache_entries[key])))
    return " ".join(args)

def _verify_libs(static_libs):
    checks = []
    for lib in static_libs:
        checks.append("test -f \"$OUT_ROOT/lib/{lib}\"".format(lib = lib))
    return "\n".join(checks)

def _library_to_link(ctx, feature_configuration, cc_toolchain, lib):
    return cc_common.create_library_to_link(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        static_library = lib,
    )

def _cmake_static_import_impl(ctx):
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    include_dir = ctx.actions.declare_directory(ctx.label.name + "/include")
    cmake_dir = ctx.actions.declare_directory(ctx.label.name + "/lib/cmake")
    stamp = ctx.actions.declare_file(ctx.label.name + "/stamp.txt")
    static_libs = [
        ctx.actions.declare_file(ctx.label.name + "/lib/" + lib)
        for lib in ctx.attr.static_libs
    ]

    cmake_path = ctx.file._cmake_bin.path
    ninja_path = ctx.file._ninja_bin.path
    source_dir = ctx.file.cmake_lists.dirname
    out_root = include_dir.dirname

    command = """
set -euo pipefail

EXT_BUILD_ROOT="$PWD"
SRC_DIR="$EXT_BUILD_ROOT/{source_dir}"
OUT_ROOT="$EXT_BUILD_ROOT/{out_root}"
BUILD_TMPDIR="$OUT_ROOT.build_tmpdir"
EXT_BUILD_DEPS="$OUT_ROOT.ext_build_deps"
CMAKE_BIN="$EXT_BUILD_ROOT/{cmake_path}"
NINJA_BIN="$EXT_BUILD_ROOT/{ninja_path}"

rm -rf "$BUILD_TMPDIR" "$EXT_BUILD_DEPS" "$OUT_ROOT/include" "$OUT_ROOT/lib" "$OUT_ROOT/stamp.txt"
mkdir -p "$BUILD_TMPDIR" "$EXT_BUILD_DEPS/bin" "$OUT_ROOT/lib"
ln -sf "$CMAKE_BIN" "$EXT_BUILD_DEPS/bin/cmake"
ln -sf "$NINJA_BIN" "$EXT_BUILD_DEPS/bin/ninja"
export PATH="$EXT_BUILD_DEPS/bin:$PATH"
export CMAKE_BUILD_PARALLEL_LEVEL="{parallel}"

cat > "$BUILD_TMPDIR/crosstool_bazel.cmake" <<'EOF'
set(CMAKE_AR "/usr/bin/ar" CACHE FILEPATH "Archiver")
set(CMAKE_C_COMPILER "/usr/bin/gcc")
set(CMAKE_CXX_COMPILER "/usr/bin/gcc")
set(CMAKE_ASM_FLAGS_INIT "-U_FORTIFY_SOURCE -fstack-protector -Wall -Wunused-but-set-parameter -Wno-free-nonheap-object -fno-omit-frame-pointer -g0 -O2 -D_FORTIFY_SOURCE=1 -DNDEBUG -ffunction-sections -fdata-sections -fno-canonical-system-headers -Wno-builtin-macro-redefined -D__DATE__=\\\"redacted\\\" -D__TIMESTAMP__=\\\"redacted\\\" -D__TIME__=\\\"redacted\\\" -march=native -mtune=native -O3")
set(CMAKE_C_FLAGS_INIT "-U_FORTIFY_SOURCE -fstack-protector -Wall -Wunused-but-set-parameter -Wno-free-nonheap-object -fno-omit-frame-pointer -g0 -O2 -D_FORTIFY_SOURCE=1 -DNDEBUG -ffunction-sections -fdata-sections -fno-canonical-system-headers -Wno-builtin-macro-redefined -D__DATE__=\\\"redacted\\\" -D__TIMESTAMP__=\\\"redacted\\\" -D__TIME__=\\\"redacted\\\" -march=native -mtune=native -O3")
set(CMAKE_CXX_FLAGS_INIT "-U_FORTIFY_SOURCE -fstack-protector -Wall -Wunused-but-set-parameter -Wno-free-nonheap-object -fno-omit-frame-pointer -g0 -O2 -D_FORTIFY_SOURCE=1 -DNDEBUG -ffunction-sections -fdata-sections -std=c++14 -fno-canonical-system-headers -Wno-builtin-macro-redefined -D__DATE__=\\\"redacted\\\" -D__TIMESTAMP__=\\\"redacted\\\" -D__TIME__=\\\"redacted\\\" -march=native -mtune=native -O3 -std=c++17")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=gold -Wl,-no-as-needed -Wl,-z,relro,-z,now -B/usr/bin -pass-exit-codes -Wl,--gc-sections -lstdc++ -lm")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-shared -fuse-ld=gold -Wl,-no-as-needed -Wl,-z,relro,-z,now -B/usr/bin -pass-exit-codes -Wl,--gc-sections -lstdc++ -lm")
EOF

cd "$BUILD_TMPDIR"
"$CMAKE_BIN" {cache_defs} \\
  -DCMAKE_TOOLCHAIN_FILE="$BUILD_TMPDIR/crosstool_bazel.cmake" \\
  -DCMAKE_INSTALL_PREFIX="$OUT_ROOT" \\
  -DCMAKE_PREFIX_PATH="$EXT_BUILD_DEPS" \\
  -DCMAKE_RANLIB="" \\
  -G Ninja \\
  "$SRC_DIR"
"$CMAKE_BIN" --build . --config Release --target {targets} --parallel {parallel}
"$CMAKE_BIN" --install . --config Release

{verify_libs}

cat > "$OUT_ROOT/stamp.txt" <<'EOF'
name={name}
source_dir={source_dir}
targets={targets}
parallel={parallel}
cache_defs={cache_defs}
static_libs={static_libs_stamp}
EOF
""".format(
        cache_defs = _cmake_defs(ctx.attr.cache_entries),
        cmake_path = cmake_path,
        name = ctx.label.name,
        ninja_path = ninja_path,
        out_root = out_root,
        parallel = ctx.attr.parallel,
        source_dir = source_dir,
        static_libs_stamp = " ".join(ctx.attr.static_libs),
        targets = " ".join(ctx.attr.targets),
        verify_libs = _verify_libs(ctx.attr.static_libs),
    )

    inputs = depset(
        direct = ctx.files.srcs + [ctx.file.cmake_lists],
        transitive = [
            depset(ctx.files._cmake_data),
            depset(ctx.files._ninja_data),
            cc_toolchain.all_files,
        ],
    )
    outputs = [include_dir, cmake_dir, stamp] + static_libs

    ctx.actions.run_shell(
        inputs = inputs,
        outputs = outputs,
        command = command,
        mnemonic = "CmakeStaticImport",
        progress_message = "Refreshing CMake import {}".format(ctx.label),
        execution_requirements = {"requires-network": ""},
    )

    libraries = [
        _library_to_link(ctx, feature_configuration, cc_toolchain, lib)
        for lib in static_libs
    ]
    linker_input = cc_common.create_linker_input(
        owner = ctx.label,
        libraries = depset(direct = libraries),
    )
    compilation_context = cc_common.create_compilation_context(
        headers = depset(direct = [include_dir]),
        system_includes = depset(direct = [include_dir.path]),
    )
    linking_context = cc_common.create_linking_context(
        linker_inputs = depset(direct = [linker_input]),
    )

    return [
        DefaultInfo(files = depset(direct = outputs)),
        CcInfo(
            compilation_context = compilation_context,
            linking_context = linking_context,
        ),
    ]

cmake_static_import = rule(
    implementation = _cmake_static_import_impl,
    attrs = {
        "cache_entries": attr.string_dict(),
        "cmake_lists": attr.label(allow_single_file = True, mandatory = True),
        "parallel": attr.string(default = "8"),
        "srcs": attr.label_list(allow_files = True),
        "static_libs": attr.string_list(mandatory = True),
        "targets": attr.string_list(default = ["install"]),
        "_cc_toolchain": attr.label(default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")),
        "_cmake_bin": attr.label(
            allow_single_file = True,
            cfg = "exec",
            default = Label("@cmake-3.23.2-linux-x86_64//:cmake_bin"),
        ),
        "_cmake_data": attr.label(
            allow_files = True,
            cfg = "exec",
            default = Label("@cmake-3.23.2-linux-x86_64//:cmake_data"),
        ),
        "_ninja_bin": attr.label(
            allow_single_file = True,
            cfg = "exec",
            default = Label("@ninja_1.11.1_linux//:ninja_bin"),
        ),
        "_ninja_data": attr.label(
            allow_files = True,
            cfg = "exec",
            default = Label("@ninja_1.11.1_linux//:ninja_bin"),
        ),
    },
    fragments = ["cpp"],
    toolchains = use_cpp_toolchain(),
)
