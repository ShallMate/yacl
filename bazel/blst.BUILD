# Copyright 2026 Guowei Ling
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

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "blst",
    srcs = [
        "build/assembly.S",
        "src/server.c",
    ],
    hdrs = glob(["bindings/*.h"]),
    textual_hdrs = glob([
        "build/elf/*.s",
        "src/*.c",
        "src/*.h",
    ]),
    copts = [
        "-O3",
        "-D__ADX__",
        "-fno-builtin",
        "-fPIC",
        "-Wno-error",
    ],
    includes = [
        "bindings",
        "build",
        "src",
    ],
)
