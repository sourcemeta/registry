sourcemeta_googletest(NAMESPACE sourcemeta PROJECT registry NAME configuration
  SOURCES configuration_read_test.cc configuration_test.cc)

target_link_libraries(sourcemeta_registry_configuration_unit
  PRIVATE sourcemeta::registry::configuration)
target_compile_definitions(sourcemeta_registry_configuration_unit
  PRIVATE STUB_DIRECTORY="${CMAKE_CURRENT_SOURCE_DIR}/stub")
target_compile_definitions(sourcemeta_registry_configuration_unit
  PRIVATE COLLECTIONS_DIRECTORY="${CMAKE_CURRENT_SOURCE_DIR}/stub/collections")
