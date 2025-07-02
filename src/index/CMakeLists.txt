sourcemeta_executable(NAMESPACE sourcemeta PROJECT registry NAME index 
  FOLDER "Registry/Index" 
  SOURCES index.cc explorer.h toc.h configure.h.in 
    "${PROJECT_SOURCE_DIR}/schemas/configuration.json"
    "${CMAKE_CURRENT_BINARY_DIR}/style.min.css")

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

# TODO: Get rid of Hydra here
target_link_libraries(sourcemeta_registry_index PRIVATE
  sourcemeta::hydra::http)

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

# TODO: Pre-calculate .meta files with checksums, last modified, and mime types
include(BootstrapFiles)
find_program(SASSC_BIN NAMES sassc REQUIRED)
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/style.min.css"
  COMMAND "${SASSC_BIN}" --style compressed
    "${CMAKE_CURRENT_SOURCE_DIR}/style.scss"
    "${CMAKE_CURRENT_BINARY_DIR}/style.min.css"
  DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/style.scss"
    "${PROJECT_SOURCE_DIR}/vendor/bootstrap-icons/font/bootstrap-icons.scss"
    ${BOOTSTRAP_SCSS_FILES})
install(FILES
  # Icons
  "${CMAKE_CURRENT_SOURCE_DIR}/assets/favicon.ico"
  "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon_192x192.png"
  "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon_512x512.png"
  "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.svg"
  "${CMAKE_CURRENT_SOURCE_DIR}/assets/apple-touch-icon.png"
  "${CMAKE_CURRENT_SOURCE_DIR}/assets/manifest.webmanifest"
  "${CMAKE_CURRENT_SOURCE_DIR}/assets/main.js"

  # Styles
  "${CMAKE_CURRENT_BINARY_DIR}/style.min.css"
  "${PROJECT_SOURCE_DIR}/vendor/bootstrap-icons/font/fonts/bootstrap-icons.woff"
  "${PROJECT_SOURCE_DIR}/vendor/bootstrap-icons/font/fonts/bootstrap-icons.woff2"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/static/data"
  COMPONENT sourcemeta_registry)
