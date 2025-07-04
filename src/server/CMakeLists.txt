sourcemeta_executable(NAMESPACE sourcemeta PROJECT registry NAME server 
  FOLDER "Registry/Server" 
  SOURCES reader.h logger.h search.h
    server.cc uwebsockets.h configure.h.in)

set_target_properties(sourcemeta_registry_server PROPERTIES OUTPUT_NAME sourcemeta-registry-server)

target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::core::uuid)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::core::gzip)
target_link_libraries(sourcemeta_registry_server PRIVATE uNetworking::uSockets)
target_link_libraries(sourcemeta_registry_server PRIVATE uNetworking::uWebSockets)

# TODO: Get rid of this library
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::hydra::http)

target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::registry::license)

if(REGISTRY_EDITION STREQUAL "enterprise")
  target_compile_definitions(sourcemeta_registry_server 
    PRIVATE SOURCEMETA_REGISTRY_ENTERPRISE)
elseif(REGISTRY_EDITION STREQUAL "pro")
  target_compile_definitions(sourcemeta_registry_server 
    PRIVATE SOURCEMETA_REGISTRY_PRO)
else()
  target_compile_definitions(sourcemeta_registry_server 
    PRIVATE SOURCEMETA_REGISTRY_STARTER)
endif()

target_compile_definitions(sourcemeta_registry_server 
  PRIVATE SOURCEMETA_REGISTRY_STATIC="${REGISTRY_PREFIX}/share/sourcemeta/registry/static")

configure_file(configure.h.in configure.h @ONLY)
target_include_directories(sourcemeta_registry_server PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

include(GNUInstallDirs)
install(TARGETS sourcemeta_registry_server
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  COMPONENT sourcemeta_registry)
