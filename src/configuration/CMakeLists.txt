sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME configuration
  PRIVATE_HEADERS error.h
  SOURCES parse.cc read.cc "${CMAKE_CURRENT_BINARY_DIR}/template.h")

# Compile the configuration schema
set(SCHEMA_BASE_PATH "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas")
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/template.json"
  COMMAND "$<TARGET_FILE:jsonschema_cli>" compile --minify
    "${SCHEMA_BASE_PATH}/configuration/configuration.json"
    > "${CMAKE_CURRENT_BINARY_DIR}/template.json"
  DEPENDS
    "$<TARGET_FILE:jsonschema_cli>"
    "${SCHEMA_BASE_PATH}/configuration/configuration.json"
    "${SCHEMA_BASE_PATH}/configuration/collection.json"
    "${SCHEMA_BASE_PATH}/configuration/contents.json"
    "${SCHEMA_BASE_PATH}/configuration/extends.json"
    "${SCHEMA_BASE_PATH}/configuration/page.json"
    "${SCHEMA_BASE_PATH}/common/email-address.json"
    "${SCHEMA_BASE_PATH}/common/path-posix.json"
    "${SCHEMA_BASE_PATH}/common/path-posix-absolute.json"
    "${SCHEMA_BASE_PATH}/common/path-posix-relative.json"
    "${SCHEMA_BASE_PATH}/common/uri-reference.json"
    "${SCHEMA_BASE_PATH}/common/uri-relative.json"
    "${SCHEMA_BASE_PATH}/common/uri.json"
    "${SCHEMA_BASE_PATH}/common/url.json"
    "${SCHEMA_BASE_PATH}/common/urn.json")

find_program(XXD_BIN NAMES xxd REQUIRED)
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/template.h"
  COMMAND "${XXD_BIN}" --include --name SOURCEMETA_CONFIGURATION_SCHEMA_TEMPLATE
    "${CMAKE_CURRENT_BINARY_DIR}/template.json"
    "${CMAKE_CURRENT_BINARY_DIR}/template.h"
  DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/template.json")

target_include_directories(sourcemeta_registry_configuration PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

target_link_libraries(sourcemeta_registry_configuration PUBLIC sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_configuration PUBLIC sourcemeta::core::jsonpointer)
target_link_libraries(sourcemeta_registry_configuration PUBLIC sourcemeta::core::schemaconfig)
target_link_libraries(sourcemeta_registry_configuration PRIVATE sourcemeta::core::uri)
target_link_libraries(sourcemeta_registry_configuration PUBLIC sourcemeta::blaze::output)
target_link_libraries(sourcemeta_registry_configuration PRIVATE sourcemeta::blaze::evaluator)
