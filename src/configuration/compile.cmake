execute_process(
  COMMAND "${JSONSCHEMA}" compile --minify "${INPUT}"
  OUTPUT_FILE "${OUTPUT}"
  RESULT_VARIABLE RESULT)

if(RESULT)
  message(FATAL_ERROR "Failed to compile schema: ${INPUT}")
endif()
