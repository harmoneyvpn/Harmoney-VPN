#include <winsock2.h>
#include <ws2tcpip.h>
#include <mstcpip.h>
#include <windows.h>

#include <array>
#include <atomic>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <memory>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

#pragma comment(lib, "Ws2_32.lib")

namespace {

constexpr size_t kMaxRedirectBlob = 64 * 1024;
constexpr size_t kBufferSize = 64 * 1024;
constexpr DWORD kUdpRedirectIoctl = 0x00124008;
constexpr DWORD kUdpFlowTimeoutMs = 120000;
constexpr int kUdpFlowTimeoutError = WSAETIMEDOUT;

struct UdpFlow {
  SOCKET upstream = INVALID_SOCKET;
  SOCKADDR_STORAGE client{};
  SOCKADDR_STORAGE destination{};
  std::atomic<bool> active{true};
  std::mutex socket_mutex;
};

std::mutex g_udp_flows_mutex;
std::vector<std::shared_ptr<UdpFlow>> g_udp_flows;
HANDLE g_driver_device = INVALID_HANDLE_VALUE;

struct WsaRuntime {
  WsaRuntime() {
    WSADATA data{};
    status = WSAStartup(MAKEWORD(2, 2), &data);
  }
  ~WsaRuntime() {
    if (status == 0) WSACleanup();
  }
  int status = 0;
};

std::string socket_error(const char* operation) {
  return std::string(operation) + " failed (Winsock " +
         std::to_string(WSAGetLastError()) + ")";
}

bool query_blob(SOCKET socket, DWORD control_code,
                std::vector<unsigned char>* result) {
  // WSAIoctl's WFP redirect metadata queries do not reliably report the
  // required size when called with a null/zero-length output buffer. Supply a
  // bounded buffer on the first call instead; the metadata is opaque to the
  // relay and is only copied onto its outbound socket.
  result->resize(kMaxRedirectBlob);
  DWORD returned = 0;
  if (WSAIoctl(socket, control_code, nullptr, 0, result->data(),
               static_cast<DWORD>(result->size()), &returned, nullptr,
               nullptr) == SOCKET_ERROR) {
    std::fprintf(stderr, "%s (buffer=%zu)\n",
                 socket_error("WSAIoctl query").c_str(), result->size());
    result->clear();
    return false;
  }
  if (returned == 0 || returned > result->size()) {
    std::fprintf(stderr, "redirect metadata size is invalid: %lu\n",
                 static_cast<unsigned long>(returned));
    result->clear();
    return false;
  }
  result->resize(returned);
  return !result->empty();
}

bool apply_redirect_records(SOCKET socket,
                            const std::vector<unsigned char>& records) {
  DWORD returned = 0;
  if (WSAIoctl(socket, SIO_SET_WFP_CONNECTION_REDIRECT_RECORDS,
               const_cast<unsigned char*>(records.data()),
               static_cast<DWORD>(records.size()), nullptr, 0, &returned,
               nullptr, nullptr) == SOCKET_ERROR) {
    std::fprintf(stderr, "%s\n",
                 socket_error("set WFP redirect records").c_str());
    return false;
  }
  return true;
}

bool set_outbound_interface(SOCKET socket, int family, DWORD interface_index) {
  if (family == AF_INET) {
    // IP_UNICAST_IF expects the interface index in network byte order.
    const DWORD index = htonl(interface_index);
    if (setsockopt(socket, IPPROTO_IP, IP_UNICAST_IF,
                   reinterpret_cast<const char*>(&index), sizeof(index)) ==
        SOCKET_ERROR) {
      std::fprintf(stderr, "%s\n",
                   socket_error("set IPv4 outbound interface").c_str());
      return false;
    }
    return true;
  }
  if (family == AF_INET6) {
    // IPV6_UNICAST_IF uses a DWORD interface index in host byte order.
    if (setsockopt(socket, IPPROTO_IPV6, IPV6_UNICAST_IF,
                   reinterpret_cast<const char*>(&interface_index),
                   sizeof(interface_index)) == SOCKET_ERROR) {
      std::fprintf(stderr, "%s\n",
                   socket_error("set IPv6 outbound interface").c_str());
      return false;
    }
    return true;
  }
  return false;
}

bool parse_redirect_destination(const std::vector<unsigned char>& context,
                                SOCKADDR_STORAGE* destination,
                                SOCKADDR_STORAGE* original_local) {
  // The paired WFP callout writes [original remote sockaddr, original local
  // sockaddr] as two SOCKADDR_STORAGE values in localRedirectContext.
  if (context.size() < sizeof(SOCKADDR_STORAGE) * 2) {
    std::fprintf(stderr, "redirect context has an unsupported layout\n");
    return false;
  }
  std::memcpy(destination, context.data(), sizeof(*destination));
  std::memcpy(original_local, context.data() + sizeof(*destination),
              sizeof(*original_local));
  if (destination->ss_family != AF_INET &&
      destination->ss_family != AF_INET6) {
    std::fprintf(stderr, "redirected destination has unsupported address family\n");
    return false;
  }
  return true;
}

std::string format_endpoint(const SOCKADDR_STORAGE& endpoint);

bool same_endpoint(const SOCKADDR_STORAGE& left,
                   const SOCKADDR_STORAGE& right) {
  if (left.ss_family != right.ss_family) return false;
  if (left.ss_family == AF_INET) {
    const auto* l = reinterpret_cast<const SOCKADDR_IN*>(&left);
    const auto* r = reinterpret_cast<const SOCKADDR_IN*>(&right);
    return l->sin_port == r->sin_port &&
           l->sin_addr.s_addr == r->sin_addr.s_addr;
  }
  if (left.ss_family == AF_INET6) {
    const auto* l = reinterpret_cast<const SOCKADDR_IN6*>(&left);
    const auto* r = reinterpret_cast<const SOCKADDR_IN6*>(&right);
    return l->sin6_port == r->sin6_port &&
           l->sin6_scope_id == r->sin6_scope_id &&
           std::memcmp(&l->sin6_addr, &r->sin6_addr,
                       sizeof(l->sin6_addr)) == 0;
  }
  return false;
}

bool query_udp_destination(const SOCKADDR_STORAGE& client,
                           SOCKADDR_STORAGE* destination) {
  SOCKADDR_STORAGE buffer = client;
  DWORD returned = 0;
  if (!DeviceIoControl(g_driver_device, kUdpRedirectIoctl, &buffer,
                       sizeof(buffer), &buffer, sizeof(buffer), &returned,
                       nullptr) || returned != sizeof(buffer)) {
    const DWORD error = GetLastError();
    std::fprintf(stderr,
                 "[WARN] UDP redirect metadata unavailable for %s (Win32 %lu)\n",
                 format_endpoint(client).c_str(),
                 static_cast<unsigned long>(error));
    return false;
  }
  *destination = buffer;
  return destination->ss_family == AF_INET ||
         destination->ss_family == AF_INET6;
}

SOCKET create_udp_listener(int family, unsigned short port) {
  SOCKET listener = WSASocketW(family, SOCK_DGRAM, IPPROTO_UDP, nullptr, 0,
                               WSA_FLAG_OVERLAPPED);
  if (listener == INVALID_SOCKET) return INVALID_SOCKET;
  if (family == AF_INET) {
    SOCKADDR_IN address{};
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    if (bind(listener, reinterpret_cast<const SOCKADDR*>(&address),
             sizeof(address)) == 0)
      return listener;
  } else if (family == AF_INET6) {
    DWORD only_v6 = 1;
    if (setsockopt(listener, IPPROTO_IPV6, IPV6_V6ONLY,
                   reinterpret_cast<const char*>(&only_v6),
                   sizeof(only_v6)) == 0) {
      SOCKADDR_IN6 address{};
      address.sin6_family = AF_INET6;
      address.sin6_port = htons(port);
      address.sin6_addr = in6addr_loopback;
      if (bind(listener, reinterpret_cast<const SOCKADDR*>(&address),
               sizeof(address)) == 0)
        return listener;
    }
  }
  closesocket(listener);
  return INVALID_SOCKET;
}

std::shared_ptr<UdpFlow> find_or_create_udp_flow(
    const SOCKADDR_STORAGE& client, const SOCKADDR_STORAGE& destination,
    DWORD interface_index, SOCKET reply_socket) {
  std::lock_guard<std::mutex> lock(g_udp_flows_mutex);
  for (auto it = g_udp_flows.begin(); it != g_udp_flows.end();) {
    const auto& flow = *it;
    if (!flow->active.load()) {
      it = g_udp_flows.erase(it);
      continue;
    }
    if (same_endpoint(flow->client, client)) {
      if (same_endpoint(flow->destination, destination)) return flow;
      // The same local UDP endpoint cannot be multiplexed to different peers
      // safely through one connected application socket.
      return nullptr;
    }
    ++it;
  }

  SOCKET upstream = WSASocketW(destination.ss_family, SOCK_DGRAM, IPPROTO_UDP,
                               nullptr, 0, WSA_FLAG_OVERLAPPED);
  if (upstream == INVALID_SOCKET ||
      !set_outbound_interface(upstream, destination.ss_family,
                              interface_index)) {
    if (upstream != INVALID_SOCKET) closesocket(upstream);
    std::fprintf(stderr, "%s\n",
                 socket_error("create UDP direct-egress socket").c_str());
    return nullptr;
  }
  DWORD timeout = kUdpFlowTimeoutMs;
  setsockopt(upstream, SOL_SOCKET, SO_RCVTIMEO,
             reinterpret_cast<const char*>(&timeout), sizeof(timeout));

  auto flow = std::make_shared<UdpFlow>();
  flow->upstream = upstream;
  flow->client = client;
  flow->destination = destination;
  g_udp_flows.push_back(flow);
  std::thread([flow, reply_socket] {
    std::array<char, kBufferSize> buffer{};
    for (;;) {
      SOCKADDR_STORAGE remote{};
      int remote_size = sizeof(remote);
      const int received = recvfrom(
          flow->upstream, buffer.data(), static_cast<int>(buffer.size()), 0,
          reinterpret_cast<SOCKADDR*>(&remote), &remote_size);
      if (received == SOCKET_ERROR) {
        const int error = WSAGetLastError();
        if (error != kUdpFlowTimeoutError)
          std::fprintf(stderr, "[WARN] Direct UDP receive ended (Winsock %d)\n",
                       error);
        break;
      }
      if (!same_endpoint(remote, flow->destination)) continue;
      const int sent = sendto(
          reply_socket, buffer.data(), received, 0,
          reinterpret_cast<const SOCKADDR*>(&flow->client),
          flow->client.ss_family == AF_INET ? sizeof(SOCKADDR_IN)
                                            : sizeof(SOCKADDR_IN6));
      if (sent == SOCKET_ERROR)
        std::fprintf(stderr, "%s\n",
                     socket_error("send UDP reply to application").c_str());
    }
    flow->active.store(false);
    std::lock_guard<std::mutex> socket_lock(flow->socket_mutex);
    if (flow->upstream != INVALID_SOCKET) {
      closesocket(flow->upstream);
      flow->upstream = INVALID_SOCKET;
    }
  }).detach();
  std::fprintf(stderr, "[INFO] Direct UDP uplink via ifindex %lu: %s -> %s\n",
               static_cast<unsigned long>(interface_index),
               format_endpoint(client).c_str(),
               format_endpoint(destination).c_str());
  return flow;
}

void udp_receive_loop(SOCKET listener, DWORD interface_index) {
  std::array<char, kBufferSize> buffer{};
  for (;;) {
    SOCKADDR_STORAGE client{};
    int client_size = sizeof(client);
    const int received = recvfrom(
        listener, buffer.data(), static_cast<int>(buffer.size()), 0,
        reinterpret_cast<SOCKADDR*>(&client), &client_size);
    if (received == SOCKET_ERROR) {
      std::fprintf(stderr, "%s\n", socket_error("UDP relay receive").c_str());
      continue;
    }
    SOCKADDR_STORAGE destination{};
    if (!query_udp_destination(client, &destination)) continue;
    auto flow = find_or_create_udp_flow(client, destination, interface_index,
                                        listener);
    if (!flow) {
      std::fprintf(stderr,
                   "[WARN] Dropping ambiguous UDP flow for %s\n",
                   format_endpoint(client).c_str());
      continue;
    }
    std::lock_guard<std::mutex> socket_lock(flow->socket_mutex);
    if (!flow->active.load() || flow->upstream == INVALID_SOCKET) continue;
    const int sent = sendto(
        flow->upstream, buffer.data(), received, 0,
        reinterpret_cast<const SOCKADDR*>(&destination),
        destination.ss_family == AF_INET ? sizeof(SOCKADDR_IN)
                                         : sizeof(SOCKADDR_IN6));
    if (sent == SOCKET_ERROR)
      std::fprintf(stderr, "%s\n", socket_error("direct UDP send").c_str());
  }
}

std::string format_endpoint(const SOCKADDR_STORAGE& endpoint) {
  std::array<char, INET6_ADDRSTRLEN> address{};
  const void* raw_address = nullptr;
  unsigned short port = 0;
  if (endpoint.ss_family == AF_INET) {
    const auto* v4 = reinterpret_cast<const SOCKADDR_IN*>(&endpoint);
    raw_address = &v4->sin_addr;
    port = ntohs(v4->sin_port);
  } else if (endpoint.ss_family == AF_INET6) {
    const auto* v6 = reinterpret_cast<const SOCKADDR_IN6*>(&endpoint);
    raw_address = &v6->sin6_addr;
    port = ntohs(v6->sin6_port);
  } else {
    return "<unknown-family>";
  }
  if (!InetNtopA(endpoint.ss_family, const_cast<void*>(raw_address),
                 address.data(), static_cast<DWORD>(address.size()))) {
    return "<address-format-error>";
  }
  return endpoint.ss_family == AF_INET6
             ? "[" + std::string(address.data()) + "]:" +
                   std::to_string(port)
             : std::string(address.data()) + ":" + std::to_string(port);
}

void relay_direction(SOCKET from, SOCKET to, std::atomic<bool>* failed) {
  std::array<char, kBufferSize> buffer{};
  for (;;) {
    const int received = recv(from, buffer.data(),
                              static_cast<int>(buffer.size()), 0);
    if (received == 0) {
      shutdown(to, SD_SEND);
      return;
    }
    if (received == SOCKET_ERROR) {
      const int error = WSAGetLastError();
      if (error != WSAESHUTDOWN && error != WSAECONNRESET) {
        std::fprintf(stderr, "relay receive failed (Winsock %d)\n", error);
        failed->store(true);
      }
      shutdown(to, SD_SEND);
      return;
    }

    int sent_total = 0;
    while (sent_total < received) {
      const int sent = send(to, buffer.data() + sent_total,
                            received - sent_total, 0);
      if (sent == SOCKET_ERROR || sent == 0) {
        std::fprintf(stderr, "%s\n", socket_error("relay send").c_str());
        failed->store(true);
        shutdown(from, SD_RECEIVE);
        shutdown(to, SD_SEND);
        return;
      }
      sent_total += sent;
    }
  }
}

bool handle_client(SOCKET client, DWORD interface_index) {
  std::vector<unsigned char> context;
  std::vector<unsigned char> records;
  if (!query_blob(client, SIO_QUERY_WFP_CONNECTION_REDIRECT_CONTEXT,
                  &context) ||
      !query_blob(client, SIO_QUERY_WFP_CONNECTION_REDIRECT_RECORDS,
                  &records)) {
    return false;
  }

  SOCKADDR_STORAGE destination{};
  SOCKADDR_STORAGE original_local{};
  if (!parse_redirect_destination(context, &destination, &original_local))
    return false;

  std::fprintf(stderr, "[INFO] Redirected TCP %s -> %s\n",
               format_endpoint(original_local).c_str(),
               format_endpoint(destination).c_str());

  SOCKET outbound = WSASocketW(destination.ss_family, SOCK_STREAM, IPPROTO_TCP,
                               nullptr, 0, WSA_FLAG_OVERLAPPED);
  if (outbound == INVALID_SOCKET) {
    std::fprintf(stderr, "%s\n", socket_error("create outbound socket").c_str());
    return false;
  }

  bool connected = false;
  if (set_outbound_interface(outbound, destination.ss_family,
                             interface_index) &&
      apply_redirect_records(outbound, records) &&
      connect(outbound, reinterpret_cast<const SOCKADDR*>(&destination),
              destination.ss_family == AF_INET ? sizeof(SOCKADDR_IN)
                                               : sizeof(SOCKADDR_IN6)) == 0) {
    connected = true;
  } else {
    std::fprintf(stderr, "%s\n", socket_error("connect original destination").c_str());
  }

  if (connected) {
    std::fprintf(stderr, "[INFO] Direct TCP uplink established to %s via ifindex %lu\n",
                 format_endpoint(destination).c_str(),
                 static_cast<unsigned long>(interface_index));
    std::atomic<bool> failed{false};
    std::thread uplink(relay_direction, client, outbound, &failed);
    relay_direction(outbound, client, &failed);
    shutdown(client, SD_BOTH);
    shutdown(outbound, SD_BOTH);
    uplink.join();
  }

  closesocket(outbound);
  return connected;
}

SOCKET create_listener(int family, unsigned short port) {
  SOCKET listener = WSASocketW(family, SOCK_STREAM, IPPROTO_TCP, nullptr, 0,
                               WSA_FLAG_OVERLAPPED);
  if (listener == INVALID_SOCKET) return INVALID_SOCKET;

  if (family == AF_INET) {
    SOCKADDR_IN address{};
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    if (bind(listener, reinterpret_cast<const SOCKADDR*>(&address),
             sizeof(address)) == 0 &&
        listen(listener, SOMAXCONN) == 0) {
      return listener;
    }
  } else if (family == AF_INET6) {
    DWORD only_v6 = 1;
    if (setsockopt(listener, IPPROTO_IPV6, IPV6_V6ONLY,
                   reinterpret_cast<const char*>(&only_v6),
                   sizeof(only_v6)) == 0) {
      SOCKADDR_IN6 address{};
      address.sin6_family = AF_INET6;
      address.sin6_port = htons(port);
      address.sin6_addr = in6addr_loopback;
      if (bind(listener, reinterpret_cast<const SOCKADDR*>(&address),
               sizeof(address)) == 0 &&
          listen(listener, SOMAXCONN) == 0) {
        return listener;
      }
    }
  }

  closesocket(listener);
  return INVALID_SOCKET;
}

void accept_loop(SOCKET listener, DWORD interface_index) {
  for (;;) {
    SOCKET client = accept(listener, nullptr, nullptr);
    if (client == INVALID_SOCKET) {
      std::fprintf(stderr, "%s\n", socket_error("accept").c_str());
      continue;
    }
    std::thread([client, interface_index] {
      handle_client(client, interface_index);
      shutdown(client, SD_BOTH);
      closesocket(client);
    }).detach();
  }
}

bool parse_args(int argc, wchar_t** argv, unsigned short* listen_port,
                unsigned short* udp_listen_port, DWORD* interface_index) {
  bool has_port = false;
  bool has_udp_port = false;
  bool has_interface = false;
  for (int i = 1; i + 1 < argc; i += 2) {
    if (wcscmp(argv[i], L"--listen-port") == 0) {
      wchar_t* end = nullptr;
      const unsigned long value = wcstoul(argv[i + 1], &end, 10);
      if (!end || *end != L'\0' || value == 0 || value > 65535) return false;
      *listen_port = static_cast<unsigned short>(value);
      has_port = true;
    } else if (wcscmp(argv[i], L"--udp-listen-port") == 0) {
      wchar_t* end = nullptr;
      const unsigned long value = wcstoul(argv[i + 1], &end, 10);
      if (!end || *end != L'\0' || value == 0 || value > 65535) return false;
      *udp_listen_port = static_cast<unsigned short>(value);
      has_udp_port = true;
    } else if (wcscmp(argv[i], L"--interface-index") == 0) {
      wchar_t* end = nullptr;
      const unsigned long value = wcstoul(argv[i + 1], &end, 10);
      if (!end || *end != L'\0' || value == 0 || value > UINT32_MAX)
        return false;
      *interface_index = static_cast<DWORD>(value);
      has_interface = true;
    } else {
      return false;
    }
  }
  return argc == 7 && has_port && has_udp_port && has_interface;
}

}  // namespace

