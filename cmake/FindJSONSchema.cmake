if(NOT JSONSchema_FOUND)
  add_subdirectory("${PROJECT_SOURCE_DIR}/vendor/jsonschema")
  set(JSONSchema_FOUND ON)
endif()
