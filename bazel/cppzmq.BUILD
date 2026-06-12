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
    name = "cppzmq_cmake",
    cache_entries = {
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_PREFIX_PATH": "$$EXT_BUILD_DEPS$$/zmq_static",
        "CPPZMQ_BUILD_TESTS": "OFF",
        "CPPZMQ_CMAKECONFIG_INSTALL_DIR": "share/cmake/cppzmq",
        "ZeroMQ_DIR": "$$EXT_BUILD_DEPS$$/zmq_static/lib/cmake/ZeroMQ",
    },
    deps = ["@local_zmq//:zmq_static"],
    lib_source = ":all_srcs",
    out_headers_only = True,
    out_include_dir = "include",
    targets = ["install"],
)

cc_library(
    name = "cppzmq",
    hdrs = [
        "zmq.hpp",
        "zmq_addon.hpp",
    ],
    includes = ["."],
)
