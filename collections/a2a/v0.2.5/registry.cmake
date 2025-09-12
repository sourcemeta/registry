set(COLLECTION_NAMESPACE "a2a/v0.2.5")

install(FILES "${PROJECT_SOURCE_DIR}/vendor/collections/${COLLECTION_NAMESPACE}/specification/json/a2a.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}/schemas"
  RENAME schema.json
  COMPONENT sourcemeta_registry)

install(FILES "${CMAKE_CURRENT_LIST_DIR}/registry.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)
install(FILES "${CMAKE_CURRENT_LIST_DIR}/jsonschema.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)
