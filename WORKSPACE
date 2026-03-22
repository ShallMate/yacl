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

workspace(name = "yacl")

load("//bazel:repositories.bzl", "yacl_deps")

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
    register_built_tools = False,
    register_default_tools = False,
    register_preinstalled_tools = True,
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

local_repository(
    name = "com_github_google_shell",
    path = "third_party/com_github_google_shell",
)

new_local_repository(
    name = "com_github_google_glog",
    path = "/usr",
    build_file_content = """
cc_import(
    name = "glog_shared",
    shared_library = "lib/x86_64-linux-gnu/libglog.so",
)

cc_import(
    name = "libunwind_shared",
    shared_library = "lib/x86_64-linux-gnu/libunwind.so.8",
)

cc_import(
    name = "libunwind_x86_64_shared",
    shared_library = "lib/x86_64-linux-gnu/libunwind-x86_64.so.8",
)

cc_library(
    name = "glog",
    hdrs = glob(["include/glog/**/*.h"]),
    includes = ["include"],
    deps = [
        ":glog_shared",
        ":libunwind_shared",
        ":libunwind_x86_64_shared",
    ],
    linkopts = [
        "-lgflags",
    ],
    visibility = ["//visibility:public"],
)
    """,
)

new_local_repository(
    name = "local_apsi",
    path = "/usr/local",
    build_file_content = """
cc_import(
    name = "apsi_static",
    static_library = "lib/libapsi-0.11.a",
)

cc_library(
    name = "apsi",
    hdrs = glob(["include/APSI-0.11/**/*.h"]),
    includes = ["include/APSI-0.11"],
    deps = [
        ":apsi_static",
        "@kuku//:kuku",
        "@local_jsoncpp//:jsoncpp",
        "@local_log4cplus//:log4cplus",
        "@local_zmq//:zmq",
        "@seal//:seal",
    ],
    visibility = ["//visibility:public"],
)
    """,
)

new_local_repository(
    name = "seal",
    path = "/usr/local",
    build_file_content = """
cc_import(
    name = "seal_static",
    static_library = "lib/libseal-4.1.a",
)

cc_library(
    name = "seal",
    hdrs = glob([
        "include/SEAL-4.1/**/*.h",
        "include/SEAL-4.1/gsl/**",
    ]),
    includes = ["include/SEAL-4.1"],
    deps = [":seal_static"],
    visibility = ["//visibility:public"],
)
    """,
)

new_local_repository(
    name = "kuku",
    path = "/usr/local",
    build_file_content = """
cc_import(
    name = "kuku_static",
    static_library = "lib/libkuku-2.1.a",
)

cc_library(
    name = "kuku",
    hdrs = glob(["include/Kuku-2.1/**/*.h"]),
    includes = ["include/Kuku-2.1"],
    deps = [":kuku_static"],
    visibility = ["//visibility:public"],
)
    """,
)

new_local_repository(
    name = "openfhe",
    path = "/usr/local",
    build_file_content = """
OPENFHE_LIBS = glob([
    "lib/libOPENFHE*.so*",
    "lib/libOPENFHE*.a*",
    "lib64/libOPENFHE*.so*",
    "lib64/libOPENFHE*.a*",
])

cc_library(
    name = "openfhe",
    hdrs = glob([
        "include/openfhe/**/*.h",
        "include/openfhe/**/*.hpp",
    ]),
    # 关键：把 .so/.a 声明为 srcs，Bazel 才会把它们作为链接输入带进 sandbox
    srcs = OPENFHE_LIBS,
    includes = [
        "include",
        "include/openfhe",
        "include/openfhe/core",
        "include/openfhe/pke",
        "include/openfhe/binfhe",
    ],
    # 这里只保留"系统依赖库"，OpenFHE 自己的库文件已经在 srcs 里了
    linkopts = [
        "-ldl",
        "-lgomp",
        "-lntl",
    ],
    visibility = ["//visibility:public"],
)
""",
)

# RELIC library for One-Pass-PSI
new_local_repository(
    name = "local_relic",
    path = "/home/lgw/One-Pass-PSI-from-Pairings/out/install/linux",
    build_file_content = """
RELIC_LIBS = glob([
    "lib/librelic*.a",
    "lib/librelic*.so*",
])

cc_library(
    name = "relic",
    hdrs = glob(["include/relic/**/*.h"]),
    srcs = RELIC_LIBS,
    includes = ["include/relic"],
    visibility = ["//visibility:public"],
)
""",
)

