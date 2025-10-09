sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME gzip
  PRIVATE_HEADERS error.h
  SOURCES gzip.cc)

target_link_libraries(sourcemeta_registry_gzip PRIVATE ZLIB::ZLIB)
