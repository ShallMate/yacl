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

load("@rules_cc//cc:defs.bzl", "cc_import", "cc_library")

package(default_visibility = ["//visibility:public"])

ABY3_COPTS = [
    "-std=c++20",
    "-Wno-error",
    "-Wno-deprecated-declarations",
] + select({
    "@platforms//cpu:aarch64": [
        "-march=armv8-a+simd+crypto+crc",
    ],
    "//conditions:default": [
        "-maes",
        "-msse2",
        "-msse3",
        "-msse4.1",
        "-mavx",
        "-mavx2",
        "-mpclmul",
    ],
})

ABY3_STATIC_LIBS = [
    "libbitpolymul",
    "libboost_atomic",
    "libboost_date_time",
    "libboost_filesystem",
    "libboost_regex",
    "libboost_system",
    "libboost_thread",
    "libcoproto",
    "libcryptoTools",
    "liblibOTe",
    "libmacoro",
]

[
    cc_import(
        name = lib,
        static_library = "thirdparty/unix/lib/{}.a".format(lib),
    )
    for lib in ABY3_STATIC_LIBS
]

cc_library(
    name = "aby3",
    srcs = glob(["aby3/**/*.cpp"]),
    hdrs = glob([
        "aby3/**/*.h",
        "thirdparty/eigen-3.3.4/Eigen/**",
        "thirdparty/eigen-3.3.4/unsupported/Eigen/**",
        "thirdparty/unix/include/**",
    ]),
    copts = ABY3_COPTS,
    includes = [
        ".",
        "thirdparty/eigen-3.3.4",
        "thirdparty/unix/include",
    ],
    linkopts = [
        "-ldl",
        "-pthread",
    ],
    deps = [":" + lib for lib in ABY3_STATIC_LIBS] + [
        "@com_github_openssl_openssl//:openssl",
    ],
)

cc_library(
    name = "aby3_db",
    srcs = glob(["aby3-DB/**/*.cpp"]),
    hdrs = glob(["aby3-DB/**/*.h"]),
    copts = ABY3_COPTS,
    includes = [
        ".",
        "thirdparty/eigen-3.3.4",
        "thirdparty/unix/include",
    ],
    deps = [
        ":aby3",
    ],
)

cc_library(
    name = "aby3_ml",
    srcs = glob(
        ["aby3-ML/**/*.cpp"],
        exclude = [
            "aby3-ML/main-*.cpp",
        ],
    ),
    hdrs = glob(["aby3-ML/**/*.h"]),
    copts = ABY3_COPTS,
    includes = [
        ".",
        "thirdparty/eigen-3.3.4",
        "thirdparty/unix/include",
    ],
    deps = [
        ":aby3",
    ],
)

alias(
    name = "headers",
    actual = ":aby3",
)
