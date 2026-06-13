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

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def yacl_deps(include_examples = False, include_dev = False):
    _rule_proto()
    _rule_python()
    _rules_foreign_cc()
    _com_github_ridiculousfish_libdivide()
    _com_github_madler_zlib()
    _com_google_protobuf()
    _com_github_gflags_gflags()
    _com_google_googletest()
    _com_google_absl()
    _com_github_google_leveldb()
    _com_github_brpc_brpc()
    _com_github_fmtlib_fmt()
    _com_github_gabime_spdlog()
    _com_github_google_benchmark()
    _com_github_google_cpu_features()
    _com_github_dltcollab_sse2neon()
    _com_github_msgpack_msgpack()
    _com_github_greendow_hash_drbg()
    _com_github_facebook_zstd()
    _com_github_microsoft_seal()
    _com_github_nelhage_rules_boost()

    # crypto related
    _com_github_openssl_openssl()
    _com_github_blake3team_blake3()
    _com_github_libsodium()
    _com_github_libtom_libtommath()
    _com_github_herumi_mcl()
    _com_github_microsoft_FourQlib()
    _lib25519()

    _simplest_ot()
    _org_interconnection()
    _com_github_agl_curve25519_donna()
    _com_github_floodyberry_ed25519_donna()

    if include_examples:
        yacl_example_deps()

    if include_dev:
        yacl_dev_deps()

def yacl_example_deps():
    _com_github_supranational_blst()
    _com_github_osu_crypto_libote()
    _example_local_repositories()
    _eigen()
    _llvm_project_archives()

def yacl_dev_deps():
    _com_github_google_shell()
    _hedron_compile_commands()

def _simplest_ot():
    maybe(
        http_archive,
        name = "simplest_ot",
        urls = [
            "https://github.com/secretflow/simplest-ot/archive/4e39b7c35721c7fd968da6e047f59c0ac92e8088.tar.gz",
        ],
        strip_prefix = "simplest-ot-4e39b7c35721c7fd968da6e047f59c0ac92e8088",
        sha256 = "326e411c63b1cbd6697e9561a74f9d417df9394a988bf5c5e14775f14c612063",
    )

def _org_interconnection():
    maybe(
        http_archive,
        name = "org_interconnection",
        urls = [
            "https://github.com/secretflow/interconnection/archive/30e4220b7444d0bb077a9040f1b428632124e31a.tar.gz",
        ],
        strip_prefix = "interconnection-30e4220b7444d0bb077a9040f1b428632124e31a",
        sha256 = "341f6de0fa7dd618f9723009b9cb5b1da1788aacb9e12acfb0c9b19e5c5a7354",
    )

    # Add Homebrew OpenMP for macOS through declared external repositories.
    native.new_local_repository(
        name = "macos_omp_x64",
        build_file = "@yacl//bazel:local_openmp_macos.BUILD",
        path = "/opt/homebrew/opt/libomp/",
    )

    native.new_local_repository(
        name = "macos_omp_arm64",
        build_file = "@yacl//bazel:local_openmp_macos.BUILD",
        path = "/opt/homebrew/opt/libomp/",
    )

def _com_github_osu_crypto_libote():
    maybe(
        git_repository,
        name = "com_github_osu_crypto_libote",
        remote = "https://github.com/osu-crypto/libOTe.git",
        commit = "0412d3114bcf9c9955d0647aad8e49fe6a444461",
        recursive_init_submodules = True,
        build_file = "@yacl//bazel:libote.BUILD",
        patch_args = ["-p1"],
        patch_cmds = [
            "perl -0pi -e 's/add_subdirectory\\(libOTe_Tests\\)/add_subdirectory(libOTe_Tests EXCLUDE_FROM_ALL)/' CMakeLists.txt",
            "perl -0pi -e 's/add_subdirectory\\(frontend\\)/add_subdirectory(frontend EXCLUDE_FROM_ALL)/' CMakeLists.txt",
            "perl -0pi -e 's/add_subdirectory\\(tests_cryptoTools\\)/add_subdirectory(tests_cryptoTools EXCLUDE_FROM_ALL)/' cryptoTools/CMakeLists.txt",
            "perl -0pi -e 's/add_subdirectory\\(frontend_cryptoTools\\)/add_subdirectory(frontend_cryptoTools EXCLUDE_FROM_ALL)/' cryptoTools/CMakeLists.txt",
        ],
        patches = ["@yacl//bazel:libote_fetch_mkdir.patch"],
    )

def _example_local_repositories():
    _com_github_google_glog()
    _seal_compat()
    _local_apsi()
    _apsi_support_repositories()
    _openfhe_local()
    _local_relic()
    _sparsehash_c11()
    _local_volepsi()
    _local_circuitpsu1_deps()
    _local_secure_join_usr()
    _system_glib()
    _system_gmp()
    _system_ntl()
    _local_emp_tool()
    _local_emp_ot()
    _securepsu()
    _libpsi_install()
    _minipsi_external()

def _com_github_google_shell():
    maybe(
        native.local_repository,
        name = "com_github_google_shell",
        path = "third_party/com_github_google_shell",
    )

def _hedron_compile_commands():
    maybe(
        native.local_repository,
        name = "hedron_compile_commands",
        path = "third_party/hedron_compile_commands_stub",
    )

