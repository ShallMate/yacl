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
    name = "jsoncpp_static",
    cache_entries = {
        "BUILD_OBJECT_LIBS": "OFF",
        "BUILD_SHARED_LIBS": "OFF",
        "BUILD_STATIC_LIBS": "ON",
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_INSTALL_LIBDIR": "lib",
        "JSONCPP_WITH_CMAKE_PACKAGE": "OFF",
        "JSONCPP_WITH_EXAMPLE": "OFF",
        "JSONCPP_WITH_PKGCONFIG_SUPPORT": "OFF",
        "JSONCPP_WITH_POST_BUILD_UNITTEST": "OFF",
        "JSONCPP_WITH_TESTS": "OFF",
    },
    lib_source = ":all_srcs",
    out_include_dir = "include",
    out_lib_dir = "lib",
    out_static_libs = ["libjsoncpp.a"],
    targets = ["install"],
)

cc_library(
    name = "jsoncpp",
    deps = [":jsoncpp_static"],
)
