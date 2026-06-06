# Copyright 2026 Ant Group Co., Ltd.
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
    name = "openfhe_cmake",
    cache_entries = {
        "BUILD_BENCHMARKS": "OFF",
        "BUILD_EXAMPLES": "OFF",
        "BUILD_SHARED": "ON",
        "BUILD_STATIC": "OFF",
        "BUILD_UNITTESTS": "OFF",
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_INSTALL_LIBDIR": "lib",
        "GIT_SUBMOD_AUTO": "OFF",
        "MATHBACKEND": "4",
        "NATIVE_SIZE": "64",
        "WITH_NATIVEOPT": "OFF",
        "WITH_NTL": "OFF",
        "WITH_OPENMP": "ON",
        "WITH_TCM": "OFF",
    },
    lib_source = ":all_srcs",
    out_include_dir = "include",
    out_lib_dir = "lib",
    out_shared_libs = [
        "libOPENFHEbinfhe.so",
        "libOPENFHEcore.so",
        "libOPENFHEpke.so",
    ],
    targets = [
        "install",
    ],
)

cc_library(
    name = "openfhe",
    includes = [
        "openfhe_cmake/include/openfhe",
        "openfhe_cmake/include/openfhe/binfhe",
        "openfhe_cmake/include/openfhe/core",
        "openfhe_cmake/include/openfhe/pke",
    ],
    linkopts = [
        "-ldl",
        "-fopenmp",
    ],
    deps = [
        ":openfhe_cmake",
    ],
)
