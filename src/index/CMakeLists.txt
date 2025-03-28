# TODO: Use new executable macro
add_executable(schema_registry_index index.cc html.h configure.h.in 
  "${PROJECT_SOURCE_DIR}/schemas/configuration.json")

sourcemeta_add_default_options(PRIVATE schema_registry_index)
set_target_properties(schema_registry_index PROPERTIES OUTPUT_NAME sourcemeta-registry-index)
target_link_libraries(schema_registry_index PRIVATE sourcemeta::core::uri)
target_link_libraries(schema_registry_index PRIVATE sourcemeta::core::json)
target_link_libraries(schema_registry_index PRIVATE sourcemeta::core::jsonschema)
target_link_libraries(schema_registry_index PRIVATE sourcemeta::core::yaml)
target_link_libraries(schema_registry_index PRIVATE sourcemeta::blaze::compiler)
target_link_libraries(schema_registry_index PRIVATE sourcemeta::blaze::evaluator)
target_link_libraries(schema_registry_index PRIVATE sourcemeta::registry::html)

if(REGISTRY_EDITION STREQUAL "enterprise")
  target_compile_definitions(schema_registry_index 
    PRIVATE SOURCEMETA_REGISTRY_ENTERPRISE)
elseif(REGISTRY_EDITION STREQUAL "pro")
  target_compile_definitions(schema_registry_index 
    PRIVATE SOURCEMETA_REGISTRY_PRO)
else()
  target_compile_definitions(schema_registry_index 
    PRIVATE SOURCEMETA_REGISTRY_STARTER)
endif()

file(READ "${PROJECT_SOURCE_DIR}/schemas/configuration.json" SCHEMA_CONFIGURATION)
configure_file(configure.h.in configure.h @ONLY)
target_include_directories(schema_registry_index PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

include(GNUInstallDirs)
install(TARGETS schema_registry_index
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  COMPONENT sourcemeta_registry)
