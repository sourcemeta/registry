find_program(NODE_BIN NAMES node REQUIRED)

set(COLLECTION_NAMESPACE "geojson/v1.0.3")
set(GEOJSON_PATH "${PROJECT_SOURCE_DIR}/vendor/collections/${COLLECTION_NAMESPACE}")

set(GEOJSON_SCRIPTS
  "${GEOJSON_PATH}/src/schema/ref/PointCoordinates.js"
  "${GEOJSON_PATH}/src/schema/ref/PolygonCoordinates.js"
  "${GEOJSON_PATH}/src/schema/ref/LinearRingCoordinates.js"
  "${GEOJSON_PATH}/src/schema/ref/LineStringCoordinates.js"
  "${GEOJSON_PATH}/src/schema/ref/BoundingBox.js"
  "${GEOJSON_PATH}/src/schema/Polygon.js"
  "${GEOJSON_PATH}/src/schema/MultiPolygon.js"
  "${GEOJSON_PATH}/src/schema/MultiLineString.js"
  "${GEOJSON_PATH}/src/schema/Feature.js"
  "${GEOJSON_PATH}/src/schema/LineString.js"
  "${GEOJSON_PATH}/src/schema/MultiPoint.js"
  "${GEOJSON_PATH}/src/schema/FeatureCollection.js"
  "${GEOJSON_PATH}/src/schema/GeometryCollection.js"
  "${GEOJSON_PATH}/src/schema/GeoJSON.js"
  "${GEOJSON_PATH}/src/schema/Point.js"
  "${GEOJSON_PATH}/src/schema/Geometry.js")

foreach(script IN LISTS GEOJSON_SCRIPTS)
  get_filename_component(schema_name "${script}" NAME_WE)
  set(schema_output "${CMAKE_CURRENT_BINARY_DIR}/collections/${COLLECTION_NAMESPACE}/${schema_name}.json")
  cmake_path(GET schema_output PARENT_PATH schema_parent)
  add_custom_command(OUTPUT "${schema_output}"
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${schema_parent}"
    COMMAND "${NODE_BIN}" "${GEOJSON_PATH}/bin/format.js" "${script}" > "${schema_output}"
    DEPENDS "${GEOJSON_PATH}/bin/format.js" ${GEOJSON_SCRIPTS})
  list(APPEND REGISTRY_COLLECTION_SOURCES "${schema_output}")
  install(FILES "${schema_output}"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}/schemas"
    COMPONENT sourcemeta_registry)
endforeach()

install(FILES "${CMAKE_CURRENT_LIST_DIR}/registry.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)
install(FILES "${CMAKE_CURRENT_LIST_DIR}/jsonschema.json"
  DESTINATION "${CMAKE_INSTALL_DATADIR}/sourcemeta/registry/collections/${COLLECTION_NAMESPACE}"
  COMPONENT sourcemeta_registry)
