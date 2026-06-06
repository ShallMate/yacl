# YACL

YACL (Yet Another Common crypto Library) is a C++ library for cryptography,
secure-computation primitives, networking, and IO. This repository also carries
example protocols under `examples/`.

The build is Bazel based. Local development defaults to building both the core
library and all examples, while downstream users can import only the core
dependency set through `bazel/repositories.bzl`.

## Repository Layout

- `yacl/`: core library code.
- `yacl/base/`: basic types and common utilities.
- `yacl/crypto/`: cryptographic primitives and tools.
- `yacl/kernel/`: higher-level crypto kernels such as OT and DPF.
- `yacl/io/`: streaming, file, and serialization utilities.
- `yacl/link/`: RPC-style multi-party communication utilities.
- `examples/`: protocol examples and research prototypes that may require
  heavier optional dependencies.
- `bazel/`: dependency declarations, external BUILD files, patches, and local
  build defaults.

## Prerequisites

Install the basic build tools before building:

```sh
sudo apt install build-essential git wget nasm autoconf automake libtool m4 perl binutils
```

Use Bazel or Bazelisk. The current workspace has been validated with Bazel
6.5.x; Bazel 9.x is not required.

The default build uses:

- C++17
- `-c opt`
- `-O3`
- `-march=native`
- `-mtune=native`
- `-fuse-ld=gold`
- `--jobs=HOST_CPUS`

If your machine does not support `gold` or native CPU tuning, adjust `.bazelrc`
before building.

`rules_foreign_cc` uses Bazel-managed CMake and Ninja toolchains. It does not
select CMake or Ninja from `/usr/local`. The few required autotools executables
are taken from `/usr/bin`.

## Build This Repository

For local development, build the core library and all examples with:

```sh
bazel build
```

By default this builds both:

```text
//yacl/...
//examples/...
```

The target list lives in `bazel/default_targets.txt`, and `.bazelrc` loads it
through the default `--config=all` setting.

Build outputs are written through Bazel's normal workspace symlinks:

```text
bazel-bin/
bazel-out/
bazel-testlogs/
```

The first build can take a while because external projects such as OpenSSL,
protobuf, libOTe, and example-only dependencies may need to be fetched and
compiled. Later builds are incremental. libOTe is exposed through a single
`@com_github_osu_crypto_libote//:all_deps` path backed by `libote_all`; the
target produces one generated C++ import from the libOTe source tree and build
configuration. If libOTe source, patches, or build options change, Bazel
refreshes that import. If you only change an example source file, Bazel should
rebuild only the affected example target and the dependencies that changed.

## Build A Specific Target

Since this repository makes bare `bazel build` mean "build everything", use
`--config=one` when you want a single explicit target:

```sh
bazel build --config=one //yacl/kernel/algorithms:base_ot
```

Examples:

```sh
bazel build --config=one //yacl/...
bazel build --config=one //examples/...
bazel build --config=one //examples/MiniPSI:minipsi_frontend
```

To inspect available example targets:

```sh
bazel query //examples/...
```

## Dependency Model

Dependencies are declared in `bazel/repositories.bzl`.

The main entry point is:

```python
yacl_deps(include_examples = False, include_dev = False)
```

The dependency groups are:

- Core dependencies: required by `yacl/` targets.
- Example dependencies: required only by `examples/` targets.
- Dev dependencies: local development helpers such as compile-command tooling.

This is intentionally lazy for downstream users. Calling `yacl_deps()` without
arguments does not register example-only repositories such as libOTe/APSI-related
deps, OpenFHE, RELIC, LLVM archives, or other heavy example dependencies.

This repository's own `WORKSPACE` calls:

```python
yacl_deps(
    include_dev = True,
    include_examples = True,
)
```

That keeps examples buildable locally. Downstream projects should keep the
default `yacl_deps()` unless they really need the examples.

The build also clears `LD_LIBRARY_PATH` for Bazel repository, action, and host
action environments in `.bazelrc`. This avoids accidentally linking against
libraries installed under paths such as `/usr/local/lib`.

## Use YACL From Another Bazel Workspace

For local testing, a downstream workspace can import this checkout as:

```python
workspace(name = "my_project")

local_repository(
    name = "yacl",
    path = "/path/to/yacl",
)

load("@yacl//bazel:repositories.bzl", "yacl_deps")

yacl_deps()

load("@com_github_nelhage_rules_boost//:boost/boost.bzl", "boost_deps")

boost_deps()

load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()

load(
    "@rules_foreign_cc//foreign_cc:repositories.bzl",
    "rules_foreign_cc_dependencies",
)

rules_foreign_cc_dependencies(
    native_tools_toolchains = [
        "@yacl//bazel:usr_bin_autoconf_toolchain",
        "@yacl//bazel:usr_bin_automake_toolchain",
        "@yacl//bazel:usr_bin_m4_toolchain",
        "@yacl//bazel:usr_bin_make_toolchain",
        "@yacl//bazel:usr_bin_pkgconfig_toolchain",
    ],
    register_built_tools = True,
    register_default_tools = True,
    register_preinstalled_tools = False,
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()
```

Then depend on YACL targets from your `BUILD.bazel` files:

```python
cc_binary(
    name = "demo",
    srcs = ["demo.cc"],
    deps = [
        "@yacl//yacl/kernel/algorithms:base_ot",
    ],
)
```

If your downstream build touches YACL targets that require Bazel
`cc_shared_library`, add this to the downstream `.bazelrc`:

```text
build --experimental_cc_shared_library
```

If the downstream project also wants to build YACL examples, opt in explicitly:

```python
yacl_deps(include_examples = True)
```

## Common Commands

Full local build:

```sh
bazel build
```

Analyze the full target set without compiling:

```sh
bazel build --nobuild
```

Build one target:

```sh
bazel build --config=one //yacl/kernel/algorithms:base_ot
```

Build only examples:

```sh
bazel build --config=one //examples/...
```

Run tests:

```sh
bazel test --config=one //yacl/...
```

## License

See `LICENSE` and `NOTICE.md`.