def _eigen():
    maybe(
        http_archive,
        name = "eigen",
        build_file = "@yacl//bazel:eigen.BUILD",
        sha256 = "8586084f71f9bde545ee7fa6d00288b264a2b7ac3607b974e54d13e7162c1c72",
        strip_prefix = "eigen-3.4.0",
        urls = ["https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz"],
    )

def _llvm_project_archives():
    llvm_commit = "499bce3abab8a362b9b4197944bd40b826c736c4"
    llvm_bazel_tag = "llvm-project-%s" % (llvm_commit,)

    maybe(
        http_archive,
        name = "llvm-bazel",
        sha256 = "a05a83300b6b4d8b45c9ba48296c06217f3ea27ed06b7e698896b5a3b2ed498d",
        strip_prefix = "llvm-bazel-{tag}/llvm-bazel".format(tag = llvm_bazel_tag),
        url = "https://github.com/google/llvm-bazel/archive/{tag}.tar.gz".format(tag = llvm_bazel_tag),
    )

    maybe(
        http_archive,
        name = "llvm-project-raw",
        build_file_content = "#empty",
        sha256 = "a154965dfeb2b5963acc2193bc334ce90b314acbe48430ba310d8a7c7a20de8b",
        strip_prefix = "llvm-project-" + llvm_commit,
        urls = [
            "https://storage.googleapis.com/mirror.tensorflow.org/github.com/llvm/llvm-project/archive/{commit}.tar.gz".format(commit = llvm_commit),
            "https://github.com/llvm/llvm-project/archive/{commit}.tar.gz".format(commit = llvm_commit),
        ],
    )

def _com_github_google_glog():
    maybe(
        git_repository,
        name = "com_github_google_glog",
        remote = "https://github.com/google/glog.git",
        tag = "v0.6.0",
        build_file = "@yacl//bazel:glog.BUILD",
    )

def _seal_compat():
    maybe(
        native.new_local_repository,
        name = "seal",
        path = "third_party",
        build_file_content = """
cc_library(
    name = "seal",
    deps = ["@com_github_microsoft_seal//:seal"],
    visibility = ["//visibility:public"],
)
""",
    )

def _local_apsi():
    maybe(
        git_repository,
        name = "local_apsi",
        remote = "https://github.com/microsoft/apsi.git",
        tag = "v0.11.0",
        build_file = "@yacl//bazel:apsi.BUILD",
        patch_args = ["-p1"],
        patches = ["@yacl//bazel:apsi_seal_4_1_compat.patch"],
    )

def _apsi_support_repositories():
    maybe(
        git_repository,
        name = "kuku",
        remote = "https://github.com/microsoft/Kuku.git",
        commit = "1338c4ae2211ab4c739022ff57f48ce5a76531d5",
        build_file = "@yacl//bazel:kuku.BUILD",
    )

    maybe(
        git_repository,
        name = "local_flatbuffers",
        remote = "https://github.com/google/flatbuffers.git",
        commit = "595bf0007ab1929570c7671f091313c8fc20644e",
        build_file = "@yacl//bazel:flatbuffers.BUILD",
    )

    maybe(
        git_repository,
        name = "local_jsoncpp",
        remote = "https://github.com/open-source-parsers/jsoncpp.git",
        commit = "89e2973c754a9c02a49974d839779b151e95afd6",
        build_file = "@yacl//bazel:jsoncpp.BUILD",
    )

    maybe(
        git_repository,
        name = "local_log4cplus",
        remote = "https://github.com/log4cplus/log4cplus.git",
        commit = "034a6bc91ac37774de1ce92f0cbb6ca47e46a6ce",
        recursive_init_submodules = True,
        build_file = "@yacl//bazel:log4cplus.BUILD",
    )

    maybe(
        git_repository,
        name = "local_zmq",
        remote = "https://github.com/zeromq/libzmq.git",
        commit = "622fc6dde99ee172ebaa9c8628d85a7a1995a21d",
        build_file = "@yacl//bazel:zeromq.BUILD",
    )

    maybe(
        git_repository,
        name = "cppzmq",
        remote = "https://github.com/zeromq/cppzmq.git",
        commit = "c94c20743ed7d4aa37835a5c46567ab0790d4acc",
        build_file = "@yacl//bazel:cppzmq.BUILD",
    )

    maybe(
        git_repository,
        name = "microsoft_gsl",
        remote = "https://github.com/microsoft/GSL.git",
        commit = "87f9d768866548b5b86e72be66c60c5abd4d9b37",
        build_file = "@yacl//bazel:ms_gsl.BUILD",
        patch_args = ["-p1"],
        patches = ["@yacl//bazel:ms_gsl_empty_static.patch"],
    )

def _openfhe_local():
    maybe(
        git_repository,
        name = "openfhe",
        remote = "https://github.com/openfheorg/openfhe-development.git",
        commit = "aa391988d354d4360f390f223a90e0d1b98839d7",
        recursive_init_submodules = True,
        build_file = "@yacl//bazel:openfhe.BUILD",
    )

def _local_relic():
    maybe(
        git_repository,
        name = "local_relic",
        remote = "https://github.com/relic-toolkit/relic.git",
        commit = "242c3ad139b5cd6e3df49969e563d63a9f1a4e54",
        build_file = "@yacl//bazel:relic.BUILD",
    )