int wmain(int argc, wchar_t** argv) {
  unsigned short listen_port = 0;
  unsigned short udp_listen_port = 0;
  DWORD interface_index = 0;
  if (!parse_args(argc, argv, &listen_port, &udp_listen_port,
                  &interface_index)) {
    std::fwprintf(stderr,
                  L"Usage: harmoney-per-app-relay --listen-port <port> "
                  L"--udp-listen-port <port> "
                  L"--interface-index <index>\n");
    return 2;
  }

  WsaRuntime runtime;
  if (runtime.status != 0) {
    std::fprintf(stderr, "WSAStartup failed (%d)\n", runtime.status);
    return 1;
  }

  g_driver_device = CreateFileW(L"\\\\.\\HarmoneyPerAppWfp", GENERIC_READ,
                                FILE_SHARE_READ | FILE_SHARE_WRITE, nullptr,
                                OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
  if (g_driver_device == INVALID_HANDLE_VALUE) {
    std::fprintf(stderr, "Could not open Harmoney per-app WFP device (Win32 %lu)\n",
                 static_cast<unsigned long>(GetLastError()));
    return 1;
  }

  SOCKET listener_v4 = create_listener(AF_INET, listen_port);
  if (listener_v4 == INVALID_SOCKET) {
    std::fprintf(stderr, "%s\n", socket_error("IPv4 bind/listen").c_str());
    return 1;
  }
  SOCKET listener_v6 = create_listener(AF_INET6, listen_port);
  if (listener_v6 == INVALID_SOCKET) {
    std::fprintf(stderr, "%s\n", socket_error("IPv6 bind/listen").c_str());
    closesocket(listener_v4);
    return 1;
  }

  SOCKET udp_listener_v4 = create_udp_listener(AF_INET, udp_listen_port);
  if (udp_listener_v4 == INVALID_SOCKET) {
    std::fprintf(stderr, "%s\n", socket_error("IPv4 UDP bind").c_str());
    closesocket(listener_v4);
    closesocket(listener_v6);
    return 1;
  }
  SOCKET udp_listener_v6 = create_udp_listener(AF_INET6, udp_listen_port);
  if (udp_listener_v6 == INVALID_SOCKET) {
    std::fprintf(stderr, "%s\n", socket_error("IPv6 UDP bind").c_str());
    closesocket(listener_v4);
    closesocket(listener_v6);
    closesocket(udp_listener_v4);
    return 1;
  }

  std::fwprintf(stdout,
                L"Per-app TCP/UDP relay listening on loopback ports %hu/%hu "
                L"via interface %lu\n",
                listen_port,
                udp_listen_port,
                static_cast<unsigned long>(interface_index));
  std::fflush(stdout);
  std::thread(accept_loop, listener_v4, interface_index).detach();
  std::thread(udp_receive_loop, udp_listener_v4, interface_index).detach();
  std::thread(udp_receive_loop, udp_listener_v6, interface_index).detach();
  accept_loop(listener_v6, interface_index);
}
