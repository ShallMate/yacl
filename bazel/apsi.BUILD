load("@yacl//bazel:yacl.bzl", "yacl_cmake_external")

package(default_visibility = ["//visibility:public"])

_APSI_CMAKE_PREFIX_PATH = ";".join([
    "$$EXT_BUILD_DEPS$$/seal",
    "$$EXT_BUILD_DEPS$$/kuku_static",
    "$$EXT_BUILD_DEPS$$/flatbuffers_static",
    "$$EXT_BUILD_DEPS$$/jsoncpp_static",
    "$$EXT_BUILD_DEPS$$/zmq_static",
    "$$EXT_BUILD_DEPS$$/cppzmq_cmake",
    "$$EXT_BUILD_DEPS$$/log4cplus_static",
    "$$EXT_BUILD_DEPS$$/gsl_cmake/include",
])

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
    name = "apsi_static",
    cache_entries = {
        "APSI_BUILD_CLI": "OFF",
        "APSI_BUILD_TESTS": "OFF",
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_INSTALL_LIBDIR": "lib",
        "CMAKE_PREFIX_PATH": _APSI_CMAKE_PREFIX_PATH,
        "CMAKE_CXX_FLAGS": "-I$$EXT_BUILD_DEPS$$/gsl_cmake/include",
        "Kuku_DIR": "$$EXT_BUILD_DEPS$$/kuku_static/lib/cmake/Kuku-2.1",
        "Microsoft.GSL_DIR": "$$EXT_BUILD_DEPS$$/gsl_cmake/include/share/cmake/Microsoft.GSL",
        "SEAL_DIR": "$$EXT_BUILD_DEPS$$/seal/lib/cmake/SEAL-4.1",
        "ZeroMQ_DIR": "$$EXT_BUILD_DEPS$$/zmq_static/lib/cmake/ZeroMQ",
        "cppzmq_DIR": "$$EXT_BUILD_DEPS$$/cppzmq_cmake/share/cmake/cppzmq",
        "flatbuffers_DIR": "$$EXT_BUILD_DEPS$$/flatbuffers_static/lib/cmake/flatbuffers",
        "jsoncpp_DIR": "$$EXT_BUILD_DEPS$$/jsoncpp_static/lib/cmake/jsoncpp",
        "log4cplus_DIR": "$$EXT_BUILD_DEPS$$/log4cplus_static/lib/cmake/log4cplus",
    },
    deps = [
        "@com_github_microsoft_seal//:seal",
        "@cppzmq//:cppzmq_cmake",
        "@kuku//:kuku_static",
        "@local_flatbuffers//:flatbuffers_static",
        "@local_jsoncpp//:jsoncpp_static",
        "@local_log4cplus//:log4cplus_static",
        "@local_zmq//:zmq_static",
        "@microsoft_gsl//:gsl_cmake",
    ],
    lib_source = ":all_srcs",
    out_include_dir = "include/APSI-0.11",
    out_lib_dir = "lib",
    out_static_libs = ["libapsi-0.11.a"],
    targets = ["install"],
)

cc_library(
    name = "apsi",
    linkopts = [
        "-pthread",
    ],
    deps = [
        ":apsi_static",
        "@kuku//:kuku",
        "@local_flatbuffers//:flatbuffers",
        "@local_jsoncpp//:jsoncpp",
        "@local_log4cplus//:log4cplus",
        "@local_zmq//:zmq",
        "@microsoft_gsl//:gsl",
        "@seal//:seal",
    ],
)