def _sparsehash_c11():
    maybe(
        git_repository,
        name = "sparsehash_c11",
        remote = "https://github.com/sparsehash/sparsehash-c11.git",
        commit = "edd6f1180156e76facc1c0449da245208ab39503",
        build_file_content = """
cc_library(
    name = "sparsehash",
    hdrs = glob(["sparsehash/**/*"]),
    includes = ["."],
    visibility = ["//visibility:public"],
)
""",
    )

def _local_volepsi():
    maybe(
        git_repository,
        name = "local_volepsi",
        remote = "https://github.com/ladnir/volepsi.git",
        commit = "ed943f5f814591cdf864777c73b7bc9e7526c1a8",
        patch_args = ["-p1"],
        patches = ["@yacl//bazel:volepsi_libote_compat.patch"],
        build_file_content = """
genrule(
    name = "volepsi_config",
    outs = ["volePSI/config.h"],
    cmd = "cat > $@ <<'EOF'\\n#pragma once\\n#define VOLE_PSI_ENABLE_GMW ON\\n#define VOLE_PSI_ENABLE_CPSI ON\\n#define VOLE_PSI_ENABLE_OPPRF ON\\nEOF",
)

cc_library(
    name = "headers",
    hdrs = glob([
        "volePSI/**/*.h",
    ]) + [
        ":volepsi_config",
    ],
    includes = ["."],
    deps = [
        "@com_github_ridiculousfish_libdivide//:libdivide",
        "@com_github_osu_crypto_libote//:headers",
        "@sparsehash_c11//:sparsehash",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "volepsi",
    srcs = [
        "volePSI/GMW/Circuit.cpp",
        "volePSI/GMW/Gmw.cpp",
        "volePSI/GMW/SilentTripleGen.cpp",
        "volePSI/RsCpsi.cpp",
        "volePSI/RsOpprf.cpp",
        "volePSI/RsOprf.cpp",
        "volePSI/RsPsi.cpp",
        "volePSI/SimpleIndex.cpp",
        "volePSI/fileBased.cpp",
    ],
    copts = [
        "-std=c++20",
        "-fcoroutines",
        "-Wno-error",
        "-Wno-unused-parameter",
        "-Wno-unused-variable",
        "-Wno-sign-compare",
    ] + select({
        "@platforms//cpu:aarch64": [],
        "//conditions:default": [
            "-maes",
            "-mavx",
            "-mavx2",
            "-mpclmul",
            "-msse2",
            "-msse3",
            "-msse4.1",
        ],
    }),
    deps = [
        ":headers",
        "@com_github_ridiculousfish_libdivide//:libdivide",
        "@com_github_osu_crypto_libote//:all_deps",
        "@sparsehash_c11//:sparsehash",
    ],
    linkopts = [
        "-ldl",
        "-lpthread",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "support_libs",
    deps = [
        ":volepsi",
        "@com_github_osu_crypto_libote//:all_deps",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "static_libs",
    deps = [":support_libs"],
    visibility = ["//visibility:public"],
)
""",
    )

def _local_circuitpsu1_deps():
    maybe(
        native.new_local_repository,
        name = "local_circuitpsu1_volepsi",
        path = "third_party",
        build_file_content = """
cc_library(
    name = "headers",
    deps = ["@local_volepsi//:headers"],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "static_libs",
    deps = ["@local_volepsi//:static_libs"],
    visibility = ["//visibility:public"],
)
""",
    )

    maybe(
        native.new_local_repository,
        name = "local_circuitpsu1_securejoin",
        path = "third_party",
        build_file_content = """
cc_library(
    name = "headers",
    deps = ["@local_secure_join_usr//:headers"],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "securejoin",
    deps = ["@local_secure_join_usr//:securejoin"],
    visibility = ["//visibility:public"],
)
""",
    )

