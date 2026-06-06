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
    name = "relic_static",
    cache_entries = {
        "ARCH": "X64",
        "ARITH": "x64-asm-6l",
        "BN_PRECI": "3072",
        "CHECK": "off",
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_INSTALL_LIBDIR": "lib",
        "CURVE": "B12-381",
        "EP2_METHD": "PROJC;JACOB;LWNAF;COMBS;INTER",
        "EP_METHD": "PROJC;JACOB;LWNAF;COMBS;INTER",
        "FPX_METHD": "INTEG;INTEG;LAZYR",
        "FP_METHD": "INTEG;INTEG;INTEG;MONTY;LOWER;LOWER;SLIDE",
        "FP_PMERS": "off",
        "FP_PRIME": "381",
        "FP_QNRES": "on",
        "MULTI": "PTHREAD",
        "PP_METHD": "LAZYR;OATEP",
        "RAND": "UDEV",
        "SHLIB": "off",
        "STBIN": "off",
        "STLIB": "on",
        "TIMER": "HREAL",
        "VERBS": "off",
        "WITH_BN": "on",
        "WITH_DV": "on",
        "WITH_EP": "on",
        "WITH_EP2": "on",
        "WITH_EPX": "on",
        "WITH_FB": "on",
        "WITH_FP": "on",
        "WITH_FPX": "on",
        "WITH_MD": "on",
        "WITH_PC": "on",
        "WITH_PP": "on",
        "WSIZE": "64",
    },
    deps = [
        "@system_gmp//:gmp",
    ],
    lib_source = ":all_srcs",
    out_include_dir = "include",
    out_lib_dir = "lib",
    out_static_libs = ["librelic_s.a"],
    targets = ["install"],
)

cc_library(
    name = "relic",
    includes = ["relic_static/include/relic"],
    linkopts = ["-pthread"],
    deps = [
        ":relic_static",
        "@system_gmp//:gmp",
    ],
)
