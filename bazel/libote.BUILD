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
load("@yacl//bazel:cmake_import.bzl", "cmake_static_import")

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

COMMON_CACHE_ENTRIES = {
    "CMAKE_BUILD_TYPE": "Release",
    "CMAKE_INSTALL_LIBDIR": "lib",
    "CRYPTO_TOOLS_STD_VER": "20",
    "ENABLE_ALL_OT": "ON",
    "ENABLE_AVX": "ON",
    "ENABLE_AVX2": "ON",
    "ENABLE_AVX512": "ON",
    "ENABLE_BITPOLYMUL": "ON",
    "ENABLE_BOOST": "ON",
    "ENABLE_CIRCUITS": "ON",
    "ENABLE_COPROTO": "ON",
    "ENABLE_DELTA_IKNP": "ON",
    "ENABLE_DELTA_KOS": "ON",
    "ENABLE_FOLEAGE": "ON",
    "ENABLE_IKNP": "ON",
    "ENABLE_KKRT": "ON",
    "ENABLE_KOS": "ON",
    "ENABLE_MOCK_OT": "OFF",
    "ENABLE_MR": "ON",
    "ENABLE_MRR": "ON",
    "ENABLE_MRR_TWIST": "ON",
    "ENABLE_NET_LOG": "OFF",
    "ENABLE_NP": "ON",
    "ENABLE_OOS": "ON",
    "ENABLE_OPENSSL": "OFF",
    "ENABLE_PPRF": "ON",
    "ENABLE_RELIC": "ON",
    "ENABLE_REGULAR_DPF": "ON",
    "ENABLE_SILENTOT": "ON",
    "ENABLE_SILENT_VOLE": "ON",
    "ENABLE_SODIUM": "ON",
    "ENABLE_SOFTSPOKEN_OT": "ON",
    "ENABLE_SPARSE_DPF": "ON",
    "ENABLE_SSE": "ON",
    "ENABLE_TERNARY_DPF": "ON",
    "FETCH_AUTO": "ON",
    "FETCH_BITPOLYMUL": "ON",
    "FETCH_BOOST": "ON",
    "FETCH_COPROTO": "ON",
    "FETCH_LIBDIVIDE": "ON",
    "FETCH_RELIC": "ON",
    "FETCH_SODIUM": "ON",
    "CRYPTOTOOLS_BUILD_DIR": "$BUILD_TMPDIR/cryptoTools",
    "LIBOTE_STD_VER": "20",
    "LIBOTE_BUILD_DIR": "$BUILD_TMPDIR",
    "MACORO_TESTS": "OFF",
    "NO_KOS_WARNING": "ON",
    "NO_SYSTEM_PATH": "ON",
    "OC_THIRDPARTY_CLONE_DIR": "$BUILD_TMPDIR/out",
    "OC_THIRDPARTY_HINT": "$BUILD_TMPDIR/out/install/linux",
    "OC_THIRDPARTY_INSTALL_PREFIX": "$BUILD_TMPDIR/out/install/linux",
}

SUPPORT_STATIC_LIBS = [
    "libbitpolymul.a",
    "libboost_atomic.a",
    "libboost_chrono.a",
    "libboost_container.a",
    "libboost_date_time.a",
    "libboost_exception.a",
    "libboost_filesystem.a",
    "libboost_regex.a",
    "libboost_thread.a",
    "libcoproto.a",
    "libcryptoTools.a",
    "libmacoro.a",
    "librelic_s.a",
]

LIBOTE_ALL_STATIC_LIBS = [
    "liblibOTe.a",
    "libKyberOT.a",
    "libSimplestOT.a",
] + SUPPORT_STATIC_LIBS + [
    "libsodium.a",
]

LIBOTE_ALL_CACHE_ENTRIES = dict(COMMON_CACHE_ENTRIES)

LIBOTE_ALL_CACHE_ENTRIES.update({
    "ENABLE_MR_KYBER": "ON",
    "ENABLE_PIC": "OFF",
    "ENABLE_SIMPLESTOT": "ON",
    "ENABLE_SIMPLESTOT_ASM": "ON",
})

cmake_static_import(
    name = "libote_all",
    cache_entries = LIBOTE_ALL_CACHE_ENTRIES,
    cmake_lists = "CMakeLists.txt",
    srcs = [":all_srcs"],
    static_libs = LIBOTE_ALL_STATIC_LIBS,
    targets = [
        "install",
    ],
)

cc_library(
    name = "headers",
    deps = [
        ":libote_all",
    ],
)

cc_library(
    name = "all_deps",
    linkopts = [
        "-ldl",
        "-pthread",
    ],
    deps = [
        ":libote_all",
    ],
)