def _local_secure_join_usr():
    maybe(
        git_repository,
        name = "local_secure_join_usr",
        remote = "https://github.com/ladnir/secure-join.git",
        commit = "377ca63b9d8f4f6aede0d3a2e3d9078973a3ee10",
        patch_args = ["-p1"],
        patches = ["@yacl//bazel:secure_join_libote_compat.patch"],
        build_file_content = """
genrule(
    name = "securejoin_config",
    outs = ["secure-join/config.h"],
    cmd = "cat > $@ <<'EOF'\\n#pragma once\\n\\n/* #undef SECUREJOIN_ENABLE_PAILLIER */\\n/* #undef SECUREJOIN_ENABLE_FAKE_GEN */\\n#define SEC_JOIN_ROOT_DIRECTORY \\\\\\".\\\\\\"\\nEOF",
)

cc_library(
    name = "headers",
    hdrs = glob([
        "secure-join/**/*.h",
        "secure-join/**/*.hpp",
        "secure-join/**/*.hh",
    ]) + [
        ":securejoin_config",
    ],
    includes = ["."],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "securejoin",
    srcs = [
        "secure-join/AggTree/AggTree.cpp",
        "secure-join/AggTree/Level.cpp",
        "secure-join/AggTree/PlainAggTree.cpp",
        "secure-join/CorGenerator/Batch.cpp",
        "secure-join/CorGenerator/BinOleBatch.cpp",
        "secure-join/CorGenerator/CorGenerator.cpp",
        "secure-join/CorGenerator/F4BitOtBatch.cpp",
        "secure-join/CorGenerator/OtBatch.cpp",
        "secure-join/CorGenerator/Request.cpp",
        "secure-join/CorGenerator/TritOtBatch.cpp",
        "secure-join/GMW/Circuit.cpp",
        "secure-join/GMW/Gmw.cpp",
        "secure-join/Join/OmJoin.cpp",
        "secure-join/Join/OoJoin.cpp",
        "secure-join/Join/Table.cpp",
        "secure-join/Perm/AltModComposedPerm.cpp",
        "secure-join/Perm/AltModPerm.cpp",
        "secure-join/Perm/ComposedPerm.cpp",
        "secure-join/Perm/LowMCPerm.cpp",
        "secure-join/Perm/PermCorrelation.cpp",
        "secure-join/Perm/Permutation.cpp",
        "secure-join/Perm/PprfPermGen.cpp",
        "secure-join/Prf/AltModKeyMult.cpp",
        "secure-join/Prf/AltModPrf.cpp",
        "secure-join/Prf/AltModPrfProto.cpp",
        "secure-join/Prf/ConvertToF3.cpp",
        "secure-join/Prf/F2LinearCode.cpp",
        "secure-join/Prf/F3LinearCode.cpp",
        "secure-join/Prf/mod3.cpp",
        "secure-join/Sort/BitInjection.cpp",
        "secure-join/Sort/RadixSort.cpp",
        "secure-join/TableOps/Extract.cpp",
        "secure-join/TableOps/GroupBy.cpp",
        "secure-join/TableOps/Where.cpp",
        "secure-join/TableOps/WhereParser.cpp",
        "secure-join/Util/Trim.cpp",
    ],
    copts = [
        "-std=c++20",
        "-fcoroutines",
        "-fpermissive",
        "-Wno-error",
        "-Wno-unused-parameter",
        "-Wno-unused-variable",
        "-Wno-sign-compare",
        "-DmMultType=mLpnMultType",
        "-maes",
        "-mbmi2",
        "-mpclmul",
        "-msse4.1",
        "-mavx",
        "-mavx2",
    ],
    deps = [
        ":headers",
        "@com_github_osu_crypto_libote//:all_deps",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "securejoin_libs",
    deps = [
        ":securejoin",
        "@com_github_osu_crypto_libote//:all_deps",
    ],
    visibility = ["//visibility:public"],
)
""",
    )

