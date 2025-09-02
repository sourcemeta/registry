set(COLLECTION_NAMESPACE "sourcemeta/registry")

include(GNUInstallDirs)
install(FILES
    "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration/configuration.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration/contents.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration/page.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration/collection.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration/extends.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration/uri-reference.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration/uri-relative.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration/uri.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration/urn.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration/url.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration/email-address.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration/path-posix.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration/path-posix-absolute.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/configuration/path-posix-relative.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}/schemas"
  COMPONENT sourcemeta_registry)

install(FILES "${CMAKE_CURRENT_LIST_DIR}/registry.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)
install(FILES "${CMAKE_CURRENT_LIST_DIR}/jsonschema.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)
