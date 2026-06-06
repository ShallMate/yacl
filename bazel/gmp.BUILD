load("@yacl//bazel:yacl.bzl", "yacl_configure_make")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all_srcs",
    srcs = glob(["**"]),
)

yacl_configure_make(
    name = "gmp_foreign",
    configure_in_place = True,
    configure_options = [
        "CXX=g++",
        "--disable-shared",
        "--enable-cxx",
        "--enable-static",
    ],
    lib_name = "gmp",
    lib_source = ":all_srcs",
    out_static_libs = [
        "libgmpxx.a",
        "libgmp.a",
    ],
)

alias(
    name = "gmp",
    actual = ":gmp_foreign",
)

alias(
    name = "gmpxx",
    actual = ":gmp_foreign",
)
