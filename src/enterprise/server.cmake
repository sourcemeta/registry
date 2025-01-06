target_compile_definitions(schema_registry_server PRIVATE SOURCEMETA_REGISTRY_ENTERPRISE)

cmake_path(GET CMAKE_CURRENT_LIST_FILE PARENT_PATH ENTERPRISE_SOURCE_DIR)
target_sources(schema_registry_server PRIVATE 
  "${ENTERPRISE_SOURCE_DIR}/enterprise_server.h"
  "${CMAKE_CURRENT_BINARY_DIR}/style.min.css")
target_include_directories(schema_registry_server PRIVATE "${ENTERPRISE_SOURCE_DIR}")

# Static assets
target_compile_definitions(schema_registry_server 
  PRIVATE SOURCEMETA_REGISTRY_ENTERPRISE_STATIC="${REGISTRY_PREFIX}/share/sourcemeta/registry")
include(BootstrapFiles)
find_program(SASSC_BIN NAMES sassc REQUIRED)
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/style.min.css"
  COMMAND "${SASSC_BIN}" --style compressed
    "${ENTERPRISE_SOURCE_DIR}/style.scss"
    "${CMAKE_CURRENT_BINARY_DIR}/style.min.css"
  DEPENDS
    "${ENTERPRISE_SOURCE_DIR}/style.scss"
    "${PROJECT_SOURCE_DIR}/vendor/bootstrap-icons/font/bootstrap-icons.scss"
    ${BOOTSTRAP_SCSS_FILES})
include(GNUInstallDirs)
install(FILES
  # Icons
  "${ENTERPRISE_SOURCE_DIR}/assets/favicon.ico"
  "${ENTERPRISE_SOURCE_DIR}/assets/icon_192x192.png"
  "${ENTERPRISE_SOURCE_DIR}/assets/icon_512x512.png"
  "${ENTERPRISE_SOURCE_DIR}/assets/icon.svg"
  "${ENTERPRISE_SOURCE_DIR}/assets/apple-touch-icon.png"
  "${ENTERPRISE_SOURCE_DIR}/assets/manifest.webmanifest"

  # Styles
  "${CMAKE_CURRENT_BINARY_DIR}/style.min.css"
  "${PROJECT_SOURCE_DIR}/vendor/bootstrap-icons/font/fonts/bootstrap-icons.woff"
  "${PROJECT_SOURCE_DIR}/vendor/bootstrap-icons/font/fonts/bootstrap-icons.woff2"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry"
  COMPONENT sourcemeta_registry)