new_local_repository(
    name = "local_volepsi",
    path = "/home/lgw/sp26/mPSI/out/install/linux",
    build_file_content = """
cc_library(
    name = "headers",
    hdrs = glob([
        "include/**/*",
        "include/sparsehash/*",
        "include/sparsehash/**/*",
    ]),
    includes = ["include"],
    visibility = ["//visibility:public"],
)

cc_import(
    name = "libote_static",
    static_library = "lib/liblibOTe.a",
    alwayslink = True,
)

cc_import(
    name = "cryptotools_static",
    static_library = "lib/libcryptoTools.a",
    alwayslink = True,
)

cc_import(
    name = "macoro_static",
    static_library = "lib/libmacoro.a",
    alwayslink = True,
)

cc_import(
    name = "coproto_static",
    static_library = "lib/libcoproto.a",
    alwayslink = True,
)

cc_import(
    name = "volepsi_static",
    static_library = "lib/libvolePSI.a",
    alwayslink = True,
)

cc_import(
    name = "bitpolymul_static",
    static_library = "lib/libbitpolymul.a",
    alwayslink = True,
)

cc_import(
    name = "sodium_static",
    static_library = "lib/libsodium.a",
    alwayslink = True,
)

cc_import(
    name = "boost_system_static",
    static_library = "lib/libboost_system.a",
    alwayslink = True,
)

cc_import(
    name = "boost_thread_static",
    static_library = "lib/libboost_thread.a",
    alwayslink = True,
)

cc_import(
    name = "boost_filesystem_static",
    static_library = "lib/libboost_filesystem.a",
    alwayslink = True,
)

cc_import(
    name = "boost_regex_static",
    static_library = "lib/libboost_regex.a",
    alwayslink = True,
)

cc_import(
    name = "boost_atomic_static",
    static_library = "lib/libboost_atomic.a",
    alwayslink = True,
)

cc_import(
    name = "boost_datetime_static",
    static_library = "lib/libboost_date_time.a",
    alwayslink = True,
)

cc_library(
    name = "support_libs",
    deps = [
        ":bitpolymul_static",
        ":boost_atomic_static",
        ":boost_datetime_static",
        ":boost_filesystem_static",
        ":boost_regex_static",
        ":boost_system_static",
        ":boost_thread_static",
        ":coproto_static",
        ":cryptotools_static",
        ":libote_static",
        ":macoro_static",
        ":sodium_static",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "static_libs",
    deps = [
        ":support_libs",
        ":volepsi_static",
    ],
    visibility = ["//visibility:public"],
)
""",
)

new_local_repository(
    name = "local_circuitpsu1_volepsi",
    path = "/home/lgw/circuitPSU1/libs/volepsi",
    build_file_content = """
cc_library(
    name = "headers",
    hdrs = glob([
        "include/**/*.h",
        "include/**/*.hpp",
        "include/**/*.hh",
    ]),
    includes = ["include"],
    visibility = ["//visibility:public"],
)

cc_import(
    name = "bitpolymul_static",
    static_library = "lib/libbitpolymul.a",
    alwayslink = True,
)

cc_import(
    name = "boost_atomic_static",
    static_library = "lib/libboost_atomic.a",
    alwayslink = True,
)

cc_import(
    name = "boost_datetime_static",
    static_library = "lib/libboost_date_time.a",
    alwayslink = True,
)

cc_import(
    name = "boost_filesystem_static",
    static_library = "lib/libboost_filesystem.a",
    alwayslink = True,
)

cc_import(
    name = "boost_regex_static",
    static_library = "lib/libboost_regex.a",
    alwayslink = True,
)

cc_import(
    name = "boost_system_static",
    static_library = "lib/libboost_system.a",
    alwayslink = True,
)

cc_import(
    name = "boost_thread_static",
    static_library = "lib/libboost_thread.a",
    alwayslink = True,
)

cc_import(
    name = "coproto_static",
    static_library = "lib/libcoproto.a",
    alwayslink = True,
)

cc_import(
    name = "cryptotools_static",
    static_library = "lib/libcryptoTools.a",
    alwayslink = True,
)

cc_import(
    name = "libote_static",
    static_library = "lib/liblibOTe.a",
    alwayslink = True,
)

cc_import(
    name = "macoro_static",
    static_library = "lib/libmacoro.a",
    alwayslink = True,
)

cc_import(
    name = "relic_static",
    static_library = "lib/librelic_s.a",
    alwayslink = True,
)

cc_import(
    name = "sodium_static",
    static_library = "lib/libsodium.a",
    alwayslink = True,
)

cc_import(
    name = "volepsi_static",
    static_library = "lib/libvolePSI.a",
    alwayslink = True,
)

cc_library(
    name = "static_libs",
    deps = [
        ":bitpolymul_static",
        ":boost_atomic_static",
        ":boost_datetime_static",
        ":boost_filesystem_static",
        ":boost_regex_static",
        ":boost_system_static",
        ":boost_thread_static",
        ":coproto_static",
        ":cryptotools_static",
        ":headers",
        ":libote_static",
        ":macoro_static",
        ":relic_static",
        ":sodium_static",
        ":volepsi_static",
    ],
    linkopts = [
        "-ldl",
        "-lpthread",
    ],
    visibility = ["//visibility:public"],
)
""",
)

