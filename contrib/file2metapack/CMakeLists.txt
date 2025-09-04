sourcemeta_executable(NAMESPACE sourcemeta PROJECT registry NAME file2metapack
  SOURCES file2metapack.cc)

target_link_libraries(sourcemeta_registry_file2metapack
  PRIVATE sourcemeta::registry::metapack)
target_link_libraries(sourcemeta_registry_file2metapack
  PRIVATE sourcemeta::core::options)
