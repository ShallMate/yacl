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

yacl_deps(
    include_dev = True,
    include_examples = True,
)

load("@com_github_nelhage_rules_boost//:boost/boost.bzl", "boost_deps")

boost_deps()

load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()

load(
    "@rules_foreign_cc//foreign_cc:repositories.bzl",
    "rules_foreign_cc_dependencies",
)

rules_foreign_cc_dependencies(
    native_tools_toolchains = [
        "@yacl//bazel:usr_bin_autoconf_toolchain",
        "@yacl//bazel:usr_bin_automake_toolchain",
        "@yacl//bazel:usr_bin_m4_toolchain",
        "@yacl//bazel:usr_bin_make_toolchain",
        "@yacl//bazel:usr_bin_pkgconfig_toolchain",
    ],
    register_built_tools = True,
    register_default_tools = True,
    register_preinstalled_tools = False,
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

load("@hedron_compile_commands//:workspace_setup.bzl", "hedron_compile_commands_setup")

hedron_compile_commands_setup()

load("@llvm-bazel//:terminfo.bzl", "llvm_terminfo_disable")

llvm_terminfo_disable(name = "llvm_terminfo")

load("@llvm-bazel//:zlib.bzl", "llvm_zlib_disable")

llvm_zlib_disable(name = "llvm_zlib")

load("@llvm-bazel//:configure.bzl", "llvm_configure")

llvm_configure(
    name = "llvm-project",
    src_path = ".",
    src_workspace = "@llvm-project-raw//:WORKSPACE",
)
