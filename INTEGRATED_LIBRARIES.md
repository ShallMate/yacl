# YACL Integrated Libraries

本文档按当前 `bazel/repositories.bzl` 梳理 YACL 已接入的外部库。这里的“接入”指 YACL 通过 Bazel repository rule、BUILD wrapper、兼容 alias 或本地包装仓库直接声明并可被 Bazel target 依赖的库；不展开每个上游项目在 CMake 内部再次拉取的间接依赖。

## 依赖加载层级

| 层级 | 入口 | 含义 |
| --- | --- | --- |
| Core | `yacl_deps()` | 构建 `yacl/` 主库和基础组件时默认声明的依赖。 |
| Example | `yacl_deps(include_examples = True)` / `yacl_example_deps()` | `examples/` 下协议、论文复现、HE/PSI/MPC 示例需要的重依赖。 |
| Dev | `yacl_deps(include_dev = True)` / `yacl_dev_deps()` | 本地开发辅助依赖，例如 compile commands 生成。 |

## 构建规则与工具链

| 库/规则 | Bazel repository | 层级 | 用途 |
| --- | --- | --- | --- |
| Bazel rules_proto | `@rules_proto` | Core | Protobuf Bazel 规则。 |
| Bazel rules_python | `@rules_python` | Core | Python 规则，主要服务 Protobuf/脚本工具。 |
| rules_foreign_cc | `@rules_foreign_cc` | Core | 用 CMake/configure/make 构建上游 C/C++ 项目。 |
| rules_boost | `@com_github_nelhage_rules_boost` / `@boost` | Core | 为 Boost 组件提供 Bazel 包装。 |
| LLVM archives | `@llvm-bazel`, `@llvm-project-raw` | Example | 示例中需要 LLVM/MLIR 相关源码归档时使用。 |

## C++ 基础设施

| 库 | Bazel repository / label | 层级 | 用途 |
| --- | --- | --- | --- |
| Abseil | `@com_google_absl` | Core | 通用 C++ 基础库。 |
| gflags | `@com_github_gflags_gflags` | Core | 命令行 flag。 |
| glog | `@com_github_google_glog` | Example | 示例和上游协议库日志。 |
| fmt | `@com_github_fmtlib_fmt` | Core | 格式化输出。 |
| spdlog | `@com_github_gabime_spdlog` | Core | 日志库。 |
| GoogleTest | `@com_google_googletest` | Core | 单元测试。 |
| Google Benchmark | `@com_github_google_benchmark` | Core | 基准测试。 |
| LevelDB | `@com_github_google_leveldb` | Core | KV 存储。 |
| libdivide | `@com_github_ridiculousfish_libdivide` | Core | 快速整数除法。 |
| cpu_features | `@com_github_google_cpu_features` | Core | CPU 特性检测。 |
| sse2neon | `@com_github_dltcollab_sse2neon` | Core | x86 SIMD 到 ARM NEON 的兼容层。 |
| Eigen | `@eigen` | Example | 线性代数和部分上游示例依赖。 |
| Microsoft GSL | `@microsoft_gsl` | Example | APSI/SEAL 相关上游依赖。 |
| function2 | `@com_github_naios_function2//:function2` | Example | ABY3 相关 C++ callable 工具库。 |

## 序列化、压缩与数据格式

| 库 | Bazel repository / label | 层级 | 用途 |
| --- | --- | --- | --- |
| Protobuf | `@com_google_protobuf` | Core | RPC/序列化。 |
| msgpack-c | `@com_github_msgpack_msgpack` | Core | MessagePack 编解码。 |
| zlib | `@zlib` | Core | 压缩。 |
| Zstandard | `@com_github_facebook_zstd` | Core | 压缩，SEAL/APSI 等也会用到。 |
| FlatBuffers | `@local_flatbuffers` | Example | APSI 支撑依赖。 |
| jsoncpp | `@local_jsoncpp` | Example | APSI 支撑依赖。 |
| nlohmann/json | `@com_github_nlohmann_json//:json` | Example | ABY3/示例侧 JSON 支撑库。 |

## 网络与通信

| 库 | Bazel repository / label | 层级 | 用途 |
| --- | --- | --- | --- |
| brpc | `@com_github_brpc_brpc` | Core | RPC 通信。 |
| ZeroMQ | `@local_zmq` | Example | APSI/示例通信支撑。 |
| cppzmq | `@cppzmq` | Example | ZeroMQ C++ header wrapper。 |
| log4cplus | `@local_log4cplus` | Example | APSI 日志支撑。 |
| GLib wrapper | `@system_glib//:glib` | Example | 需要 GLib 头文件的示例兼容包装。 |

## 密码学基础库与数学库

| 库 | Bazel repository / label | 层级 | 用途 |
| --- | --- | --- | --- |
| OpenSSL | `@com_github_openssl_openssl//:openssl` | Core | TLS/哈希/对称密码/大数等基础能力。 |
| BLAKE3 | `@com_github_blake3team_blake3` | Core | BLAKE3 哈希。 |
| libsodium | `@com_github_libsodium` | Core | 现代密码学基础库。 |
| Hash-DRBG | `@com_github_greendow_hash_drbg` | Core | DRBG 随机数生成。 |
| libtommath | `@com_github_libtom_libtommath` | Core | 多精度整数。 |
| GMP | `@system_gmp//:gmp`, `@system_gmp//:gmpxx` | Example | 大整数和部分协议库依赖。 |
| NTL | `@system_ntl//:ntl` | Example | 数论库，PSI/OT 相关示例使用。 |
| MCL | `@com_github_herumi_mcl` | Core | pairing/椭圆曲线相关数学库。 |
| BLST | `@com_github_supranational_blst` | Example | BLS12-381 相关实现。 |
| RELIC | `@local_relic` | Example | pairing/群运算，上游 ABY/协议示例可能使用。 |
| FourQlib | `@com_github_microsoft_FourQlib` | Core | FourQ 椭圆曲线实现。 |
| lib25519 | `@lib25519` | Core | Curve25519/Ed25519 相关实现。 |
| curve25519-donna | `@com_github_agl_curve25519_donna` | Core | Curve25519 实现。 |
| ed25519-donna | `@com_github_floodyberry_ed25519_donna` | Core | Ed25519 实现。 |

