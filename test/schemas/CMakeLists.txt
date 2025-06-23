add_test(NAME registry.schemas COMMAND
  "$<TARGET_FILE:jsonschema_cli>"
  test "${CMAKE_CURRENT_SOURCE_DIR}"
  --resolve "${PROJECT_SOURCE_DIR}/schemas")
