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
    name = "zmq_static",
    cache_entries = {
        "BUILD_SHARED": "OFF",
        "BUILD_STATIC": "ON",
        "BUILD_TESTS": "OFF",
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_INSTALL_LIBDIR": "lib",
        "ENABLE_CPACK": "OFF",
        "ENABLE_CURVE": "OFF",
        "ENABLE_DRAFTS": "OFF",
        "ENABLE_PRECOMPILED": "OFF",
        "WITH_DOCS": "OFF",
        "WITH_LIBSODIUM": "OFF",
        "WITH_NORM": "OFF",
        "WITH_OPENPGM": "OFF",
        "WITH_TLS": "OFF",
    },
    lib_source = ":all_srcs",
    out_include_dir = "include",
    out_lib_dir = "lib",
    out_static_libs = ["libzmq.a"],
    targets = ["install"],
)

cc_library(
    name = "zmq",
    linkopts = [
        "-ldl",
        "-pthread",
    ],
    deps = [
        ":zmq_static",
        "@cppzmq//:cppzmq",
    ],
)
