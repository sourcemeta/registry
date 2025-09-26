sourcemeta_executable(NAMESPACE sourcemeta PROJECT registry NAME index
  FOLDER "Registry/Index"
  SOURCES index.cc output.h generators.h explorer.h)

set_target_properties(sourcemeta_registry_index PROPERTIES OUTPUT_NAME sourcemeta-registry-index)

target_compile_definitions(sourcemeta_registry_index
  PRIVATE SOURCEMETA_REGISTRY_COLLECTIONS="${REGISTRY_PREFIX}/share/sourcemeta/registry/collections")

target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::registry::resolver)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::registry::shared)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::registry::configuration)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::registry::web)

target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::build)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::uri)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::jsonschema)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::alterschema)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::editorschema)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::parallel)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::options)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::blaze::compiler)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::blaze::evaluator)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::blaze::output)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::blaze::linter)

install(TARGETS sourcemeta_registry_index
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  COMPONENT sourcemeta_registry)