def _system_glib():
    maybe(
        native.new_local_repository,
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

def _system_gmp():
    maybe(
        http_archive,
        name = "system_gmp",
        build_file = "@yacl//bazel:gmp.BUILD",
        sha256 = "a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898",
        strip_prefix = "gmp-6.3.0",
        urls = ["https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz"],
    )

def _local_emp_tool():
    maybe(
        git_repository,
        name = "local_emp_tool",
        remote = "https://github.com/emp-toolkit/emp-tool.git",
        commit = "8052d95ddf56b519a671b774865bb13157b3b4e0",
        build_file_content = """
cc_library(
    name = "emp-tool",
    srcs = [
        "emp-tool/emp-tool.cpp",
        "emp-tool/circuits/float32_add.cpp",
        "emp-tool/circuits/float32_cos.cpp",
        "emp-tool/circuits/float32_div.cpp",
        "emp-tool/circuits/float32_eq.cpp",
        "emp-tool/circuits/float32_exp.cpp",
        "emp-tool/circuits/float32_exp2.cpp",
        "emp-tool/circuits/float32_le.cpp",
        "emp-tool/circuits/float32_leq.cpp",
        "emp-tool/circuits/float32_ln.cpp",
        "emp-tool/circuits/float32_log2.cpp",
        "emp-tool/circuits/float32_mul.cpp",
        "emp-tool/circuits/float32_sin.cpp",
        "emp-tool/circuits/float32_sq.cpp",
        "emp-tool/circuits/float32_sqrt.cpp",
        "emp-tool/circuits/float32_sub.cpp",
    ],
    hdrs = glob([
        "emp-tool/**/*.h",
        "emp-tool/**/*.hpp",
        "emp-tool/circuits/files/**/*",
    ]),
    includes = ["."],
    copts = [
        "-std=c++11",
        "-pthread",
        "-Wall",
        "-funroll-loops",
        "-Wno-ignored-attributes",
        "-Wno-unused-result",
    ] + select({
        "@platforms//cpu:aarch64": [
            "-march=armv8-a+simd+crypto+crc",
        ],
        "//conditions:default": [
            "-maes",
            "-mrdseed",
        ],
    }),
    deps = [
        "@com_github_openssl_openssl//:openssl",
    ],
    linkopts = ["-pthread"],
    visibility = ["//visibility:public"],
)
""",
    )

def _local_emp_ot():
    maybe(
        git_repository,
        name = "local_emp_ot",
        remote = "https://github.com/emp-toolkit/emp-ot.git",
        commit = "d5f4fc89433c1e391de16c209bcca1a08755507b",
        build_file_content = """
cc_library(
    name = "emp-ot",
    hdrs = glob([
        "emp-ot/**/*.h",
        "emp-ot/**/*.hpp",
    ]),
    includes = ["."],
    deps = ["@local_emp_tool//:emp-tool"],
    visibility = ["//visibility:public"],
)
""",
    )

def _system_ntl():
    maybe(
        http_archive,
        name = "system_ntl",
        build_file = "@yacl//bazel:ntl.BUILD",
        sha256 = "210d06c31306cbc6eaf6814453c56c776d9d8e8df36d74eb306f6a523d1c6a8a",
        strip_prefix = "ntl-11.5.1",
        urls = ["https://libntl.org/ntl-11.5.1.tar.gz"],
    )

def _securepsu():
    maybe(
        git_repository,
        name = "securepsu",
        build_file = "@yacl//bazel:securepsu.BUILD",
        commit = "2821e2422ff3590d9df551a4ce2eb98b4ccd27f9",
        patch_args = ["-p1"],
        patches = ["@yacl//bazel:securepsu_bazel_compat.patch"],
        recursive_init_submodules = True,
        remote = "https://github.com/yanxue820/SecurePSU.git",
    )

def _libpsi_install():
    maybe(
        native.new_local_repository,
        name = "libpsi_install",
        path = "third_party",
        build_file_content = """
cc_library(
    name = "headers",
    deps = [
        "@boost//:format",
        "@boost//:multiprecision",
        "@com_github_osu_crypto_libote//:headers",
        "@sparsehash_c11//:sparsehash",
        "@system_gmp//:gmpxx",
        "@system_ntl//:ntl",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "frontend_deps",
    deps = [
        ":headers",
        "@boost//:format",
        "@boost//:multiprecision",
        "@boost//:system",
        "@boost//:thread",
        "@com_github_osu_crypto_libote//:all_deps",
        "@sparsehash_c11//:sparsehash",
        "@system_gmp//:gmpxx",
        "@system_ntl//:ntl",
    ],
    linkopts = [
        "-ldl",
        "-pthread",
    ],
    visibility = ["//visibility:public"],
)
""",
    )

def _minipsi_external():
    maybe(
        native.new_local_repository,
        name = "minipsi_external",
        path = "examples/MiniPSI/compat/legacy_dep",
        build_file_content = """
cc_import(
    name = "cryptotools_static",
    static_library = "lib/libcryptoTools.a",
)

cc_import(
    name = "libote_static",
    static_library = "lib/liblibOTe.a",
)

cc_import(
    name = "miracl_static",
    static_library = "libOTe/cryptoTools/thirdparty/linux/miracl/source/miracl.a",
    alwayslink = True,
)

cc_import(
    name = "ntl_static",
    static_library = "thirdparty/linux/ntl/src/libntl.a",
)

cc_import(
    name = "gmp_static",
    static_library = "thirdparty/linux/gmp/lib/libgmp.a",
)

cc_import(
    name = "gf2x_static",
    static_library = "thirdparty/linux/gf2x/.libs/libgf2x.a",
)

cc_import(
    name = "sodium_static",
    static_library = "libsodium-stable/bin/lib/libsodium.a",
)

cc_library(
    name = "headers",
    hdrs = glob([
        "libOTe/libOTe/**/*.h",
        "libOTe/cryptoTools/cryptoTools/**/*",
        "libOTe/cryptoTools/thirdparty/linux/miracl/include/**/*",
        "thirdparty/linux/ntl/include/**/*",
        "thirdparty/linux/gmp/include/**/*",
        "thirdparty/linux/gf2x/include/**/*",
        "libsodium-stable/bin/include/**/*",
    ]),
    includes = [
        ".",
        "libOTe",
        "libOTe/cryptoTools",
        "libOTe/cryptoTools/thirdparty/linux",
        "libOTe/cryptoTools/thirdparty/linux/miracl/include",
        "thirdparty/linux/ntl/include",
        "thirdparty/linux/gmp/include",
        "thirdparty/linux/gf2x/include",
        "libsodium-stable/bin/include",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "core_deps",
    deps = [
        ":libote_static",
        ":miracl_static",
        ":ntl_static",
        ":cryptotools_static",
        ":gf2x_static",
        ":gmp_static",
        ":sodium_static",
    ],
    linkopts = [
        "-ldl",
        "-lpthread",
    ],
    visibility = ["//visibility:public"],
)
""",
    )

def _com_github_brpc_brpc():
    maybe(
        http_archive,
        name = "com_github_brpc_brpc",
        sha256 = "85856da0216773e1296834116f69f9e80007b7ff421db3be5c9d1890ecfaea74",
        strip_prefix = "brpc-1.9.0",
        type = "tar.gz",
        patch_args = ["-p1"],
        patches = [
            "@yacl//bazel:patches/brpc.patch",
            "@yacl//bazel:patches/brpc_m1.patch",
        ],
        urls = [
            "https://github.com/apache/brpc/archive/refs/tags/1.9.0.tar.gz",
        ],
    )

def _com_github_gflags_gflags():
    maybe(
        http_archive,
        name = "com_github_gflags_gflags",
        strip_prefix = "gflags-2.2.2",
        sha256 = "34af2f15cf7367513b352bdcd2493ab14ce43692d2dcd9dfc499492966c64dcf",
        type = "tar.gz",
        patch_args = ["-p1"],
        patches = ["@yacl//bazel:patches/gflags_google_namespace.patch"],
        urls = [
            "https://github.com/gflags/gflags/archive/v2.2.2.tar.gz",
        ],
    )

def _com_github_google_leveldb():
    maybe(
        http_archive,
        name = "com_github_google_leveldb",
        strip_prefix = "leveldb-1.23",
        sha256 = "9a37f8a6174f09bd622bc723b55881dc541cd50747cbd08831c2a82d620f6d76",
        type = "tar.gz",
        build_file = "@yacl//bazel:leveldb.BUILD",
        patch_args = ["-p1"],
        patches = ["@yacl//bazel:patches/leveldb.patch"],
        urls = [
            "https://github.com/google/leveldb/archive/refs/tags/1.23.tar.gz",
        ],
    )

def _com_github_madler_zlib():
    maybe(
        http_archive,
        name = "zlib",
        build_file = "@yacl//bazel:zlib.BUILD",
        strip_prefix = "zlib-1.3.1",
        sha256 = "17e88863f3600672ab49182f217281b6fc4d3c762bde361935e436a95214d05c",
        type = ".tar.gz",
        urls = [
            "https://github.com/madler/zlib/archive/refs/tags/v1.3.1.tar.gz",
        ],
    )

def _com_google_protobuf():
    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "2c6a36c7b5a55accae063667ef3c55f2642e67476d96d355ff0acb13dbb47f09",
        strip_prefix = "protobuf-21.12",
        type = "tar.gz",
        patch_args = ["-p1"],
        patches = ["@yacl//bazel:patches/protobuf.patch"],
        urls = [
            "https://github.com/protocolbuffers/protobuf/releases/download/v21.12/protobuf-all-21.12.tar.gz",
        ],
    )

