sourcemeta_esbuild_bundle(
  ENTRYPOINT "${CMAKE_CURRENT_SOURCE_DIR}/main.js"
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/main.min.js"
  DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/main.js"
    "${CMAKE_CURRENT_SOURCE_DIR}/search.js"
    "${CMAKE_CURRENT_SOURCE_DIR}/tabs.js"
    "${CMAKE_CURRENT_SOURCE_DIR}/editor.js")

# OpenAPI artifacts
set(OPENAPI_DEPENDENCIES
  "${PROJECT_SOURCE_DIR}/openapi/api/fetch.yaml"
  "${PROJECT_SOURCE_DIR}/openapi/api/list.yaml"
  "${PROJECT_SOURCE_DIR}/openapi/api/list-root.yaml"
  "${PROJECT_SOURCE_DIR}/openapi/api/schemas/dependencies.yaml"
  "${PROJECT_SOURCE_DIR}/openapi/api/schemas/evaluate.yaml"
  "${PROJECT_SOURCE_DIR}/openapi/api/schemas/health.yaml"
  "${PROJECT_SOURCE_DIR}/openapi/api/schemas/locations.yaml"
  "${PROJECT_SOURCE_DIR}/openapi/api/schemas/metadata.yaml"
  "${PROJECT_SOURCE_DIR}/openapi/api/schemas/positions.yaml"
  "${PROJECT_SOURCE_DIR}/openapi/api/schemas/search.yaml"
  "${PROJECT_SOURCE_DIR}/openapi/api/schemas/trace.yaml"
  "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas/api/list.json"
  "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas/api/common/error.json"
  "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas/api/common/etag.json"
  "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas/api/common/gmt.json"
  "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas/api/common/schema.json"
  "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas/api/schemas/dependencies.json"
  "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas/api/schemas/evaluate.json"
  "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas/api/schemas/health.json"
  "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas/api/schemas/locations.json"
  "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas/api/schemas/metadata.json"
  "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas/api/schemas/positions.json"
  "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas/api/schemas/search.json"
  "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas/api/schemas/trace.json"
  "${PROJECT_SOURCE_DIR}/package.json"
  "${PROJECT_SOURCE_DIR}/package-lock.json")
sourcemeta_redocly_openapi_to_html(
  REDOCLY "${PROJECT_SOURCE_DIR}/node_modules/@redocly/cli/bin/cli.js"
  INPUT "${PROJECT_SOURCE_DIR}/openapi/openapi.yaml"
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/openapi.html"
  DEPENDS ${OPENAPI_DEPENDENCIES})
# TODO: Serve the OpenAPI.json at `/self/openapi`. Do it dynamically to
# put the right server URLs and versions on the fly?
sourcemeta_redocly_openapi_to_json(
  REDOCLY "${PROJECT_SOURCE_DIR}/node_modules/@redocly/cli/bin/cli.js"
  INPUT "${PROJECT_SOURCE_DIR}/openapi/openapi.yaml"
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/openapi.json"
  DEPENDS ${OPENAPI_DEPENDENCIES})

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
  "${CMAKE_CURRENT_BINARY_DIR}/openapi.html"
  "${CMAKE_CURRENT_BINARY_DIR}/openapi.json"
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

include(GNUInstallDirs)

install(FILES ${REGISTRY_STATIC_METAPACK}
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/static"
  COMPONENT sourcemeta_registry)

add_custom_target(sourcemeta_registry_web DEPENDS
  ${REGISTRY_STATIC_METAPACK}
  "${CMAKE_CURRENT_BINARY_DIR}/main.min.js"
  "${CMAKE_CURRENT_BINARY_DIR}/openapi.html"
  "${CMAKE_CURRENT_BINARY_DIR}/openapi.json"
  "${CMAKE_CURRENT_BINARY_DIR}/style.min.css")
