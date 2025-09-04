sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME resolver
  PRIVATE_HEADERS error.h SOURCES resolver.cc visitor.h visitor.cc)

target_link_libraries(sourcemeta_registry_resolver PUBLIC
  sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_resolver PUBLIC
  sourcemeta::registry::configuration)

target_link_libraries(sourcemeta_registry_resolver PRIVATE
  sourcemeta::core::uri)
target_link_libraries(sourcemeta_registry_resolver PRIVATE
  sourcemeta::core::jsonschema)
target_link_libraries(sourcemeta_registry_resolver PRIVATE
  sourcemeta::core::yaml)
target_link_libraries(sourcemeta_registry_resolver PRIVATE
  sourcemeta::registry::shared)
