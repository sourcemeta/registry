cmake_minimum_required(VERSION 3.16)
project(registry VERSION 3.2.0 LANGUAGES C CXX)
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

# Options
option(REGISTRY_TESTS "Build the Registry unit tests" ON)
option(REGISTRY_SERVER "Build the Registry server" ON)
option(REGISTRY_INDEX "Build the Registry index tool" ON)
set(REGISTRY_PREFIX "/usr" CACHE STRING "Expected installation prefix")

# Commercial editions require a paid license
# See https://github.com/sourcemeta/registry/blob/main/LICENSE
set(REGISTRY_EDITION "starter" CACHE STRING "The Registry edition")
if(REGISTRY_EDITION)
  message(STATUS "Sourcemeta Registry edition: ${REGISTRY_EDITION}")
else()
  message(FATAL_ERROR "You must set an edition using REGISTRY_EDITION")
endif()

cmake_path(IS_ABSOLUTE REGISTRY_PREFIX REGISTRY_PREFIX_IS_ABSOLUTE)
if(NOT REGISTRY_PREFIX_IS_ABSOLUTE)
  message(FATAL_ERROR "REGISTRY_PREFIX must be an absolute path but it was: ${REGISTRY_PREFIX}")
endif()

find_package(Core REQUIRED)
find_package(Blaze REQUIRED)
find_package(JSONBinPack REQUIRED)
find_package(JSONSchema REQUIRED)

include(GNUInstallDirs)

# Always optimize the current architecture
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -march=native")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -mtune=native")

# Set these globally to not repeat ourselves in every target
if(REGISTRY_EDITION STREQUAL "enterprise")
  add_compile_definitions(SOURCEMETA_REGISTRY_ENTERPRISE)
elseif(REGISTRY_EDITION STREQUAL "pro")
  add_compile_definitions(SOURCEMETA_REGISTRY_PRO)
else()
  add_compile_definitions(SOURCEMETA_REGISTRY_STARTER)
endif()

if(REGISTRY_INDEX OR REGISTRY_SERVER)
  add_subdirectory(src/shared)
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Release")
  set(REGISTRY_VERSION "${PROJECT_VERSION}")
else()
  find_program(GIT_BIN NAMES git)
  if(GIT_BIN AND JSONSCHEMA_CONTINUOUS)
    execute_process(COMMAND "${GIT_BIN}" rev-parse --git-dir
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
      OUTPUT_VARIABLE GIT_DIR)
  endif()
  if(GIT_BIN AND EXISTS "${GIT_DIR}")
    execute_process(
      COMMAND "${GIT_BIN}" rev-parse --short=8 HEAD
      WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
      OUTPUT_VARIABLE PROJECT_GIT_SHA
      OUTPUT_STRIP_TRAILING_WHITESPACE
      COMMAND_ERROR_IS_FATAL ANY)
  else()
    set(PROJECT_GIT_SHA "unknown")
  endif()
  set(REGISTRY_VERSION "${PROJECT_VERSION}+${PROJECT_GIT_SHA}")
endif()
message(STATUS "Registry version: ${REGISTRY_VERSION}")

if(REGISTRY_INDEX)
  add_subdirectory(contrib/file2metapack)
  include(commands/file2metapack)
  include(commands/esbuild)
  add_subdirectory(src/configuration)
  add_subdirectory(src/resolver)
  add_subdirectory(src/index)
  add_subdirectory(collections)
  add_dependencies(sourcemeta_registry_index
    sourcemeta_registry_collections)
  add_subdirectory(src/web)
  add_dependencies(sourcemeta_registry_index
    sourcemeta_registry_web)
endif()

if(REGISTRY_SERVER)
  find_package(uSockets REQUIRED)
  find_package(uWebSockets REQUIRED)
  add_subdirectory(src/server)
endif()

sourcemeta_target_clang_format(SOURCES src/*.h src/*.cc test/*.cc contrib/*.cc)
sourcemeta_target_shellcheck(SOURCES test/*.sh docker/*.sh)

set(SOURCEMETA_SCHEMAS "${PROJECT_SOURCE_DIR}/collections/sourcemeta/registry/schemas")
add_custom_target(jsonschema_fmt_test
  COMMAND "$<TARGET_FILE:jsonschema_cli>" fmt --check --verbose ${SOURCEMETA_SCHEMAS})
add_custom_target(jsonschema_fmt
  COMMAND "$<TARGET_FILE:jsonschema_cli>" fmt --verbose ${SOURCEMETA_SCHEMAS})
add_custom_target(jsonschema_metaschema
  COMMAND "$<TARGET_FILE:jsonschema_cli>" metaschema --verbose ${SOURCEMETA_SCHEMAS})
add_custom_target(jsonschema_lint
  COMMAND "$<TARGET_FILE:jsonschema_cli>" lint --strict --verbose
  ${SOURCEMETA_SCHEMAS})

if(REGISTRY_TESTS)
  enable_testing()
  add_test(NAME registry.schemas COMMAND
    "$<TARGET_FILE:jsonschema_cli>" test --extension .test.json
    "${PROJECT_SOURCE_DIR}/collections/sourcemeta")

  if(REGISTRY_INDEX)
    add_subdirectory(test/unit/configuration)
    add_subdirectory(test/unit/resolver)
  endif()
  add_subdirectory(test/cli)
endif()
