set(COLLECTION_NAMESPACE "sourcemeta/registry")
set(COLLECTION_SCHEMAS
  "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration.json"
  "${CMAKE_CURRENT_LIST_DIR}/schemas/contents.json"
  "${CMAKE_CURRENT_LIST_DIR}/schemas/page.json"
  "${CMAKE_CURRENT_LIST_DIR}/schemas/collection.json"
  "${CMAKE_CURRENT_LIST_DIR}/schemas/extends.json"
  "${CMAKE_CURRENT_LIST_DIR}/schemas/uri-reference.json"
  "${CMAKE_CURRENT_LIST_DIR}/schemas/uri-relative.json"
  "${CMAKE_CURRENT_LIST_DIR}/schemas/uri.json"
  "${CMAKE_CURRENT_LIST_DIR}/schemas/urn.json"
  "${CMAKE_CURRENT_LIST_DIR}/schemas/url.json"
  "${CMAKE_CURRENT_LIST_DIR}/schemas/email-address.json"
  "${CMAKE_CURRENT_LIST_DIR}/schemas/path-posix.json"
  "${CMAKE_CURRENT_LIST_DIR}/schemas/path-posix-absolute.json"
  "${CMAKE_CURRENT_LIST_DIR}/schemas/path-posix-relative.json")

include(GNUInstallDirs)
install(FILES ${COLLECTION_SCHEMAS}
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}/schemas"
  COMPONENT sourcemeta_registry)
install(FILES "${CMAKE_CURRENT_LIST_DIR}/registry.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)
install(FILES "${CMAKE_CURRENT_LIST_DIR}/jsonschema.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)

add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${COLLECTION_NAMESPACE}/configuration.json"
  COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/${COLLECTION_NAMESPACE}"
  COMMAND "$<TARGET_FILE:jsonschema_cli>" bundle
    "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration.json"
    > "${CMAKE_CURRENT_BINARY_DIR}/${COLLECTION_NAMESPACE}/configuration.json"
  DEPENDS "$<TARGET_FILE:jsonschema_cli>" ${COLLECTION_SCHEMAS})
sourcemeta_schema2metapack_gzip(
  INPUT "${CMAKE_CURRENT_BINARY_DIR}/${COLLECTION_NAMESPACE}/configuration.json"
  DIALECT "https://json-schema.org/draft/2020-12/schema"
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${COLLECTION_NAMESPACE}/configuration.metapack")
list(APPEND REGISTRY_COLLECTION_SOURCES
  "${CMAKE_CURRENT_BINARY_DIR}/${COLLECTION_NAMESPACE}/configuration.metapack")
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${COLLECTION_NAMESPACE}/configuration.metapack"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/schemas"
  RENAME "configuration.json"
  COMPONENT sourcemeta_registry)

