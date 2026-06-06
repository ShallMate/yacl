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
    name = "log4cplus_static",
    cache_entries = {
        "BUILD_SHARED_LIBS": "OFF",
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_INSTALL_LIBDIR": "lib",
        "LOG4CPLUS_BUILD_LOGGINGSERVER": "OFF",
        "LOG4CPLUS_BUILD_TESTING": "OFF",
        "LOG4CPLUS_ENABLE_DECORATED_LIBRARY_NAME": "OFF",
        "LOG4CPLUS_ENABLE_THREAD_POOL": "OFF",
        "WITH_ICONV": "OFF",
        "WITH_UNIT_TESTS": "OFF",
    },
    lib_source = ":all_srcs",
    out_include_dir = "include",
    out_lib_dir = "lib",
    out_static_libs = ["liblog4cplus.a"],
    targets = ["install"],
)

cc_library(
    name = "log4cplus",
    linkopts = ["-pthread"],
    deps = [":log4cplus_static"],
)
