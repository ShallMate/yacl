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
    name = "kuku_static",
    cache_entries = {
        "BUILD_SHARED_LIBS": "OFF",
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_INSTALL_LIBDIR": "lib",
        "KUKU_BUILD_EXAMPLES": "OFF",
        "KUKU_BUILD_KUKU_C": "OFF",
        "KUKU_BUILD_TESTS": "OFF",
    },
    lib_source = ":all_srcs",
    out_include_dir = "include/Kuku-2.1",
    out_lib_dir = "lib",
    out_static_libs = ["libkuku-2.1.a"],
    targets = ["install"],
)

cc_library(
    name = "kuku",
    deps = [":kuku_static"],
)
