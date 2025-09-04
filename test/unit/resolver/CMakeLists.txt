sourcemeta_googletest(NAMESPACE sourcemeta PROJECT registry NAME resolver
  SOURCES resolver_test.cc resolver_relativize_test.cc)

target_link_libraries(sourcemeta_registry_resolver_unit
  PRIVATE sourcemeta::registry::configuration)
target_link_libraries(sourcemeta_registry_resolver_unit
  PRIVATE sourcemeta::registry::resolver)
target_compile_definitions(sourcemeta_registry_resolver_unit
  PRIVATE SCHEMAS_PATH="${CMAKE_CURRENT_SOURCE_DIR}/schemas")
target_compile_definitions(sourcemeta_registry_resolver_unit
  PRIVATE CONFIGURATION_PATH="${CMAKE_CURRENT_SOURCE_DIR}/registry.json")
