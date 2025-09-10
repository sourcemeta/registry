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
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}/schemas/configuration"
  COMPONENT sourcemeta_registry)

install(FILES
    "${CMAKE_CURRENT_LIST_DIR}/schemas/api/common/error.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/api/common/gmt.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/api/common/etag.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}/schemas/api/common"
  COMPONENT sourcemeta_registry)

install(FILES
    "${CMAKE_CURRENT_LIST_DIR}/schemas/api/schemas/dependencies.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/api/schemas/evaluate.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/api/schemas/health.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/api/schemas/list.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/api/schemas/locations.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/api/schemas/metadata.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/api/schemas/positions.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/api/schemas/search.json"
    "${CMAKE_CURRENT_LIST_DIR}/schemas/api/schemas/trace.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}/schemas/api/schemas"
  COMPONENT sourcemeta_registry)

install(FILES "${CMAKE_CURRENT_LIST_DIR}/registry.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)
install(FILES "${CMAKE_CURRENT_LIST_DIR}/jsonschema.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)
