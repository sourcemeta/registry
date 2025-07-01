if(NOT uSockets_FOUND)
  set(USOCKETS_DIR "${PROJECT_SOURCE_DIR}/vendor/uwebsockets/uSockets")
  set(USOCKETS_PUBLIC_HEADER "${USOCKETS_DIR}/src/libusockets.h")

  add_library(usockets
    "${USOCKETS_PUBLIC_HEADER}"
    "${USOCKETS_DIR}/src/internal/networking/bsd.h"
    "${USOCKETS_DIR}/src/bsd.c"
    "${USOCKETS_DIR}/src/context.c"
    "${USOCKETS_DIR}/src/loop.c"
    "${USOCKETS_DIR}/src/socket.c"
    "${USOCKETS_DIR}/src/udp.c"
    "${USOCKETS_DIR}/src/crypto/openssl.c"
    "${USOCKETS_DIR}/src/crypto/sni_tree.cpp"
    "${USOCKETS_DIR}/src/quic.c"
    "${USOCKETS_DIR}/src/quic.h"
    "${USOCKETS_DIR}/src/internal/eventing/epoll_kqueue.h"
    "${USOCKETS_DIR}/src/eventing/epoll_kqueue.c"
    "${USOCKETS_DIR}/src/io_uring/internal.h"
    "${USOCKETS_DIR}/src/io_uring/io_context.c"
    "${USOCKETS_DIR}/src/io_uring/io_loop.c"
    "${USOCKETS_DIR}/src/io_uring/io_socket.c"
    "${USOCKETS_DIR}/src/internal/eventing/gcd.h"
    "${USOCKETS_DIR}/src/eventing/gcd.c"
    "${USOCKETS_DIR}/src/internal/eventing/libuv.h"
    "${USOCKETS_DIR}/src/eventing/libuv.c"
    "${USOCKETS_DIR}/src/internal/eventing/asio.h")

  target_compile_definitions(usockets PUBLIC LIBUS_NO_SSL)

  # Configure the event loop
  if(APPLE)
    target_compile_definitions(usockets PUBLIC LIBUS_USE_KQUEUE)
  else()
    target_compile_definitions(usockets PUBLIC LIBUS_USE_EPOLL)
  endif()

  target_include_directories(usockets PUBLIC
    "$<BUILD_INTERFACE:${USOCKETS_DIR}/src>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>")

  add_library(uNetworking::uSockets ALIAS usockets)

  set_target_properties(usockets
    PROPERTIES
      OUTPUT_NAME usockets
      PUBLIC_HEADER "${USOCKETS_PUBLIC_HEADER}"
      C_VISIBILITY_PRESET "default"
      C_VISIBILITY_INLINES_HIDDEN FALSE
      WINDOWS_EXPORT_ALL_SYMBOLS TRUE
      EXPORT_NAME usockets)

  set(uSockets_FOUND ON)
endif()
