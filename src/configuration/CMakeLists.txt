sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME configuration
  PRIVATE_HEADERS error.h SOURCES parse.cc read.cc)

# Bundle the configuration schema
set(SCHEMA_BASE_PATH "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas/configuration")
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/schema.json"
  COMMAND "$<TARGET_FILE:jsonschema_cli>" bundle "${SCHEMA_BASE_PATH}/configuration.json"
    > "${CMAKE_CURRENT_BINARY_DIR}/schema.json"
  DEPENDS
    "$<TARGET_FILE:jsonschema_cli>"
    "${SCHEMA_BASE_PATH}/configuration.json"
    "${SCHEMA_BASE_PATH}/collection.json"
    "${SCHEMA_BASE_PATH}/email-address.json"
    "${SCHEMA_BASE_PATH}/entry.json"
    "${SCHEMA_BASE_PATH}/include.json"
    "${SCHEMA_BASE_PATH}/page.json"
    "${SCHEMA_BASE_PATH}/path-posix.json"
    "${SCHEMA_BASE_PATH}/path-posix-absolute.json"
    "${SCHEMA_BASE_PATH}/path-posix-relative.json"
    "${SCHEMA_BASE_PATH}/uri-reference.json"
    "${SCHEMA_BASE_PATH}/uri-relative.json"
    "${SCHEMA_BASE_PATH}/uri.json"
    "${SCHEMA_BASE_PATH}/url.json"
    "${SCHEMA_BASE_PATH}/urn.json")
add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/schema.h"
  COMMAND "${CMAKE_COMMAND}"
    -DINPUT="${CMAKE_CURRENT_BINARY_DIR}/schema.json"
    -DOUTPUT="${CMAKE_CURRENT_BINARY_DIR}/schema.h"
    -P "${CMAKE_CURRENT_SOURCE_DIR}/schema.cmake"
  DEPENDS
    "${CMAKE_CURRENT_BINARY_DIR}/schema.json"
    "${CMAKE_CURRENT_SOURCE_DIR}/schema.cmake")
target_sources(sourcemeta_registry_configuration PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/schema.h")
target_include_directories(sourcemeta_registry_configuration PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

target_link_libraries(sourcemeta_registry_configuration PUBLIC sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_configuration PUBLIC sourcemeta::core::jsonpointer)
target_link_libraries(sourcemeta_registry_configuration PUBLIC sourcemeta::core::schemaconfig)
target_link_libraries(sourcemeta_registry_configuration PRIVATE sourcemeta::core::uri)
target_link_libraries(sourcemeta_registry_configuration PUBLIC sourcemeta::blaze::output)
target_link_libraries(sourcemeta_registry_configuration PUBLIC sourcemeta::blaze::compiler)
target_link_libraries(sourcemeta_registry_configuration PRIVATE sourcemeta::blaze::evaluator)
