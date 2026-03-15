// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "shell_encryption/prng/hkdf_prng_util.h"

#include <vector>

#include <openssl/evp.h>
#include <openssl/kdf.h>
#include <openssl/rand.h>

#include "absl/memory/memory.h"
#include "absl/strings/str_cat.h"
#include "shell_encryption/status_macros.h"

namespace rlwe::internal {

namespace {

rlwe::StatusOr<std::string> ComputeHkdfSha256(absl::string_view key,
                                              absl::string_view salt,
                                              absl::string_view info,
                                              int output_len) {
  std::string output(output_len, '\0');
  EVP_PKEY_CTX* raw_ctx = EVP_PKEY_CTX_new_id(EVP_PKEY_HKDF, nullptr);
  if (raw_ctx == nullptr) {
    return absl::InternalError("Failed to allocate HKDF context.");
  }
  std::unique_ptr<EVP_PKEY_CTX, decltype(&EVP_PKEY_CTX_free)> ctx(
      raw_ctx, &EVP_PKEY_CTX_free);

  if (EVP_PKEY_derive_init(ctx.get()) <= 0) {
    return absl::InternalError("Failed to initialize HKDF context.");
  }
  if (EVP_PKEY_CTX_set_hkdf_md(ctx.get(), EVP_sha256()) <= 0) {
    return absl::InternalError("Failed to configure HKDF digest.");
  }
  if (EVP_PKEY_CTX_set1_hkdf_salt(
          ctx.get(), reinterpret_cast<const unsigned char*>(salt.data()),
          salt.size()) <= 0) {
    return absl::InternalError("Failed to configure HKDF salt.");
  }
  if (EVP_PKEY_CTX_set1_hkdf_key(
          ctx.get(), reinterpret_cast<const unsigned char*>(key.data()),
          key.size()) <= 0) {
    return absl::InternalError("Failed to configure HKDF key.");
  }
  if (!info.empty() &&
      EVP_PKEY_CTX_add1_hkdf_info(
          ctx.get(), reinterpret_cast<const unsigned char*>(info.data()),
          info.size()) <= 0) {
    return absl::InternalError("Failed to configure HKDF info.");
  }

  size_t derived_len = output.size();
  if (EVP_PKEY_derive(ctx.get(),
                      reinterpret_cast<unsigned char*>(output.data()),
                      &derived_len) <= 0) {
    return absl::InternalError("Failed to derive HKDF output.");
  }
  if (derived_len != output.size()) {
    return absl::InternalError("Unexpected HKDF output size.");
  }
  return output;
}

}  // namespace

absl::Status HkdfPrngResalt(absl::string_view key, int buffer_size,
                            int* salt_counter, int* position_in_buffer,
                            std::vector<Uint8>* buffer) {
  std::string salt = absl::StrCat("salt", *salt_counter);
  RLWE_ASSIGN_OR_RETURN(std::string buf,
                        ComputeHkdfSha256(key, salt, "", buffer_size));
  buffer->assign(buf.begin(), buf.end());
  ++(*salt_counter);
  *position_in_buffer = 0;

  return absl::OkStatus();
}

rlwe::StatusOr<std::string> HkdfPrngGenerateKey() {
  std::string key(kHkdfKeyBytesSize, '\0');
  if (RAND_bytes(reinterpret_cast<unsigned char*>(key.data()), key.size()) !=
      1) {
    return absl::InternalError("Internal error generating random PRNG key.");
  }
  return key;
}

rlwe::StatusOr<Uint8> HkdfPrngRand8(absl::string_view key,
                                    int* position_in_buffer, int* salt_counter,
                                    std::vector<Uint8>* buffer) {
  Uint8 rand;
  if (*position_in_buffer >= buffer->size()) {
    RLWE_RETURN_IF_ERROR(HkdfPrngResalt(key, kHkdfMaxOutputBytes, salt_counter,
                                        position_in_buffer, buffer));
  }
  rand = buffer->at(*position_in_buffer);
  ++(*position_in_buffer);
  return rand;
}

rlwe::StatusOr<Uint64> HkdfPrngRand64(absl::string_view key,
                                      int* position_in_buffer,
                                      int* salt_counter,
                                      std::vector<Uint8>* buffer) {
  Uint64 rand64 = 0;
  for (int i = 0; i < 8; ++i) {
    RLWE_ASSIGN_OR_RETURN(Uint8 rand8, HkdfPrngRand8(key, position_in_buffer,
                                                     salt_counter, buffer));
    rand64 += Uint64{rand8} << (8 * i);
  }
  return rand64;
}

}  // namespace rlwe::internal
