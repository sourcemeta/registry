set(COLLECTION_NAMESPACE "openapi/v2.0")
set(OPENAPI_PATH "${PROJECT_SOURCE_DIR}/vendor/collections/openapi/oas/2.0/schema")

install(FILES "${OPENAPI_PATH}/2017-08-27"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}/schemas"
  RENAME 2017-08-27.json
  COMPONENT sourcemeta_registry)

install(FILES "${CMAKE_CURRENT_LIST_DIR}/registry.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)
install(FILES "${CMAKE_CURRENT_LIST_DIR}/jsonschema.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)
