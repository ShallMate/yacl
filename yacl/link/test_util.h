// Copyright 2019 Ant Group Co., Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#pragma once

#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>

#include <future>
#include <stdexcept>
#include <vector>

#include "fmt/format.h"
#include "yacl/base/buffer.h"
#include "yacl/link/context.h"
#include "yacl/link/factory.h"

namespace yacl::link::test {

///////////////////////////////////////////////////////////////////////////////
// Utility: check whether a TCP port on 127.0.0.1 is available
///////////////////////////////////////////////////////////////////////////////
inline bool IsPortAvailable(uint16_t port) {
  int fd = ::socket(AF_INET, SOCK_STREAM, 0);
  if (fd < 0) {
    return false;
  }

  int opt = 1;
  ::setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

  sockaddr_in addr;
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);  // 127.0.0.1
  addr.sin_port = htons(port);

  bool ok = (::bind(fd, reinterpret_cast<sockaddr*>(&addr), sizeof(addr)) == 0);

  ::close(fd);
  return ok;
}

///////////////////////////////////////////////////////////////////////////////
// SetupBrpcWorld with automatic port probing
///////////////////////////////////////////////////////////////////////////////
inline std::vector<std::shared_ptr<Context>> SetupBrpcWorld(
    const std::string& id, size_t world_size) {
  ContextDesc ctx_desc;

  // Start probing from default base port
  uint16_t port = 10086;

  // Allocate ports for all ranks first
  for (size_t rank = 0; rank < world_size; rank++) {
    // Find the next available port
    while (!IsPortAvailable(port)) {
      ++port;
      if (port == 0) {
        throw std::runtime_error("SetupBrpcWorld: no available TCP port found");
      }
    }

    const auto party_id = fmt::format("{}-{}", id, rank);
    const auto host = fmt::format("127.0.0.1:{}", port);
    ctx_desc.parties.push_back({party_id, host});

    ++port;  // ensure uniqueness inside the same world
  }

  // Create contexts
  std::vector<std::shared_ptr<Context>> contexts(world_size);
  for (size_t rank = 0; rank < world_size; rank++) {
    contexts[rank] = FactoryBrpc().CreateContext(ctx_desc, rank);
  }

  // Connect mesh concurrently
  auto proc = [&](size_t rank) {
    contexts[rank]->ConnectToMesh();
    // Disable throttle so SendAsync won't block
    contexts[rank]->SetThrottleWindowSize(0);
  };

  std::vector<std::future<void>> jobs(world_size);
  for (size_t rank = 0; rank < world_size; rank++) {
    jobs[rank] = std::async(std::launch::async, proc, rank);
  }

  for (size_t rank = 0; rank < world_size; rank++) {
    jobs[rank].get();
  }

  return contexts;
}

///////////////////////////////////////////////////////////////////////////////
// Overload: default id
///////////////////////////////////////////////////////////////////////////////
inline std::vector<std::shared_ptr<Context>> SetupBrpcWorld(size_t world_size) {
  auto id = fmt::format("world_{}", world_size);
  return SetupBrpcWorld(id, world_size);
}

///////////////////////////////////////////////////////////////////////////////
// In-memory world (unchanged)
///////////////////////////////////////////////////////////////////////////////
inline std::vector<std::shared_ptr<Context>> SetupWorld(const std::string& id,
                                                        size_t world_size) {
  ContextDesc ctx_desc;
  ctx_desc.id = id;

  for (size_t rank = 0; rank < world_size; rank++) {
    ctx_desc.parties.push_back(
        {fmt::format("dummy_id:{}", rank), "dummy_host"});
  }

  std::vector<std::shared_ptr<Context>> contexts(world_size);
  for (size_t rank = 0; rank < world_size; rank++) {
    contexts[rank] = FactoryMem().CreateContext(ctx_desc, rank);
  }

  auto proc = [&](size_t rank) { contexts[rank]->ConnectToMesh(); };

  std::vector<std::future<void>> jobs(world_size);
  for (size_t rank = 0; rank < world_size; rank++) {
    jobs[rank] = std::async(std::launch::async, proc, rank);
  }

  for (size_t rank = 0; rank < world_size; rank++) {
    jobs[rank].get();
  }

  return contexts;
}

inline std::vector<std::shared_ptr<Context>> SetupWorld(size_t world_size) {
  auto id = fmt::format("world_{}", world_size);
  return SetupWorld(id, world_size);
}

///////////////////////////////////////////////////////////////////////////////
// Helper
///////////////////////////////////////////////////////////////////////////////
inline std::string MakeRoundData(size_t rank, size_t round) {
  const auto spaces = std::string(rank, '_');
  return fmt::format("d:{},{},r:{}", rank, spaces, round);
}

}  // namespace yacl::link::test
