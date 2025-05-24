sourcemeta_googletest(NAMESPACE sourcemeta PROJECT registry NAME generator
  SOURCES generator_resolver_test.cc)

target_link_libraries(sourcemeta_registry_generator_unit
  PRIVATE sourcemeta::registry::generator)
target_compile_definitions(sourcemeta_registry_generator_unit
  PRIVATE SCHEMAS_PATH="${CMAKE_CURRENT_SOURCE_DIR}/schemas")
target_compile_definitions(sourcemeta_registry_generator_unit
  PRIVATE CONFIGURATION_PATH="${CMAKE_CURRENT_SOURCE_DIR}/configuration.json")
target_compile_definitions(sourcemeta_registry_generator_unit
  PRIVATE CONFIGURATION_SCHEMA_PATH="${PROJECT_SOURCE_DIR}/schemas/configuration.json")
