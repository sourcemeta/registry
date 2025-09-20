set(COLLECTION_NAMESPACE "openapi/v3.2")
set(OPENAPI_PATH "${PROJECT_SOURCE_DIR}/vendor/collections/openapi/oas/3.2")

set(OPENAPI_DIRECTORIES "dialect;meta;schema;schema-base")
foreach(OPENAPI_DIRECTORY ${OPENAPI_DIRECTORIES})
  file(GLOB OPENAPI_FILES "${OPENAPI_PATH}/${OPENAPI_DIRECTORY}/*")
  foreach(OPENAPI_FILE ${OPENAPI_FILES})
    get_filename_component(FILENAME "${OPENAPI_FILE}" NAME)
    install(FILES "${OPENAPI_FILE}"
      DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}/schemas/${OPENAPI_DIRECTORY}"
      RENAME "${FILENAME}.json"
      COMPONENT sourcemeta_registry)
  endforeach()
endforeach()

install(FILES "${CMAKE_CURRENT_LIST_DIR}/registry.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)
install(FILES "${CMAKE_CURRENT_LIST_DIR}/jsonschema.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)
