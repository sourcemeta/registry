add_executable(schema_registry_server server.cc configure.h.in)

noa_add_default_options(PRIVATE schema_registry_server)
set_target_properties(schema_registry_server PROPERTIES OUTPUT_NAME sourcemeta-registry-server)
target_link_libraries(schema_registry_server PRIVATE sourcemeta::jsontoolkit::uri)
target_link_libraries(schema_registry_server PRIVATE sourcemeta::jsontoolkit::json)
target_link_libraries(schema_registry_server PRIVATE sourcemeta::jsontoolkit::jsonschema)
target_link_libraries(schema_registry_server PRIVATE sourcemeta::hydra::http)
target_link_libraries(schema_registry_server PRIVATE sourcemeta::hydra::httpserver)
target_link_libraries(schema_registry_server PRIVATE sourcemeta::hydra::crypto)

if(REGISTRY_ENTERPRISE)
  target_compile_definitions(schema_registry_server 
    PRIVATE SOURCEMETA_REGISTRY_ENTERPRISE)
endif()

configure_file(configure.h.in configure.h @ONLY)
target_include_directories(schema_registry_server PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

include(GNUInstallDirs)
install(TARGETS schema_registry_server
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  COMPONENT sourcemeta_registry)
