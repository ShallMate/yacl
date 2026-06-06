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
    name = "gsl_cmake",
    cache_entries = {
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_INSTALL_DATADIR": "include/share",
        "GSL_INSTALL": "ON",
        "GSL_TEST": "OFF",
    },
    lib_source = ":all_srcs",
    out_include_dir = "include",
    out_lib_dir = "lib",
    out_static_libs = ["libgsl_cmake.a"],
    targets = ["install"],
)

cc_library(
    name = "gsl",
    deps = [":gsl_cmake"],
)