## 同态加密与 FHE

| 库 | Bazel repository / label | 层级 | 用途 |
| --- | --- | --- | --- |
| Microsoft SEAL | `@com_github_microsoft_seal//:seal` | Core | BFV/CKKS 等同态加密能力；`@seal//:seal` 是示例兼容 alias。 |
| OpenFHE | `@openfhe//:openfhe` | Example | OpenFHE CMake 构建包装，`examples/mkbfv` 使用。 |
| APSI | `@local_apsi` | Example | Microsoft APSI，基于 SEAL 的 PSI 支撑库。 |
| Kuku | `@kuku` | Example | APSI 使用的 cuckoo hashing 支撑库。 |

## OT、VOLE、PSI、PSU 与 MPC 协议库

| 库 | Bazel repository / label | 层级 | 用途 |
| --- | --- | --- | --- |
| simplest-ot | `@simplest_ot` | Core | 基础 OT 实现。 |
| interconnection | `@org_interconnection` | Core | SecretFlow interconnection 支撑库。 |
| libOTe | `@com_github_osu_crypto_libote` | Example | OT/VOLE/PSI 生态核心依赖，提供 `headers`、`all_deps` 等 wrapper。 |
| MP-SPDZ | `@com_github_data61_mp_spdz` | Example | MPC 框架；`examples/mp_spdz` 提供 ExternalIO 和 MASCOT tutorial 示例。 |
| ABY | `@com_github_encryptogroup_aby//:aby` | Example | Two-party mixed-protocol MPC 框架。 |
| ABY3 | `@com_github_ladnir_aby3//:aby3` | Example | Three-party MPC 框架，同时包装 `aby3_db`、`aby3_ml`。 |
| EMP-tool | `@local_emp_tool//:emp-tool` | Example | EMP toolkit 基础工具库。 |
| EMP-OT | `@local_emp_ot//:emp-ot` | Example | EMP OT 扩展库。 |
| VOLE-PSI | `@local_volepsi//:volepsi` | Example | VOLE/OPPRF/PSI 相关示例依赖。 |
| secure-join | `@local_secure_join_usr//:securejoin` | Example | secure join / GMW / permutation 相关示例依赖。 |
| SecurePSU | `@securepsu` | Example | SecurePSU 上游实现包装。 |
| LibPSI compatibility | `@libpsi_install` | Example | `examples/libPSI` 的头文件和前端依赖兼容包装。 |
| MiniPSI legacy deps | `@minipsi_external` | Example | `examples/MiniPSI` 的 legacy 静态库和头文件包装。 |

## 示例兼容包装与本地适配

| 包装 | Bazel repository / label | 层级 | 用途 |
| --- | --- | --- | --- |
| SEAL compatibility alias | `@seal//:seal` | Example | 让旧示例继续通过 `@seal` 依赖 Microsoft SEAL。 |
| circuitpsu1 VOLE-PSI alias | `@local_circuitpsu1_volepsi` | Example | 为 `examples/circuitpsu1` 提供兼容 label。 |
| circuitpsu1 secure-join alias | `@local_circuitpsu1_securejoin` | Example | 为 `examples/circuitpsu1` 提供 secure-join 兼容 label。 |
| macOS OpenMP local wrapper | `@macos_omp_x64`, `@macos_omp_arm64` | Core | macOS Homebrew OpenMP 头文件/库兼容入口。 |

## 开发辅助依赖

| 库/工具 | Bazel repository / label | 层级 | 用途 |
| --- | --- | --- | --- |
| google shell rules stub | `@com_github_google_shell` | Dev | shell 规则/开发辅助。 |
| Hedron compile commands | `@hedron_compile_commands` | Dev | 生成 `compile_commands.json`。 |

## 近期重点接入状态

下面这些库已经有明确 Bazel wrapper 或示例目标：

| 库 | 代表目标 | 当前状态 |
| --- | --- | --- |
| MP-SPDZ | `//examples/mp_spdz:run_mascot_tutorial` | 已接入，示例会通过 MP-SPDZ `compile-run.py mascot` 跑 tutorial。 |
| ABY | `//examples/aby:aby_smoke` | 已接入，smoke 示例验证头文件、链接和运行路径。 |
| ABY3 | `//examples/aby3:aby3_smoke` | 已接入，smoke 示例验证头文件、链接和运行路径。 |
| EMP-toolkit | `@local_emp_tool//:emp-tool`, `@local_emp_ot//:emp-ot` | 已接入为 example-only 依赖。 |
| OpenFHE | `//examples/mkbfv:main` | 已接入，示例依赖 `@openfhe`。 |
| SEAL | `//examples/occ:occ_demo`、`@seal//:seal` | 已接入，多个 HE/PSI/PSU 示例使用。 |
