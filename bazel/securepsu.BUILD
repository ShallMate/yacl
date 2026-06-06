load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

SECUREPSU_COPTS = [
    "-std=c++17",
    "-maes",
    "-msse2",
    "-msse3",
    "-msse4.1",
    "-mrdrnd",
    "-mpclmul",
    "-mavx",
    "-mavx2",
]

cc_library(
    name = "sci_headers",
    hdrs = glob([
        "extern/EzPC/SCI/src/**/*.h",
        "extern/EzPC/SCI/src/**/*.hpp",
    ]),
    includes = [
        "extern",
        "extern/EzPC/SCI/src",
    ],
    deps = [
        "@com_github_openssl_openssl//:openssl",
        "@system_gmp//:gmpxx",
    ],
)

cc_library(
    name = "hashing_tables",
    srcs = [
        "extern/HashingTables/common/hash_table_entry.cpp",
        "extern/HashingTables/common/hashing.cpp",
        "extern/HashingTables/cuckoo_hashing/cuckoo_hashing.cpp",
        "extern/HashingTables/simple_hashing/simple_hashing.cpp",
    ],
    hdrs = glob([
        "extern/HashingTables/**/*.h",
        "extern/HashingTables/**/*.hpp",
        "extern/HashingTables/extern/fmt/include/**/*.h",
    ]),
    copts = SECUREPSU_COPTS + [
        "-DFMT_HEADER_ONLY",
    ],
    includes = [
        "extern/HashingTables",
        "extern/HashingTables/extern/fmt/include",
    ],
    deps = [
        "@com_github_openssl_openssl//:openssl",
    ],
)

cc_library(
    name = "encrypto_utils",
    srcs = [
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/cbitvector.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/channel.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/circular_queue.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/codewords.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/connection.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/crypto/TedKrovetzAesNiWrapperC.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/crypto/crypto.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/crypto/dgk.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/crypto/djn.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/crypto/ecc-pk-crypto.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/crypto/gmp-pk-crypto.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/crypto/intrin_sequential_enc8.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/parse_options.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/powmod.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/rcvthread.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/sndthread.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/socket.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/thread.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/timer.cpp",
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/utils.cpp",
    ],
    hdrs = glob([
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/**/*.h",
    ]),
    copts = SECUREPSU_COPTS + [
        "-DECCLVL=251",
    ],
    includes = [
        "extern/ABY/extern/ENCRYPTO_utils/src",
    ],
    linkopts = [
        "-pthread",
    ],
    deps = [
        "@boost//:system",
        "@boost//:thread",
        "@com_github_openssl_openssl//:openssl",
        "@local_relic//:relic",
        "@system_gmp//:gmpxx",
    ],
)

cc_library(
    name = "headers",
    hdrs = glob([
        "extern/ABY/extern/ENCRYPTO_utils/src/ENCRYPTO_utils/**/*.h",
        "extern/HashingTables/**/*.h",
        "extern/HashingTables/**/*.hpp",
        "extern/EzPC/SCI/src/**/*.h",
        "extern/EzPC/SCI/src/**/*.hpp",
    ]),
    includes = [
        "extern",
        "extern/ABY/extern/ENCRYPTO_utils/src",
        "extern/HashingTables",
        "extern/EzPC/SCI/src",
    ],
    deps = [
        ":encrypto_utils",
        ":hashing_tables",
        ":sci_headers",
    ],
)

cc_library(
    name = "all_libs",
    deps = [
        ":encrypto_utils",
        ":hashing_tables",
        ":sci_headers",
    ],
)
