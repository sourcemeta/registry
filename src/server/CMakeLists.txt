sourcemeta_executable(NAMESPACE sourcemeta PROJECT registry NAME server 
  FOLDER "Registry/Server" 
  SOURCES server.cc configure.h.in 
  "${CMAKE_CURRENT_BINARY_DIR}/style.min.css")

set_target_properties(sourcemeta_registry_server PROPERTIES OUTPUT_NAME sourcemeta-registry-server)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::core::uri)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::core::jsonschema)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::core::md5)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::hydra::http)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::hydra::httpserver)
target_link_libraries(sourcemeta_registry_server PRIVATE sourcemeta::registry::license)

if(REGISTRY_EDITION STREQUAL "enterprise")
  target_compile_definitions(sourcemeta_registry_server 
    PRIVATE SOURCEMETA_REGISTRY_ENTERPRISE)
elseif(REGISTRY_EDITION STREQUAL "pro")
  target_compile_definitions(sourcemeta_registry_server 
    PRIVATE SOURCEMETA_REGISTRY_PRO)
else()
  target_compile_definitions(sourcemeta_registry_server 
    PRIVATE SOURCEMETA_REGISTRY_STARTER)
endif()

target_compile_definitions(sourcemeta_registry_server 
  PRIVATE SOURCEMETA_REGISTRY_STATIC="${REGISTRY_PREFIX}/share/sourcemeta/registry")

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

configure_file(configure.h.in configure.h @ONLY)
target_include_directories(sourcemeta_registry_server PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

include(GNUInstallDirs)
install(TARGETS sourcemeta_registry_server
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  COMPONENT sourcemeta_registry)
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
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry"
  COMPONENT sourcemeta_registry)
