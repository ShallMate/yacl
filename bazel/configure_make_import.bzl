"""Configure/make-to-CcInfo import rule for heavy external libraries."""

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")

def _dq(value):
    return "\"" + value.replace("\\", "\\\\").replace("\"", "\\\"").replace("`", "\\`") + "\""

def _sq(value):
    return "'" + value.replace("'", "'\\''") + "'"

def _env_exports(env):
    exports = []
    for key in sorted(env.keys()):
        exports.append("export {}={}".format(key, _sq(env[key])))
    return "\n".join(exports)

def _verify_libs(out_lib_dir, static_libs):
    checks = []
    for lib in static_libs:
        checks.append("test -f \"$OUT_ROOT/{}/{}\"".format(out_lib_dir, lib))
    return "\n".join(checks)

def _library_to_link(ctx, feature_configuration, cc_toolchain, lib):
    return cc_common.create_library_to_link(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        static_library = lib,
    )

def _configure_make_static_import_impl(ctx):
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    include_dir = ctx.actions.declare_directory(ctx.label.name + "/include")
    stamp = ctx.actions.declare_file(ctx.label.name + "/stamp.txt")
    static_libs = [
        ctx.actions.declare_file(ctx.label.name + "/" + ctx.attr.out_lib_dir + "/" + lib)
        for lib in ctx.attr.static_libs
    ]

    source_dir = ctx.file.configure_file.dirname
    out_root = include_dir.dirname
    configure_cmd = "./" + ctx.attr.configure_command
    prefix_arg = ""
    if ctx.attr.prefix_arg:
        prefix_arg = "{}\"$OUT_ROOT\"".format(ctx.attr.prefix_arg)

    command = """
set -euo pipefail

EXT_BUILD_ROOT="$PWD"
SRC_DIR="$EXT_BUILD_ROOT/{source_dir}"
OUT_ROOT="$EXT_BUILD_ROOT/{out_root}"
BUILD_TMPDIR="$OUT_ROOT.build_tmpdir"
WORK_SRC="$BUILD_TMPDIR/src"
MAKE_BIN="/usr/bin/make"

rm -rf "$BUILD_TMPDIR" "$OUT_ROOT/include" "$OUT_ROOT/{out_lib_dir}" "$OUT_ROOT/stamp.txt"
mkdir -p "$WORK_SRC" "$OUT_ROOT/{out_lib_dir}"
cp -L -R "$SRC_DIR/." "$WORK_SRC/"
chmod -R u+w "$WORK_SRC"

export LD_LIBRARY_PATH=
export PATH="/usr/lib/gcc/x86_64-linux-gnu/11:/usr/bin:/bin:$PATH"
export COMPILER_PATH="/usr/lib/gcc/x86_64-linux-gnu/11${{COMPILER_PATH:+:$COMPILER_PATH}}"
export LIBRARY_PATH="/usr/lib/gcc/x86_64-linux-gnu/11:/usr/lib/x86_64-linux-gnu${{LIBRARY_PATH:+:$LIBRARY_PATH}}"
{env_exports}

cd "$WORK_SRC"
{configure_prefix} {configure_cmd} {prefix_arg} {configure_options}
"$MAKE_BIN" {make_args} {targets}

{verify_libs}

cat > "$OUT_ROOT/stamp.txt" <<'EOF'
name={name}
source_dir={source_dir}
configure_command={configure_command}
configure_options={configure_options}
make_args={make_args}
targets={targets}
static_libs={static_libs_stamp}
EOF
""".format(
        configure_command = ctx.attr.configure_command,
        configure_cmd = configure_cmd,
        configure_options = " ".join([_dq(opt) for opt in ctx.attr.configure_options]),
        configure_prefix = ctx.attr.configure_prefix,
        env_exports = _env_exports(ctx.attr.env),
        make_args = " ".join([_sq(arg) for arg in ctx.attr.make_args]),
        name = ctx.label.name,
        out_lib_dir = ctx.attr.out_lib_dir,
        out_root = out_root,
        prefix_arg = prefix_arg,
        source_dir = source_dir,
        static_libs_stamp = " ".join(ctx.attr.static_libs),
        targets = " ".join([_sq(target) for target in ctx.attr.targets]),
        verify_libs = _verify_libs(ctx.attr.out_lib_dir, ctx.attr.static_libs),
    )

    inputs = depset(
        direct = ctx.files.srcs + [ctx.file.configure_file],
        transitive = [cc_toolchain.all_files],
    )
    outputs = [include_dir, stamp] + static_libs

    ctx.actions.run_shell(
        inputs = inputs,
        outputs = outputs,
        command = command,
        mnemonic = "ConfigureMakeStaticImport",
        progress_message = "Refreshing configure/make import {}".format(ctx.label),
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

configure_make_static_import = rule(
    implementation = _configure_make_static_import_impl,
    attrs = {
        "configure_command": attr.string(default = "configure"),
        "configure_file": attr.label(allow_single_file = True, mandatory = True),
        "configure_options": attr.string_list(),
        "configure_prefix": attr.string(default = ""),
        "env": attr.string_dict(),
        "make_args": attr.string_list(default = ["-j", "8"]),
        "out_lib_dir": attr.string(default = "lib"),
        "prefix_arg": attr.string(default = "--prefix="),
        "srcs": attr.label_list(allow_files = True),
        "static_libs": attr.string_list(mandatory = True),
        "targets": attr.string_list(default = ["install"]),
        "_cc_toolchain": attr.label(default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")),
    },
    fragments = ["cpp"],
    toolchains = use_cpp_toolchain(),
)
