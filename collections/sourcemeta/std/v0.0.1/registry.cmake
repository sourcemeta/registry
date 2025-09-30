set(COLLECTION_NAMESPACE "sourcemeta/std/v0.0.1")

install(DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/schemas"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)
install(FILES "${CMAKE_CURRENT_LIST_DIR}/registry.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)

configure_file("${CMAKE_CURRENT_LIST_DIR}/jsonschema.json"
  "${CMAKE_CURRENT_BINARY_DIR}/${COLLECTION_NAMESPACE}.json" @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${COLLECTION_NAMESPACE}.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  RENAME jsonschema.json
  COMPONENT sourcemeta_registry)
