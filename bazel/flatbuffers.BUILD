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
    ) + [
        "//src:distribution",
    ],
)

yacl_cmake_external(
    name = "flatbuffers_static",
    cache_entries = {
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_INSTALL_LIBDIR": "lib",
        "FLATBUFFERS_BUILD_BENCHMARKS": "OFF",
        "FLATBUFFERS_BUILD_FLATC": "OFF",
        "FLATBUFFERS_BUILD_FLATHASH": "OFF",
        "FLATBUFFERS_BUILD_FLATLIB": "ON",
        "FLATBUFFERS_BUILD_GRPCTEST": "OFF",
        "FLATBUFFERS_BUILD_SHAREDLIB": "OFF",
        "FLATBUFFERS_BUILD_TESTS": "OFF",
        "FLATBUFFERS_ENABLE_PCH": "OFF",
        "FLATBUFFERS_INSTALL": "ON",
        "FLATBUFFERS_STRICT_MODE": "OFF",
    },
    lib_source = ":all_srcs",
    out_include_dir = "include",
    out_lib_dir = "lib",
    out_static_libs = ["libflatbuffers.a"],
    targets = ["install"],
)

cc_library(
    name = "flatbuffers",
    deps = [":flatbuffers_static"],
)