new_local_repository(
    name = "local_circuitpsu1_securejoin",
    path = "/home/lgw/circuitPSU1/libs/securejoin",
    build_file_content = """
cc_library(
    name = "headers",
    hdrs = glob([
        "include/**/*.h",
        "include/**/*.hpp",
        "include/**/*.hh",
    ]),
    includes = ["include"],
    visibility = ["//visibility:public"],
)

cc_import(
    name = "securejoin_static",
    static_library = "lib/libsecureJoin.a",
    alwayslink = True,
)

cc_library(
    name = "securejoin",
    deps = [
        ":headers",
        ":securejoin_static",
    ],
    visibility = ["//visibility:public"],
)
""",
)

new_local_repository(
    name = "local_libote_feature_src",
    path = "/home/lgw/sp26/mPSI/out/volepsi/out/libOTe",
    build_file_content = """
cc_library(
    name = "kkrt_mr_impl",
    srcs = [
        "libOTe/Base/MasnyRindal.cpp",
        "libOTe/NChooseOne/NcoOtExt.cpp",
        "libOTe/NChooseOne/Kkrt/KkrtNcoOtReceiver.cpp",
        "libOTe/NChooseOne/Kkrt/KkrtNcoOtSender.cpp",
    ],
    hdrs = [
        "libOTe/Base/MasnyRindal.h",
        "libOTe/NChooseOne/NcoOtExt.h",
        "libOTe/NChooseOne/Kkrt/KkrtDefines.h",
        "libOTe/NChooseOne/Kkrt/KkrtNcoOtReceiver.h",
        "libOTe/NChooseOne/Kkrt/KkrtNcoOtSender.h",
    ],
    copts = [
        "-std=c++20",
        "-fcoroutines",
        "-maes",
        "-mpclmul",
        "-msse2",
        "-msse3",
        "-msse4.1",
        "-mavx2",
        "-fPIC",
        "-DENABLE_KKRT",
        "-DENABLE_MR",
    ],
    includes = [
        ".",
        "cryptoTools",
    ],
    deps = [
        "@local_volepsi//:headers",
        "@local_volepsi//:support_libs",
    ],
    visibility = ["//visibility:public"],
)
""",
)

new_local_repository(
    name = "local_flatbuffers",
    path = "/usr/local",
    build_file_content = """
cc_import(
    name = "flatbuffers_static",
    static_library = "lib/libflatbuffers.a",
)

cc_library(
    name = "flatbuffers",
    hdrs = glob(["include/flatbuffers/**/*.h"]),
    includes = ["include"],
    deps = [":flatbuffers_static"],
    visibility = ["//visibility:public"],
)
""",
)

new_local_repository(
    name = "local_jsoncpp",
    path = "/usr/local",
    build_file_content = """
cc_import(
    name = "jsoncpp_static",
    static_library = "lib/libjsoncpp.a",
)

cc_library(
    name = "jsoncpp",
    hdrs = glob(["include/json/*.h"]),
    includes = ["include"],
    deps = [":jsoncpp_static"],
    visibility = ["//visibility:public"],
)
""",
)

new_local_repository(
    name = "local_log4cplus",
    path = "/usr/local",
    build_file_content = """
cc_import(
    name = "log4cplus_shared",
    shared_library = "lib/liblog4cplus.so",
)

cc_library(
    name = "log4cplus",
    hdrs = glob(["include/log4cplus/**/*.h"]),
    includes = ["include"],
    deps = [":log4cplus_shared"],
    visibility = ["//visibility:public"],
)
""",
)

