set(COLLECTION_NAMESPACE "modelcontextprotocol/2025-03-26")
set(MODELCONTEXTPROTOCOL_PATH "${PROJECT_SOURCE_DIR}/vendor/collections/modelcontextprotocol/schema/2025-03-26")

install(FILES "${MODELCONTEXTPROTOCOL_PATH}/schema.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}/schemas"
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
