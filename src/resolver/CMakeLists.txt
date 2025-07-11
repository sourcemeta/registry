sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME resolver
  PRIVATE_HEADERS collection.h error.h
  SOURCES resolver.cc collection.cc)

target_link_libraries(sourcemeta_registry_resolver PUBLIC
  sourcemeta::core::uri)
target_link_libraries(sourcemeta_registry_resolver PUBLIC
  sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_resolver PUBLIC
  sourcemeta::core::jsonschema)

target_link_libraries(sourcemeta_registry_resolver PRIVATE
  sourcemeta::core::yaml)
