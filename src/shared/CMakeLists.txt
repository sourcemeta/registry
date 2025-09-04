sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME shared
  PRIVATE_HEADERS license.h metapack.h encoding.h
  SOURCES license.cc metapack.cc)

target_link_libraries(sourcemeta_registry_shared PUBLIC sourcemeta::core::json)
target_link_libraries(sourcemeta_registry_shared PRIVATE sourcemeta::core::io)
target_link_libraries(sourcemeta_registry_shared PRIVATE sourcemeta::core::md5)
target_link_libraries(sourcemeta_registry_shared PRIVATE sourcemeta::core::time)
target_link_libraries(sourcemeta_registry_shared PRIVATE sourcemeta::core::gzip)

# TODO: De-duplicate this with a common macro
if(REGISTRY_EDITION STREQUAL "enterprise")
  target_compile_definitions(sourcemeta_registry_shared
    PRIVATE SOURCEMETA_REGISTRY_ENTERPRISE)
elseif(REGISTRY_EDITION STREQUAL "pro")
  target_compile_definitions(sourcemeta_registry_shared
    PRIVATE SOURCEMETA_REGISTRY_PRO)
else()
  target_compile_definitions(sourcemeta_registry_shared
    PRIVATE SOURCEMETA_REGISTRY_STARTER)
endif()
