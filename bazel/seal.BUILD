# Copyright 2022 Ant Group Co., Ltd.
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

load("@yacl//bazel:yacl.bzl", "yacl_cmake_external")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all",
    srcs = glob(["**"]),
)

config_setting(
    name = "can_use_hexl",
    constraint_values = [
        "@platforms//cpu:x86_64",
    ],
    values = {"compilation_mode": "opt"},
)

config_setting(
    name = "enable_hexl",
    values = {"define": "seal_hexl=true"},
)

default_config = {
    "SEAL_USE_MSGSL": "OFF",
    "SEAL_BUILD_DEPS": "OFF",
    "SEAL_USE_ZLIB": "OFF",
    "SEAL_USE_INTEL_HEXL": "OFF",
    "SEAL_THROW_ON_TRANSPARENT_CIPHERTEXT": "OFF",  #NOTE(juhou) required by apsi
    "SEAL_USE_ZSTD": "ON",
    "CMAKE_INSTALL_LIBDIR": "lib",
}

x64_hexl_config = {
    "SEAL_USE_MSGSL": "OFF",
    "SEAL_BUILD_DEPS": "ON",
    "SEAL_USE_ZLIB": "OFF",
    "SEAL_THROW_ON_TRANSPARENT_CIPHERTEXT": "OFF",  #NOTE(juhou) required by apsi
    "CMAKE_INSTALL_LIBDIR": "lib",
    "SEAL_USE_ZSTD": "ON",
    "SEAL_USE_INTEL_HEXL": "ON",
}

config_setting(
    name = "enable_hexl_on_x64",
    values = {
        "define": "seal_hexl=true",
        "compilation_mode": "opt",
    },
    constraint_values = [
        "@platforms//cpu:x86_64",
    ],
)

yacl_cmake_external(
    name = "seal",
    cache_entries = select({
        ":enable_hexl_on_x64": x64_hexl_config,
        "//conditions:default": default_config,
    }),
    lib_source = "@com_github_microsoft_seal//:all",
    out_include_dir = "include/SEAL-4.1",
    out_static_libs = ["libseal-4.1.a"],
    deps = [
        "@com_github_facebook_zstd//:zstd",
    ],
)
