sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME configuration
  PRIVATE_HEADERS error.h
  SOURCES parse.cc read.cc "${CMAKE_CURRENT_BINARY_DIR}/template.h")

# Compile the configuration schema
set(REGISTRY_SCHEMAS "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas")
set(STD_SCHEMAS "${PROJECT_SOURCE_DIR}/vendor/collections/sourcemeta/std/v0.0.1/schemas")
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/template.json"
  COMMAND "$<TARGET_FILE:jsonschema_cli>" compile --minify
    "${REGISTRY_SCHEMAS}/configuration/configuration.json"
    > "${CMAKE_CURRENT_BINARY_DIR}/template.json"
  DEPENDS
    "$<TARGET_FILE:jsonschema_cli>"
    "${REGISTRY_SCHEMAS}/configuration/configuration.json"
    "${REGISTRY_SCHEMAS}/configuration/collection.json"
    "${REGISTRY_SCHEMAS}/configuration/contents.json"
    "${REGISTRY_SCHEMAS}/configuration/extends.json"
    "${REGISTRY_SCHEMAS}/configuration/page.json"
    "${REGISTRY_SCHEMAS}/configuration/rpath.json"
    "${STD_SCHEMAS}/ietf/email/address.json"
    "${STD_SCHEMAS}/ieee/posix/path.json"
    "${STD_SCHEMAS}/ieee/posix/path-absolute.json"
    "${STD_SCHEMAS}/ieee/posix/path-relative.json"
    "${STD_SCHEMAS}/ietf/uri/uri-reference.json"
    "${STD_SCHEMAS}/ietf/uri/uri-relative.json"
    "${STD_SCHEMAS}/ietf/uri/uri.json"
    "${STD_SCHEMAS}/ietf/uri/url.json"
    "${STD_SCHEMAS}/ietf/uri/urn.json")

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