def _com_google_absl():
    maybe(
        http_archive,
        name = "com_google_absl",
        sha256 = "733726b8c3a6d39a4120d7e45ea8b41a434cdacde401cba500f14236c49b39dc",
        type = "tar.gz",
        strip_prefix = "abseil-cpp-20240116.2",
        urls = [
            "https://github.com/abseil/abseil-cpp/archive/refs/tags/20240116.2.tar.gz",
        ],
    )

def _com_github_openssl_openssl():
    maybe(
        http_archive,
        name = "com_github_openssl_openssl",
        sha256 = "9a7a7355f3d4b73f43b5730ce80371f9d1f97844ffc8c4b01c723ba0625d6aad",
        type = "tar.gz",
        strip_prefix = "openssl-openssl-3.0.12",
        urls = [
            "https://github.com/openssl/openssl/archive/refs/tags/openssl-3.0.12.tar.gz",
        ],
        build_file = "@yacl//bazel:openssl.BUILD",
    )

def _com_github_fmtlib_fmt():
    maybe(
        http_archive,
        name = "com_github_fmtlib_fmt",
        strip_prefix = "fmt-10.2.1",
        sha256 = "1250e4cc58bf06ee631567523f48848dc4596133e163f02615c97f78bab6c811",
        build_file = "@yacl//bazel:fmtlib.BUILD",
        urls = [
            "https://github.com/fmtlib/fmt/archive/refs/tags/10.2.1.tar.gz",
        ],
    )

def _com_github_gabime_spdlog():
    maybe(
        http_archive,
        name = "com_github_gabime_spdlog",
        strip_prefix = "spdlog-1.14.1",
        type = "tar.gz",
        sha256 = "1586508029a7d0670dfcb2d97575dcdc242d3868a259742b69f100801ab4e16b",
        build_file = "@yacl//bazel:spdlog.BUILD",
        urls = [
            "https://github.com/gabime/spdlog/archive/refs/tags/v1.14.1.tar.gz",
        ],
    )

def _com_google_googletest():
    maybe(
        http_archive,
        name = "com_google_googletest",
        sha256 = "8ad598c73ad796e0d8280b082cebd82a630d73e73cd3c70057938a6501bba5d7",
        type = "tar.gz",
        strip_prefix = "googletest-1.14.0",
        urls = [
            "https://github.com/google/googletest/archive/refs/tags/v1.14.0.tar.gz",
        ],
    )

def _com_github_google_benchmark():
    maybe(
        http_archive,
        name = "com_github_google_benchmark",
        type = "tar.gz",
        strip_prefix = "benchmark-1.8.4",
        sha256 = "3e7059b6b11fb1bbe28e33e02519398ca94c1818874ebed18e504dc6f709be45",
        urls = [
            "https://github.com/google/benchmark/archive/refs/tags/v1.8.4.tar.gz",
        ],
    )

def _com_github_blake3team_blake3():
    maybe(
        http_archive,
        name = "com_github_blake3team_blake3",
        strip_prefix = "BLAKE3-1.5.1",
        sha256 = "822cd37f70152e5985433d2c50c8f6b2ec83aaf11aa31be9fe71486a91744f37",
        build_file = "@yacl//bazel:blake3.BUILD",
        urls = [
            "https://github.com/BLAKE3-team/BLAKE3/archive/refs/tags/1.5.1.tar.gz",
        ],
    )

