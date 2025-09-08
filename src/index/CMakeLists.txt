sourcemeta_executable(NAMESPACE sourcemeta PROJECT registry NAME index
  FOLDER "Registry/Index"
  SOURCES index.cc output.h generators.h configure.h.in validator.h explorer.h)

set_target_properties(sourcemeta_registry_index PROPERTIES OUTPUT_NAME sourcemeta-registry-index)

target_compile_definitions(sourcemeta_registry_index
  PRIVATE SOURCEMETA_REGISTRY_COLLECTIONS="${REGISTRY_PREFIX}/share/sourcemeta/registry/collections")

target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::registry::resolver)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::registry::shared)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::registry::configuration)

target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::build)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::uri)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::jsonschema)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::yaml)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::md5)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::gzip)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::time)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::alterschema)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::editorschema)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::parallel)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::options)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::blaze::compiler)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::blaze::evaluator)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::blaze::output)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::blaze::linter)

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

configure_file(configure.h.in configure.h @ONLY)
target_include_directories(sourcemeta_registry_index PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

include(GNUInstallDirs)
install(TARGETS sourcemeta_registry_index
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  COMPONENT sourcemeta_registry)
