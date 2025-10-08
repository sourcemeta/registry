sourcemeta_executable(NAMESPACE sourcemeta PROJECT registry NAME server
  FOLDER "Registry/Server"
  SOURCES search.h status.h evaluate.h server.cc uwebsockets.h)

set_target_properties(sourcemeta_registry_server PROPERTIES OUTPUT_NAME sourcemeta-registry-server)

target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::core::jsonpointer)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::core::uuid)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::core::time)
target_link_libraries(sourcemeta_registry_server PRIVATE uNetworking::uSockets)
target_link_libraries(sourcemeta_registry_server PRIVATE uNetworking::uWebSockets)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::registry::gzip)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::registry::shared)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::blaze::evaluator)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::blaze::output)

target_compile_definitions(sourcemeta_registry_server
  PRIVATE SOURCEMETA_REGISTRY_STATIC="${REGISTRY_PREFIX}/share/sourcemeta/registry/static")

install(TARGETS sourcemeta_registry_server
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  COMPONENT sourcemeta_registry)
