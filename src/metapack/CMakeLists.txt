sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME metapack SOURCES metapack.cc)

target_link_libraries(sourcemeta_registry_metapack PRIVATE sourcemeta::core::io)
target_link_libraries(sourcemeta_registry_metapack PRIVATE sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_metapack PRIVATE sourcemeta::core::md5)
target_link_libraries(sourcemeta_registry_metapack PRIVATE sourcemeta::core::time)
