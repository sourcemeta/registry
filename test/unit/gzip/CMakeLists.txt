sourcemeta_googletest(NAMESPACE sourcemeta PROJECT registry NAME gzip
  SOURCES gzip_test.cc)

target_link_libraries(sourcemeta_registry_gzip_unit
  PRIVATE sourcemeta::registry::gzip)
