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
    name = "glog_static",
    cache_entries = {
        "BUILD_SHARED_LIBS": "OFF",
        "BUILD_TESTING": "OFF",
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_INSTALL_LIBDIR": "lib",
        "WITH_GFLAGS": "ON",
        "WITH_GTEST": "OFF",
        "WITH_PKGCONFIG": "OFF",
        "WITH_UNWIND": "OFF",
    },
    deps = [
        "@com_github_gflags_gflags//:gflags",
    ],
    lib_source = ":all_srcs",
    out_include_dir = "include",
    out_lib_dir = "lib",
    out_static_libs = ["libglog.a"],
    targets = ["install"],
)

cc_library(
    name = "glog",
    linkopts = ["-pthread"],
    deps = [
        ":glog_static",
        "@com_github_gflags_gflags//:gflags",
    ],
)
