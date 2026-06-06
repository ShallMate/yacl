load("@yacl//bazel:yacl.bzl", "yacl_configure_make")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all_srcs",
    srcs = glob(["**"]),
)

yacl_configure_make(
    name = "ntl_foreign",
    args = ["-j 8"],
    configure_command = "src/configure",
    configure_in_place = True,
    configure_prefix = "cd src &&",
    configure_options = [
        "CXX=g++",
        "NATIVE=off",
        "NTL_GF2X_LIB=off",
        "NTL_GMP_LIP=off",
        "NTL_STD_CXX11=on",
        "NTL_THREADS=on",
        "SHARED=off",
    ],
    lib_name = "ntl",
    lib_source = ":all_srcs",
    out_static_libs = ["libntl.a"],
    prefix_flag = "PREFIX=",
)

alias(
    name = "ntl",
    actual = ":ntl_foreign",
)
