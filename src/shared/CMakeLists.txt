sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME shared
  PRIVATE_HEADERS license.h metapack.h encoding.h version.h
  SOURCES license.cc metapack.cc version.cc configure.h.in)

target_link_libraries(sourcemeta_registry_shared PUBLIC sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_shared PRIVATE sourcemeta::core::io)
target_link_libraries(sourcemeta_registry_shared PRIVATE sourcemeta::core::uuid)
target_link_libraries(sourcemeta_registry_shared PRIVATE sourcemeta::core::md5)
target_link_libraries(sourcemeta_registry_shared PRIVATE sourcemeta::core::time)
target_link_libraries(sourcemeta_registry_shared PRIVATE sourcemeta::registry::gzip)

configure_file(configure.h.in configure.h @ONLY)
target_include_directories(sourcemeta_registry_shared
  PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")