new_local_repository(
    name = "local_zmq",
    path = "/usr/local",
    build_file_content = """
cc_import(
    name = "zmq_shared",
    shared_library = "lib/libzmq.so",
)

cc_library(
    name = "zmq",
    hdrs = glob([
        "include/zmq*.h",
        "include/zmq*.hpp",
    ]),
    includes = ["include"],
    deps = [":zmq_shared"],
    visibility = ["//visibility:public"],
)
""",
)






new_local_repository(
    name = "system_glib",
    path = "/usr",
    build_file_content = """
cc_library(
    name = "glib",
    hdrs = glob([
        "include/glib-2.0/**/*.h",
        "lib/x86_64-linux-gnu/glib-2.0/include/**/*.h",
    ]),
    includes = [
        "include/glib-2.0",
        "lib/x86_64-linux-gnu/glib-2.0/include",
    ],
    visibility = ["//visibility:public"],
)
""",
)

new_local_repository(
    name = "securepsu",
    path = "/home/lgw/SecurePSU",
    build_file_content = """
package(default_visibility = ["//visibility:public"])

cc_library(
    name = "headers",
    hdrs = glob([
        "src/**/*.h",
        "extern/ABY/extern/ENCRYPTO_utils/src/**/*.h",
        "extern/HashingTables/**/*.h",
        "extern/libOTe/libOTe/**/*.h",
        "extern/libOTe/libOTe/**/*.hpp",
        "extern/libOTe/cryptoTools/**/*.h",
        "extern/libOTe/cryptoTools/**/*.hpp",
        "extern/libOTe/cryptoTools/cryptoTools/gsl/*",
        "extern/EzPC/SCI/src/**/*.h",
        "extern/EzPC/SCI/src/**/*.hpp",
        "extern/EzPC/SCI/extern/SEAL/native/src/**/*.h",
        "build/include/relic/**/*.h",
        "toolchain_overrides/**",
    ]),
    includes = [
        "src",
        "extern",
        "extern/ABY/extern/ENCRYPTO_utils/src",
        "extern/HashingTables",
        "extern/libOTe",
        "extern/libOTe/cryptoTools",
        "extern/EzPC/SCI/src",
        "extern/EzPC/SCI/extern/SEAL/native/src",
        "build/include/relic",
        "toolchain_overrides",
    ],
)

cc_import(
    name = "src_static",
    static_library = "build/lib/libsrc.a",
    alwayslink = True,
)

cc_import(
    name = "sci_linearhe_static",
    static_library = "build/lib/libSCI-LinearHE.a",
    alwayslink = True,
)

cc_import(
    name = "encrypto_utils_static",
    static_library = "build/extern/ABY/extern/ENCRYPTO_utils/src/libencrypto_utils.a",
    alwayslink = True,
)

cc_import(
    name = "hashing_tables_static",
    static_library = "build/extern/HashingTables/libHashingTables.a",
    alwayslink = True,
)

cc_import(
    name = "libote_static",
    static_library = "build/extern/libOTe/libOTe/liblibOTe.a",
    alwayslink = True,
)

cc_import(
    name = "cryptotools_static",
    static_library = "build/extern/libOTe/cryptoTools/cryptoTools/libcryptoTools.a",
    alwayslink = True,
)

cc_import(
    name = "relic_static",
    static_library = "build/extern/ABY/extern/ENCRYPTO_utils/extern/relic/lib/librelic_s.a",
    alwayslink = True,
)

cc_import(
    name = "otextension_static",
    static_library = "build/extern/ABY/lib/libotextension.a",
    alwayslink = True,
)

cc_library(
    name = "all_libs",
    deps = [
        ":src_static",
        ":sci_linearhe_static",
        ":encrypto_utils_static",
        ":hashing_tables_static",
        ":libote_static",
        ":cryptotools_static",
        ":relic_static",
        ":otextension_static",
    ],
)
""",
)

local_repository(
    name = "hedron_compile_commands",
    path = "third_party/hedron_compile_commands_stub",
)

load("@hedron_compile_commands//:workspace_setup.bzl", "hedron_compile_commands_setup")

hedron_compile_commands_setup()

# Eigen for dealerless-FSS
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "eigen",
    build_file = "@yacl//bazel:eigen.BUILD",
    sha256 = "8586084f71f9bde545ee7fa6d00288b264a2b7ac3607b974e54d13e7162c1c72",
    strip_prefix = "eigen-3.4.0",
    urls = ["https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz"],
)
