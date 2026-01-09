# Copyright 2023 Ant Group Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

workspace(name = "yacl")

load("//bazel:repositories.bzl", "yacl_deps")

yacl_deps()

load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()

load(
    "@rules_foreign_cc//foreign_cc:repositories.bzl",
    "rules_foreign_cc_dependencies",
)

rules_foreign_cc_dependencies(
    register_built_tools = False,
    register_default_tools = False,
    register_preinstalled_tools = True,
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()


new_local_repository(
    name = "local_apsi",
    path = "/usr/local",
    build_file_content = """
cc_library(
    name = "apsi",
    hdrs = glob(["include/APSI-0.11/**/*.h"]),
    srcs = [],
    includes = ["include/APSI-0.11"],
    linkopts = ["-Llib", "-lapsi-0.11"],
    visibility = ["//visibility:public"],
)
    """,
)

new_local_repository(
    name = "seal",
    path = "/usr/local",
    build_file_content = """
cc_library(
    name = "seal",
    hdrs = glob(["include/SEAL-4.1/**/*.h"]),
    srcs = [],
    includes = ["include"],
    linkopts = ["-Llib", "-lseal-4.1"],
    visibility = ["//visibility:public"],
)
    """,
)

new_local_repository(
    name = "kuku",
    path = "/usr/local",
    build_file_content = """
cc_library(
    name = "kuku",
    hdrs = glob(["include/Kuku-2.1/**/*.h"]),
    srcs = [],
    includes = ["include"],
    linkopts = ["-Llib", "-lkuku-2.1"],
    visibility = ["//visibility:public"],
)
    """,
)

new_local_repository(
    name = "openfhe",
    path = "/usr/local",
    build_file_content = """
OPENFHE_LIBS = glob([
    "lib/libOPENFHE*.so*",
    "lib/libOPENFHE*.a*",
    "lib64/libOPENFHE*.so*",
    "lib64/libOPENFHE*.a*",
])

cc_library(
    name = "openfhe",
    hdrs = glob([
        "include/openfhe/**/*.h",
        "include/openfhe/**/*.hpp",
    ]),
    # 关键：把 .so/.a 声明为 srcs，Bazel 才会把它们作为链接输入带进 sandbox
    srcs = OPENFHE_LIBS,
    includes = [
        "include",
        "include/openfhe",
        "include/openfhe/core",
        "include/openfhe/pke",
        "include/openfhe/binfhe",
    ],
    # 这里只保留“系统依赖库”，OpenFHE 自己的库文件已经在 srcs 里了
    linkopts = [
        "-ldl",
        "-lgomp",
        "-lntl",
    ],
    visibility = ["//visibility:public"],
)
""",
)






load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository") 


git_repository(
    name = "hedron_compile_commands",
    commit = "d7a28301d812aeafa36469343538dbc025cec196",
    remote = "https://github.com/hedronvision/bazel-compile-commands-extractor.git",
)

load("@hedron_compile_commands//:workspace_setup.bzl", "hedron_compile_commands_setup")

hedron_compile_commands_setup()


