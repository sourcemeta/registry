sourcemeta_esbuild_bundle(
  ENTRYPOINT "${CMAKE_CURRENT_SOURCE_DIR}/main.js"
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/main.min.js"
  DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/main.js"
    "${CMAKE_CURRENT_SOURCE_DIR}/search.js"
    "${CMAKE_CURRENT_SOURCE_DIR}/tabs.js"
    "${CMAKE_CURRENT_SOURCE_DIR}/editor.js")

# Generate CSS
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

# Generate static files
set(REGISTRY_STATIC
  "${CMAKE_CURRENT_BINARY_DIR}/style.min.css"
  "${CMAKE_CURRENT_BINARY_DIR}/main.min.js"
  "${CMAKE_CURRENT_SOURCE_DIR}/static/favicon.ico"
  "${CMAKE_CURRENT_SOURCE_DIR}/static/icon_192x192.png"
  "${CMAKE_CURRENT_SOURCE_DIR}/static/icon_512x512.png"
  "${CMAKE_CURRENT_SOURCE_DIR}/static/icon.svg"
  "${CMAKE_CURRENT_SOURCE_DIR}/static/apple-touch-icon.png"
  "${CMAKE_CURRENT_SOURCE_DIR}/static/manifest.webmanifest"
  "${PROJECT_SOURCE_DIR}/vendor/bootstrap-icons/font/fonts/bootstrap-icons.woff"
  "${PROJECT_SOURCE_DIR}/vendor/bootstrap-icons/font/fonts/bootstrap-icons.woff2")
set(REGISTRY_STATIC_METAPACK)
foreach(file_path IN LISTS REGISTRY_STATIC)
  get_filename_component(file_name "${file_path}" NAME)
  set(file_output "${CMAKE_CURRENT_BINARY_DIR}/metapack/${file_name}")
  sourcemeta_file2metapack_gzip(INPUT "${file_path}" OUTPUT "${file_output}")
  list(APPEND REGISTRY_STATIC_METAPACK "${file_output}")
endforeach()

install(FILES ${REGISTRY_STATIC_METAPACK}
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/static"
  COMPONENT sourcemeta_registry)

add_custom_target(sourcemeta_registry_web DEPENDS
  ${REGISTRY_STATIC_METAPACK}
  "${CMAKE_CURRENT_BINARY_DIR}/main.min.js"
  "${CMAKE_CURRENT_BINARY_DIR}/style.min.css")
