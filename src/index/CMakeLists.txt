add_executable(schema_registry_index index.cc configure.h.in 
  "${PROJECT_SOURCE_DIR}/schemas/configuration.json")

sourcemeta_add_default_options(PRIVATE schema_registry_index)
set_target_properties(schema_registry_index PROPERTIES OUTPUT_NAME sourcemeta-registry-index)
target_link_libraries(schema_registry_index PRIVATE sourcemeta::core::uri)
target_link_libraries(schema_registry_index PRIVATE sourcemeta::core::json)
target_link_libraries(schema_registry_index PRIVATE sourcemeta::core::jsonschema)
target_link_libraries(schema_registry_index PRIVATE sourcemeta::core::yaml)
target_link_libraries(schema_registry_index PRIVATE sourcemeta::blaze::compiler)
target_link_libraries(schema_registry_index PRIVATE sourcemeta::blaze::evaluator)

if(REGISTRY_ENTERPRISE)
  include(../enterprise/index.cmake)
endif()

file(READ "${PROJECT_SOURCE_DIR}/schemas/configuration.json" SCHEMA_CONFIGURATION)
configure_file(configure.h.in configure.h @ONLY)
target_include_directories(schema_registry_index PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

include(GNUInstallDirs)
install(TARGETS schema_registry_index
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  COMPONENT sourcemeta_registry)
