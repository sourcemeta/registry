sourcemeta_executable(NAMESPACE sourcemeta PROJECT registry NAME index 
  FOLDER "Registry/Index" 
  SOURCES index.cc explorer.h toc.h configure.h.in 
    "${PROJECT_SOURCE_DIR}/schemas/configuration.json")

set_target_properties(sourcemeta_registry_index PROPERTIES OUTPUT_NAME sourcemeta-registry-index)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::registry::generator)

# TODO: Revise these dependencies
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::uri)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::jsonschema)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::yaml)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::blaze::compiler)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::blaze::evaluator)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::registry::html)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::registry::license)

if(REGISTRY_EDITION STREQUAL "enterprise")
  target_compile_definitions(sourcemeta_registry_index 
    PRIVATE SOURCEMETA_REGISTRY_ENTERPRISE)
elseif(REGISTRY_EDITION STREQUAL "pro")
  target_compile_definitions(sourcemeta_registry_index 
    PRIVATE SOURCEMETA_REGISTRY_PRO)
else()
  target_compile_definitions(sourcemeta_registry_index 
    PRIVATE SOURCEMETA_REGISTRY_STARTER)
endif()

file(READ "${PROJECT_SOURCE_DIR}/schemas/configuration.json" SCHEMA_CONFIGURATION)
configure_file(configure.h.in configure.h @ONLY)
target_include_directories(sourcemeta_registry_index PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

include(GNUInstallDirs)
install(TARGETS sourcemeta_registry_index
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  COMPONENT sourcemeta_registry)
