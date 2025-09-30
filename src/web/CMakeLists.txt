sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME web
  SOURCES helpers.h page.h
    pages/index.cc
    pages/directory.cc
    pages/schema.cc
    pages/not_found.cc)

target_link_libraries(sourcemeta_registry_web PUBLIC sourcemeta::core::build)
target_link_libraries(sourcemeta_registry_web PRIVATE sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_web PUBLIC sourcemeta::registry::configuration)
target_link_libraries(sourcemeta_registry_web PRIVATE sourcemeta::registry::shared)
target_link_libraries(sourcemeta_registry_web PRIVATE sourcemeta::registry::html)

sourcemeta_esbuild_bundle(
  ENTRYPOINT "${CMAKE_CURRENT_SOURCE_DIR}/scripts/main.js"
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/main.min.js"
  DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/scripts/main.js"
    "${CMAKE_CURRENT_SOURCE_DIR}/scripts/search.js"
    "${CMAKE_CURRENT_SOURCE_DIR}/scripts/tabs.js"
    "${CMAKE_CURRENT_SOURCE_DIR}/scripts/editor.js")

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

target_sources(sourcemeta_registry_web PRIVATE ${REGISTRY_STATIC_METAPACK}
  "${CMAKE_CURRENT_BINARY_DIR}/main.min.js"
  "${CMAKE_CURRENT_BINARY_DIR}/style.min.css")
