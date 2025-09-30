set(COLLECTION_NAMESPACE "sdf/v1.0.0")
set(SDF_PATH "${PROJECT_SOURCE_DIR}/vendor/collections/${COLLECTION_NAMESPACE}")

install(FILES "${SDF_PATH}/sdf-framework.jso.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}/schemas"
  RENAME framework.json
  COMPONENT sourcemeta_registry)
install(FILES "${SDF_PATH}/sdf-validation.jso.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}/schemas"
  RENAME validation.json
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
