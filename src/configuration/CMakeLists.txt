sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME configuration
  PRIVATE_HEADERS error.h SOURCES parse.cc)

target_link_libraries(sourcemeta_registry_configuration PUBLIC sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_configuration PUBLIC sourcemeta::core::jsonpointer)
target_link_libraries(sourcemeta_registry_configuration PRIVATE sourcemeta::core::uri)
