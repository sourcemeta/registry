target_compile_definitions(schema_registry_index PRIVATE SOURCEMETA_REGISTRY_ENTERPRISE)

cmake_path(GET CMAKE_CURRENT_LIST_FILE PARENT_PATH ENTERPRISE_SOURCE_DIR)
target_sources(schema_registry_index PRIVATE 
  "${ENTERPRISE_SOURCE_DIR}/enterprise_index.h"
  "${ENTERPRISE_SOURCE_DIR}/enterprise_html.h")
target_include_directories(schema_registry_index PRIVATE "${ENTERPRISE_SOURCE_DIR}")

target_link_libraries(schema_registry_index PRIVATE sourcemeta::registry::html)
