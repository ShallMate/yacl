# Copyright 2026 Guowei Ling.
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
load("@yacl//bazel:yacl.bzl", "yacl_cmake_external")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all_srcs",
    srcs = glob(
        ["**"],
        exclude = [
            "bazel-*",
            "**/.git/**",
        ],
    ),
)

yacl_cmake_external(
    name = "aby_cmake",
    cache_entries = {
        "ABY_BUILD_EXE": "OFF",
        "CMAKE_BUILD_TYPE": "Release",
    },
    lib_source = ":all_srcs",
    out_static_libs = [
        "libaby.a",
        "libencrypto_utils.a",
        "libotextension.a",
        "librelic_s.a",
    ],
    postfix_script = """
mkdir -p $$INSTALLDIR$$/include
cp -f extern/ENCRYPTO_utils/include/cmake_constants.h $$INSTALLDIR$$/include/cmake_constants.h
""",
    targets = [
        "install",
    ],
)

cc_library(
    name = "aby",
    linkopts = [
        "-ldl",
        "-pthread",
        "-lstdc++fs",
    ],
    deps = [
        ":aby_cmake",
        "@boost//:system",
        "@boost//:thread",
        "@com_github_openssl_openssl//:openssl",
        "@system_gmp//:gmpxx",
    ],
)

alias(
    name = "headers",
    actual = ":aby",
)