def _rule_proto():
    maybe(
        http_archive,
        name = "rules_proto",
        sha256 = "dc3fb206a2cb3441b485eb1e423165b231235a1ea9b031b4433cf7bc1fa460dd",
        strip_prefix = "rules_proto-5.3.0-21.7",
        urls = [
            "https://github.com/bazelbuild/rules_proto/archive/refs/tags/5.3.0-21.7.tar.gz",
        ],
    )

# Required by protobuf
def _rule_python():
    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "4912ced70dc1a2a8e4b86cec233b192ca053e82bc72d877b98e126156e8f228d",
        strip_prefix = "rules_python-0.32.2",
        urls = [
            "https://github.com/bazelbuild/rules_python/archive/refs/tags/0.32.2.tar.gz",
        ],
    )

def _rules_foreign_cc():
    maybe(
        http_archive,
        name = "rules_foreign_cc",
        sha256 = "b3127e65fc189f28833be0cf64ba8b33b0bbb2707b7d448ba3baba5247a3c9f8",
        strip_prefix = "rules_foreign_cc-5c34b7136f0dec5d8abf2b840796ec8aef56a7c1",
        urls = [
            "https://github.com/bazelbuild/rules_foreign_cc/archive/5c34b7136f0dec5d8abf2b840796ec8aef56a7c1.tar.gz",
        ],
    )

def _com_github_libsodium():
    maybe(
        git_repository,
        name = "com_github_libsodium",
        remote = "https://github.com/osu-crypto/libsodium.git",
        commit = "778c9cf491fdeeef362512fb964db0943732f275",
        build_file = "@yacl//bazel:libsodium.BUILD",
    )

def _com_github_microsoft_FourQlib():
    maybe(
        http_archive,
        name = "com_github_microsoft_FourQlib",
        type = "tar.gz",
        strip_prefix = "FourQlib-1031567f23278e1135b35cc04e5d74c2ac88c029",
        sha256 = "7417c829d7933facda568c7a08924dfefb0c83dd1dab411e597af4c0cc0417f0",
        patch_args = ["-p1"],
        patches = [
            "@yacl//bazel:patches/FourQlib.patch",
        ],
        build_file = "@yacl//bazel:FourQlib.BUILD",
        urls = [
            "https://github.com/microsoft/FourQlib/archive/1031567f23278e1135b35cc04e5d74c2ac88c029.tar.gz",
        ],
    )

def _com_github_google_cpu_features():
    maybe(
        http_archive,
        name = "com_github_google_cpu_features",
        strip_prefix = "cpu_features-0.9.0",
        type = "tar.gz",
        build_file = "@yacl//bazel:cpu_features.BUILD",
        sha256 = "bdb3484de8297c49b59955c3b22dba834401bc2df984ef5cfc17acbe69c5018e",
        urls = [
            "https://github.com/google/cpu_features/archive/refs/tags/v0.9.0.tar.gz",
        ],
    )

def _com_github_dltcollab_sse2neon():
    maybe(
        http_archive,
        name = "com_github_dltcollab_sse2neon",
        sha256 = "787e0a7a64f1461b48232a7f9b9e9c14fa4a35a30875f2fb91aec6ddeaddfc0f",
        strip_prefix = "sse2neon-8df2f48dbd0674ae5087f7a6281af6f55fa5a8e2",
        type = "tar.gz",
        urls = [
            "https://github.com/DLTcollab/sse2neon/archive/8df2f48dbd0674ae5087f7a6281af6f55fa5a8e2.tar.gz",
        ],
        build_file = "@yacl//bazel:sse2neon.BUILD",
    )

def _com_github_libtom_libtommath():
    maybe(
        http_archive,
        name = "com_github_libtom_libtommath",
        sha256 = "7cfbdb64431129de4257e7d3349200fdbd4f229b470ff3417b30d0f39beed41f",
        type = "tar.gz",
        strip_prefix = "libtommath-42b3fb07e7d504f61a04c7fca12e996d76a25251",
        patch_args = ["-p1"],
        patches = [
            "@yacl//bazel:patches/libtommath.patch",
        ],
        urls = [
            "https://github.com/libtom/libtommath/archive/42b3fb07e7d504f61a04c7fca12e996d76a25251.tar.gz",
        ],
        build_file = "@yacl//bazel:libtommath.BUILD",
    )

def _com_github_msgpack_msgpack():
    maybe(
        http_archive,
        name = "com_github_msgpack_msgpack",
        type = "tar.gz",
        strip_prefix = "msgpack-c-cpp-6.1.0",
        sha256 = "5e63e4d9b12ab528fccf197f7e6908031039b1fc89cd8da0e97fbcbf5a6c6d3a",
        patches = [
            "@yacl//bazel:patches/msgpack.patch",
        ],
        patch_args = ["-p1"],
        urls = [
            "https://github.com/msgpack/msgpack-c/archive/refs/tags/cpp-6.1.0.tar.gz",
        ],
        build_file = "@yacl//bazel:msgpack.BUILD",
    )

