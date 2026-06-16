# Copyright 2026 Guowei Ling.
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

load("@rules_cc//cc:defs.bzl", "cc_library")
load("@rules_foreign_cc//foreign_cc:defs.bzl", "make")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all_srcs",
    srcs = glob(
        ["**"],
        exclude = [
            "**/.git/**",
            "**/*.d",
            "**/*.o",
            "**/*.x",
            "bazel-*",
            "local/**",
            "static/**",
        ],
    ),
)

filegroup(
    name = "compiler",
    srcs = glob(["Compiler/**"]) + [
        "compile.py",
        "setup.py",
    ],
)

filegroup(
    name = "programs",
    srcs = glob(["Programs/**"]),
)

filegroup(
    name = "scripts",
    srcs = glob(["Scripts/**"]),
)

cc_library(
    name = "headers",
    hdrs = glob(
        [
            "**/*.h",
            "**/*.hpp",
        ],
        exclude = [
            "**/.git/**",
            "bazel-*",
            "local/**",
            "static/**",
        ],
    ),
    defines = [
        "PREP_DIR=\\\"Player-Data/\\\"",
        "SSL_DIR=\\\"Player-Data/\\\"",
        "USE_GF2N_LONG",
    ],
    includes = [
        ".",
        "deps",
        "deps/libOTe",
        "deps/libOTe/cryptoTools",
    ],
    linkopts = [
        "-ldl",
        "-pthread",
    ],
    deps = [
        "@boost//:asio",
        "@boost//:asio_ssl",
        "@boost//:filesystem",
        "@boost//:iostreams",
        "@boost//:thread",
        "@com_github_libsodium//:libsodium",
        "@com_github_openssl_openssl//:openssl",
        "@system_gmp//:gmpxx",
        "@system_ntl//:ntl",
    ],
)

make(
    name = "mascot_party",
    args = [
        "-j",
        "8",
        "CXX=/usr/bin/g++",
        "LD=/usr/bin/g++",
        "MY_CFLAGS='-Wno-unused-parameter -Wno-uninitialized -Wno-maybe-uninitialized'",
    ],
    env = {
        "ASFLAGS": "",
        "CFLAGS": "",
        "CPPFLAGS": "",
        "CXXFLAGS": "",
        "LDFLAGS": "",
    },
    lib_source = ":all_srcs",
    out_binaries = ["mascot-party.x"],
    out_shared_libs = ["libSPDZ.so"],
    postfix_script = """
mkdir -p $$INSTALLDIR$$/bin
mkdir -p $$INSTALLDIR$$/lib
cp -L mascot-party.x $$INSTALLDIR$$/bin/mascot-party.x
cp -L libSPDZ.so $$INSTALLDIR$$/lib/libSPDZ.so
""",
    targets = ["mascot-party.x"],
    tool_prefix = "perl -0pi -e 's#-lsodium#/usr/lib/x86_64-linux-gnu/libsodium.so.23#g; s#-lboost_filesystem#/usr/local/lib/libboost_filesystem.so#g' CONFIG && perl -0pi -e 's#touch ../../local/lib/liblibOTe.a#mkdir -p ../../local/lib ; touch ../../local/lib/liblibOTe.a#' Makefile && sed -i 's/\\$$(LDLIBS) \\$$(SHAREDLIB)/$$(LDLIBS) $$(SHAREDLIB) $$(LDLIBS)/' Makefile && perl -0pi -e 's#boost::asio::post\\(std::move\\(fn\\)\\);#boost::asio::post(ios->mIoService, std::move(fn));#' deps/libOTe/cryptoTools/cryptoTools/Network/IOService.cpp && perl -0pi -e 's@\\A@#include <cmath>\\n@' deps/libOTe/libOTe/TwoChooseOne/SilentOtExtSender.cpp && perl -0pi -e 's@\\A@#include <cmath>\\n@; s@\\blround\\(@std::lround(@g' deps/libOTe/frontend/ExampleTwoChooseOne.h && printf 'unexport CFLAGS\\nunexport CXXFLAGS\\nunexport CPPFLAGS\\nunexport LDFLAGS\\nOTE_OPTS += -DBoost_NO_BOOST_CMAKE=ON -DBOOST_ROOT=/usr/local -DBOOST_LIBRARYDIR=/usr/local/lib -DCMAKE_HAVE_PTHREAD_CREATE=1\\n' > CONFIG.mine && cmake -S deps/SimplestOT_C/ref10 -B deps/SimplestOT_C/ref10 &&",
)
