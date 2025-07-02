sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME generator
  PRIVATE_HEADERS collection.h configuration.h output.h resolver.h validator.h
  SOURCES collection.cc configuration.cc output.cc resolver.cc validator.cc)

target_link_libraries(sourcemeta_registry_generator PUBLIC
  sourcemeta::core::uri)
target_link_libraries(sourcemeta_registry_generator PUBLIC
  sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_generator PUBLIC
  sourcemeta::core::jsonschema)
target_link_libraries(sourcemeta_registry_generator PRIVATE
  sourcemeta::core::yaml)
target_link_libraries(sourcemeta_registry_generator PRIVATE
  sourcemeta::core::md5)

target_link_libraries(sourcemeta_registry_generator PUBLIC
  sourcemeta::blaze::compiler)
target_link_libraries(sourcemeta_registry_generator PUBLIC
  sourcemeta::blaze::evaluator)
