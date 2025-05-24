if(NOT Core_FOUND)
  set(SOURCEMETA_CORE_INSTALL OFF CACHE BOOL "disable installation")
  set(SOURCEMETA_CORE_JSONL OFF CACHE BOOL "disable JSONL support")

  if(REGISTRY_TESTS)
    set(SOURCEMETA_CORE_CONTRIB_GOOGLETEST ON CACHE BOOL "GoogleTest")
  else()
    set(SOURCEMETA_CORE_CONTRIB_GOOGLETEST OFF CACHE BOOL "GoogleTest")
  endif()

  set(SOURCEMETA_CORE_CONTRIB_GOOGLEBENCHMARK OFF CACHE BOOL "GoogleBenchmark")

  add_subdirectory("${PROJECT_SOURCE_DIR}/vendor/core")
  include(Sourcemeta)
  set(Core_FOUND ON)
endif()
