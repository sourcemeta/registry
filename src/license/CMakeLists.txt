sourcemeta_library(NAMESPACE sourcemeta PROJECT registry NAME license SOURCES license.cc)

# TODO: De-duplicate this with a common macro
if(REGISTRY_EDITION STREQUAL "enterprise")
  target_compile_definitions(sourcemeta_registry_license 
    PRIVATE SOURCEMETA_REGISTRY_ENTERPRISE)
elseif(REGISTRY_EDITION STREQUAL "pro")
  target_compile_definitions(sourcemeta_registry_license 
    PRIVATE SOURCEMETA_REGISTRY_PRO)
else()
  target_compile_definitions(sourcemeta_registry_license 
    PRIVATE SOURCEMETA_REGISTRY_STARTER)
endif()
