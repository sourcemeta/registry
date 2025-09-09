macro(sourcemeta_registry_test_cli_common program name)
  if(UNIX)
    add_test(NAME registry.${program}.common.${name} COMMAND
      "${CMAKE_CURRENT_SOURCE_DIR}/common/${program}/${name}.sh"
      "$<TARGET_FILE:sourcemeta_registry_${program}>"
      WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}")
    set_tests_properties(registry.${program}.common.${name} PROPERTIES
      ENVIRONMENT "REGISTRY_PREFIX=${REGISTRY_PREFIX}")
  endif()
endmacro()

macro(sourcemeta_registry_test_cli_edition program name)
  if(UNIX)
    add_test(NAME registry.${program}.${REGISTRY_EDITION}.${name} COMMAND
      "${CMAKE_CURRENT_SOURCE_DIR}/${REGISTRY_EDITION}/${program}/${name}.sh"
      "$<TARGET_FILE:sourcemeta_registry_${program}>"
      WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}")
    set_tests_properties(registry.${program}.${REGISTRY_EDITION}.${name} PROPERTIES
      ENVIRONMENT "REGISTRY_PREFIX=${REGISTRY_PREFIX}")
  endif()
endmacro()

if(REGISTRY_INDEX)
  sourcemeta_registry_test_cli_common(index bundle-ref-no-fragment)
  sourcemeta_registry_test_cli_common(index extend-builtin-not-found)
  sourcemeta_registry_test_cli_common(index external-reference)
  sourcemeta_registry_test_cli_common(index invalid-configuration)
  sourcemeta_registry_test_cli_common(index invalid-schema)
  sourcemeta_registry_test_cli_common(index invalid-schema-uri-percentage)
  sourcemeta_registry_test_cli_common(index invalid-url-option-relative)
  sourcemeta_registry_test_cli_common(index invalid-url-option-urn)
  sourcemeta_registry_test_cli_common(index invalid-url-option-non-http)
  sourcemeta_registry_test_cli_common(index invalid-url-option-no-value)
  sourcemeta_registry_test_cli_common(index output-non-directory)
  sourcemeta_registry_test_cli_common(index extra-files-on-rebuild)
  sourcemeta_registry_test_cli_common(index extra-directories-on-rebuild)
  sourcemeta_registry_test_cli_common(index directory-schema-same-name)
  sourcemeta_registry_test_cli_common(index rebuild-cache)
  sourcemeta_registry_test_cli_edition(index no-options)
  sourcemeta_registry_test_cli_edition(index no-output)
  sourcemeta_registry_test_cli_edition(index schema-limits)
  sourcemeta_registry_test_cli_edition(index license-check)
  sourcemeta_registry_test_cli_edition(index license-check-empty)
endif()
