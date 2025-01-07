add_executable(schema_registry_server server.cc configure.h.in)

noa_add_default_options(PRIVATE schema_registry_server)
set_target_properties(schema_registry_server PROPERTIES OUTPUT_NAME sourcemeta-registry-server)
target_link_libraries(schema_registry_server PRIVATE sourcemeta::jsontoolkit::uri)
target_link_libraries(schema_registry_server PRIVATE sourcemeta::jsontoolkit::json)
target_link_libraries(schema_registry_server PRIVATE sourcemeta::jsontoolkit::jsonschema)
target_link_libraries(schema_registry_server PRIVATE sourcemeta::hydra::http)
target_link_libraries(schema_registry_server PRIVATE sourcemeta::hydra::httpserver)
target_link_libraries(schema_registry_server PRIVATE sourcemeta::hydra::crypto)

if(REGISTRY_ENTERPRISE)
  target_compile_definitions(schema_registry_server 
    PRIVATE SOURCEMETA_REGISTRY_ENTERPRISE)
  target_sources(schema_registry_server 
    PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/style.min.css")
  target_compile_definitions(schema_registry_server 
    PRIVATE SOURCEMETA_REGISTRY_ENTERPRISE_STATIC="${REGISTRY_PREFIX}/share/sourcemeta/registry")
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
  include(GNUInstallDirs)
  install(FILES
    # Icons
    "${CMAKE_CURRENT_SOURCE_DIR}/assets/favicon.ico"
    "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon_192x192.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon_512x512.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.svg"
    "${CMAKE_CURRENT_SOURCE_DIR}/assets/apple-touch-icon.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/assets/manifest.webmanifest"

    # Styles
    "${CMAKE_CURRENT_BINARY_DIR}/style.min.css"
    "${PROJECT_SOURCE_DIR}/vendor/bootstrap-icons/font/fonts/bootstrap-icons.woff"
    "${PROJECT_SOURCE_DIR}/vendor/bootstrap-icons/font/fonts/bootstrap-icons.woff2"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry"
    COMPONENT sourcemeta_registry)
endif()

configure_file(configure.h.in configure.h @ONLY)
target_include_directories(schema_registry_server PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

include(GNUInstallDirs)
install(TARGETS schema_registry_server
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  COMPONENT sourcemeta_registry)
