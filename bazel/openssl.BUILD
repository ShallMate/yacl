# Copyright 2022 Ant Group Co., Ltd.
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

load("@rules_cc//cc:defs.bzl", "cc_library")
load("@yacl//bazel:configure_make_import.bzl", "configure_make_static_import")

# An openssl build file based on a snippet found in the github issue:
# https://github.com/bazelbuild/rules_foreign_cc/issues/337

# Read https://wiki.openssl.org/index.php/Compilation_and_Installation

filegroup(
    name = "all_srcs",
    srcs = glob(
        include = ["**"],
        exclude = ["*.bazel"],
    ),
)

CONFIGURE_OPTIONS = [
    # fixed openssl work dir for deterministic build.
    "--openssldir=/tmp/openssl",
    "--libdir=lib",
    "no-legacy",
    "no-weak-ssl-ciphers",
    "no-tests",
    "no-shared",
    "no-ui-console",
]

MAKE_TARGETS = [
    "build_libs",
    "install_dev",
]

configure_make_static_import(
    name = "openssl_import",
    configure_command = "Configure",
    configure_file = "Configure",
    configure_options = CONFIGURE_OPTIONS,
    env = select({
        "@platforms//os:macos": {
            "AR": "",
            "CC": "/usr/bin/cc",
        },
        "//conditions:default": {
            "AR": "/usr/bin/ar",
            "CC": "/usr/bin/gcc",
            "MODULESDIR": "",
        },
    }),
    make_args = ["-j", "4"],
    srcs = [":all_srcs"],
    static_libs = [
        "libssl.a",
        "libcrypto.a",
    ],
    targets = MAKE_TARGETS,
)

cc_library(
    name = "openssl",
    linkopts = select({
        "@platforms//os:linux": ["-ldl"],
        "//conditions:default": [],
    }),
    deps = [":openssl_import"],
    visibility = ["//visibility:public"],
)