def _com_github_greendow_hash_drbg():
    maybe(
        http_archive,
        name = "com_github_greendow_hash_drbg",
        sha256 = "c03a3da5742d0f0c40232817d84f21d8eed4c4af498c4dff3a51b3bcadcb3787",
        type = "tar.gz",
        strip_prefix = "Hash-DRBG-2411fa9d0de81c69dce2a48555c30298253db15d",
        urls = [
            "https://github.com/greendow/Hash-DRBG/archive/2411fa9d0de81c69dce2a48555c30298253db15d.tar.gz",
        ],
        build_file = "@yacl//bazel:hash_drbg.BUILD",
    )

def _com_github_herumi_mcl():
    maybe(
        http_archive,
        name = "com_github_herumi_mcl",
        strip_prefix = "mcl-1.88",
        sha256 = "7fcc630c008e973dda88dd1d1cd2bb14face95ee3ed3b2f717fbb25d340d6ba5",
        type = "tar.gz",
        build_file = "@yacl//bazel:mcl.BUILD",
        patch_args = ["-p1"],
        patches = [
            "@yacl//bazel:patches/mcl.patch",
        ],
        urls = ["https://github.com/herumi/mcl/archive/refs/tags/v1.88.tar.gz"],
    )

def _com_github_supranational_blst():
    maybe(
        http_archive,
        name = "com_github_supranational_blst",
        strip_prefix = "blst-0.3.16",
        sha256 = "e04805b7d6ef9e1d89b7f511a5b86136c57b455d97924d7324da2305a864673f",
        type = "tar.gz",
        build_file = "@yacl//bazel:blst.BUILD",
        urls = ["https://github.com/supranational/blst/archive/refs/tags/v0.3.16.tar.gz"],
    )

def _lib25519():
    maybe(
        http_archive,
        name = "lib25519",
        strip_prefix = "lib25519-20240321",
        sha256 = "d010baea719153fe3f012789b5a1de27d91fbbcfc65559e7eee5d802bf91eadd",
        type = "tar.gz",
        build_file = "@yacl//bazel:lib25519.BUILD",
        urls = [
            "https://lib25519.cr.yp.to/lib25519-20240321.tar.gz",
        ],
    )

def _com_github_microsoft_seal():
    maybe(
        http_archive,
        name = "com_github_microsoft_seal",
        sha256 = "af9bf0f0daccda2a8b7f344f13a5692e0ee6a45fea88478b2b90c35648bf2672",
        strip_prefix = "SEAL-4.1.1",
        type = "tar.gz",
        patch_args = ["-p1"],
        patches = ["@yacl//bazel:patches/seal.patch"],
        urls = [
            "https://github.com/microsoft/SEAL/archive/refs/tags/v4.1.1.tar.gz",
        ],
        build_file = "@yacl//bazel:seal.BUILD",
    )

def _com_github_facebook_zstd():
    maybe(
        http_archive,
        name = "com_github_facebook_zstd",
        build_file = "@yacl//bazel:zstd.BUILD",
        strip_prefix = "zstd-1.5.5",
        sha256 = "98e9c3d949d1b924e28e01eccb7deed865eefebf25c2f21c702e5cd5b63b85e1",
        type = ".tar.gz",
        urls = [
            "https://github.com/facebook/zstd/archive/refs/tags/v1.5.5.tar.gz",
        ],
    )

def _com_github_nelhage_rules_boost():
    # use boost 1.83
    RULES_BOOST_COMMIT = "cfa585b1b5843993b70aa52707266dc23b3282d0"
    maybe(
        http_archive,
        name = "com_github_nelhage_rules_boost",
        sha256 = "a7c42df432fae9db0587ff778d84f9dc46519d67a984eff8c79ae35e45f277c1",
        strip_prefix = "rules_boost-%s" % RULES_BOOST_COMMIT,
        patch_args = ["-p1"],
        patches = ["@yacl//bazel:patches/boost.patch"],
        urls = [
            "https://github.com/nelhage/rules_boost/archive/%s.tar.gz" % RULES_BOOST_COMMIT,
        ],
    )

def _com_github_ridiculousfish_libdivide():
    maybe(
        http_archive,
        name = "com_github_ridiculousfish_libdivide",
        urls = [
            "https://github.com/ridiculousfish/libdivide/archive/refs/tags/5.0.tar.gz",
        ],
        sha256 = "01ffdf90bc475e42170741d381eb9cfb631d9d7ddac7337368bcd80df8c98356",
        strip_prefix = "libdivide-5.0",
        build_file = "@yacl//bazel:libdivide.BUILD",
    )

def _com_github_agl_curve25519_donna():
    maybe(
        http_archive,
        name = "com_github_agl_curve25519_donna",
        strip_prefix = "curve25519-donna-master",
        type = "tar.gz",
        build_file = "@yacl//bazel:curve25519-donna.BUILD",
        urls = [
            "https://github.com/agl/curve25519-donna/archive/refs/heads/master.tar.gz",
        ],
    )

def _com_github_floodyberry_ed25519_donna():
    maybe(
        http_archive,
        name = "com_github_floodyberry_ed25519_donna",
        strip_prefix = "ed25519-donna-master",
        type = "tar.gz",
        build_file = "@yacl//bazel:ed25519-donna.BUILD",
        urls = [
            "https://github.com/floodyberry/ed25519-donna/archive/refs/heads/master.tar.gz",
        ],
    )
