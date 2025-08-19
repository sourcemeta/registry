set(COLLECTION_NAMESPACE "modelcontextprotocol/2024-11-05")
set(MODELCONTEXTPROTOCOL_PATH "${PROJECT_SOURCE_DIR}/vendor/collections/modelcontextprotocol/schema/2024-11-05")

include(GNUInstallDirs)
install(FILES "${MODELCONTEXTPROTOCOL_PATH}/schema.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}/schemas"
  COMPONENT sourcemeta_registry)

install(FILES "${CMAKE_CURRENT_LIST_DIR}/registry.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)
