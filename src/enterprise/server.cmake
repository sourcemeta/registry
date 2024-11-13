target_compile_definitions(schema_registry_server PRIVATE SOURCEMETA_REGISTRY_ENTERPRISE)
cmake_path(GET CMAKE_CURRENT_LIST_FILE PARENT_PATH ENTERPRISE_SOURCE_DIR)
target_sources(schema_registry_server PRIVATE 
  "${ENTERPRISE_SOURCE_DIR}/enterprise_server.h"
  "${ENTERPRISE_SOURCE_DIR}/enterprise_explorer.h")
target_include_directories(schema_registry_server PRIVATE "${ENTERPRISE_SOURCE_DIR}")
