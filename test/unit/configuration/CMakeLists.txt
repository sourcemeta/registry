sourcemeta_googletest(NAMESPACE sourcemeta PROJECT registry NAME configuration
  SOURCES configuration_test.cc)

target_link_libraries(sourcemeta_registry_configuration_unit
  PRIVATE sourcemeta::registry::configuration)
target_compile_definitions(sourcemeta_registry_configuration_unit
  PRIVATE TEST_DIRECTORY="${CMAKE_CURRENT_SOURCE_DIR}")
target_compile_definitions(sourcemeta_registry_configuration_unit
  PRIVATE COLLECTIONS_DIRECTORY="${CMAKE_CURRENT_SOURCE_DIR}/collections")
