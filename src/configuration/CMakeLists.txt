sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME configuration
  PRIVATE_HEADERS error.h SOURCES parse.cc read.cc schema.json schema.h.in)

file(READ schema.json CONFIGURATION_SCHEMA)
configure_file(schema.h.in schema.h @ONLY)
target_include_directories(sourcemeta_registry_configuration PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

target_link_libraries(sourcemeta_registry_configuration PUBLIC sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_configuration PUBLIC sourcemeta::core::jsonpointer)
target_link_libraries(sourcemeta_registry_configuration PRIVATE sourcemeta::core::uri)
target_link_libraries(sourcemeta_registry_configuration PUBLIC sourcemeta::blaze::compiler)
target_link_libraries(sourcemeta_registry_configuration PRIVATE sourcemeta::blaze::evaluator)
