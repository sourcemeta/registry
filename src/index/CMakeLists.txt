sourcemeta_executable(NAMESPACE sourcemeta PROJECT registry NAME index 
  FOLDER "Registry/Index" 
  SOURCES index.cc output.h generators.h parallel.h
    configure.h.in validator.h explorer.h
    "${PROJECT_SOURCE_DIR}/schemas/configuration.json")

set_target_properties(sourcemeta_registry_index PROPERTIES OUTPUT_NAME sourcemeta-registry-index)

target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::registry::resolver)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::registry::license)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::registry::metapack)

target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::uri)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::jsonschema)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::yaml)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::md5)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::gzip)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::core::time)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::blaze::compiler)
target_link_libraries(sourcemeta_registry_index PRIVATE sourcemeta::blaze::evaluator)

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

# Generate JS
find_program(ESBUILD_BIN NAMES esbuild REQUIRED)
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/main.min.js"
  COMMAND "${ESBUILD_BIN}" --bundle 
    "${CMAKE_CURRENT_SOURCE_DIR}/assets/main.js"
    --outfile="${CMAKE_CURRENT_BINARY_DIR}/main.min.js"
    --minify
  DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/assets/main.js")
target_sources(sourcemeta_registry_index PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/main.min.js")

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
target_sources(sourcemeta_registry_index PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/style.min.css")

# Generate static files
set(REGISTRY_STATIC
  "${CMAKE_CURRENT_BINARY_DIR}/style.min.css"
  "${CMAKE_CURRENT_BINARY_DIR}/main.min.js"
  "${CMAKE_CURRENT_SOURCE_DIR}/assets/favicon.ico"
  "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon_192x192.png"
  "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon_512x512.png"
  "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.svg"
  "${CMAKE_CURRENT_SOURCE_DIR}/assets/apple-touch-icon.png"
  "${CMAKE_CURRENT_SOURCE_DIR}/assets/manifest.webmanifest"
  "${PROJECT_SOURCE_DIR}/vendor/bootstrap-icons/font/fonts/bootstrap-icons.woff"
  "${PROJECT_SOURCE_DIR}/vendor/bootstrap-icons/font/fonts/bootstrap-icons.woff2")

set(REGISTRY_STATIC_METAPACK)
foreach(file_path IN LISTS REGISTRY_STATIC)
  get_filename_component(file_extension "${file_path}" EXT)
  string(TOLOWER "${file_extension}" file_extension)
  if(file_extension STREQUAL ".png")
    set(MIME "image/png")
  elseif(file_extension STREQUAL ".svg")
    set(MIME "image/svg+xml")
  elseif(file_extension STREQUAL ".min.css")
    set(MIME "text/css")
  elseif(file_extension STREQUAL ".js")
    set(MIME "text/javascript")
  elseif(file_extension STREQUAL ".min.js")
    set(MIME "text/javascript")
  elseif(file_extension STREQUAL ".ico")
    set(MIME "image/vnd.microsoft.icon")
  elseif(file_extension STREQUAL ".webmanifest")
    set(MIME "application/manifest+json")
  elseif(file_extension STREQUAL ".woff")
    set(MIME "font/woff")
  elseif(file_extension STREQUAL ".woff2")
    set(MIME "font/woff2")
  else()
    message(FATAL_ERROR "Cannot determine MIME type for ${file_extension}")
  endif()

  get_filename_component(file_name "${file_path}" NAME)
  add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/metapack/${file_name}"
    COMMAND "$<TARGET_FILE:sourcemeta_registry_metapack_gzip_cli>"
      "${file_path}" "${MIME}" "${CMAKE_CURRENT_BINARY_DIR}/metapack/${file_name}"
    DEPENDS "${file_path}" "$<TARGET_FILE:sourcemeta_registry_metapack_gzip_cli>")
  target_sources(sourcemeta_registry_index 
    PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/metapack/${file_name}")
  list(APPEND REGISTRY_STATIC_METAPACK
    "${CMAKE_CURRENT_BINARY_DIR}/metapack/${file_name}")
endforeach()

install(FILES ${REGISTRY_STATIC_METAPACK}
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/static"
  COMPONENT sourcemeta_registry)
