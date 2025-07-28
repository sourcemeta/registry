sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME metapack SOURCES metapack.cc)

target_link_libraries(sourcemeta_registry_metapack PUBLIC sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_metapack PRIVATE sourcemeta::core::io)
target_link_libraries(sourcemeta_registry_metapack PRIVATE sourcemeta::core::md5)
target_link_libraries(sourcemeta_registry_metapack PRIVATE sourcemeta::core::time)
target_link_libraries(sourcemeta_registry_metapack PRIVATE sourcemeta::core::gzip)

sourcemeta_executable(NAMESPACE sourcemeta PROJECT registry NAME metapack_gzip_cli 
  SOURCES metapack_gzip_cli.cc)

target_link_libraries(sourcemeta_registry_metapack_gzip_cli PRIVATE sourcemeta::registry::metapack)
target_link_libraries(sourcemeta_registry_metapack_gzip_cli PRIVATE sourcemeta::core::io)
