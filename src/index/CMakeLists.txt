sourcemeta_executable(NAMESPACE sourcemeta PROJECT registry NAME index 
  FOLDER "Registry/Index" 
  SOURCES index.cc output.h generators.h semver.h parallel.h
    configure.h.in html_partials.h html_safe.h validator.h
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

set(REGISTRY_STATIC_META)
foreach(file_path IN LISTS REGISTRY_STATIC)
  get_filename_component(file_name "${file_path}" NAME)
  add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/meta/${file_name}.meta"
    COMMAND "${CMAKE_COMMAND}" 
      -DINPUT="${file_path}" 
      -DOUTPUT="${CMAKE_CURRENT_BINARY_DIR}/meta/${file_name}.meta"
      -P "${CMAKE_CURRENT_SOURCE_DIR}/metadata.cmake"
    DEPENDS "${file_path}" "${CMAKE_CURRENT_SOURCE_DIR}/metadata.cmake")
  target_sources(sourcemeta_registry_index 
    PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/meta/${file_name}.meta")
  list(APPEND REGISTRY_STATIC_META 
    "${CMAKE_CURRENT_BINARY_DIR}/meta/${file_name}.meta")
endforeach()

install(FILES ${REGISTRY_STATIC} ${REGISTRY_STATIC_META}
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/static"
  COMPONENT sourcemeta_registry)
