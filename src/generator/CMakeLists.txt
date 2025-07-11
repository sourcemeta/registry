sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME generator
  PRIVATE_HEADERS configuration.h output.h validator.h
  SOURCES configuration.cc output.cc validator.cc)

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
