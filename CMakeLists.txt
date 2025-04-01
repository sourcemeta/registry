cmake_minimum_required(VERSION 3.16)
project(registry VERSION 0.0.1 LANGUAGES CXX)
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

# Options
option(REGISTRY_DEVELOPMENT "Build the Registry in development mode" OFF)
option(REGISTRY_SERVER "Build the Registry server" ON)
option(REGISTRY_INDEX "Build the Registry index tool" ON)
set(REGISTRY_PREFIX "/usr" CACHE STRING "Expected installation prefix")

# Commercial editions require a paid license
# See https://github.com/sourcemeta/registry/blob/main/LICENSE
set(REGISTRY_EDITION "starter" CACHE STRING "The Registry edition")

cmake_path(IS_ABSOLUTE REGISTRY_PREFIX REGISTRY_PREFIX_IS_ABSOLUTE)
if(NOT REGISTRY_PREFIX_IS_ABSOLUTE)
  message(FATAL_ERROR "REGISTRY_PREFIX must be an absolute path but it was: ${REGISTRY_PREFIX}")
endif()

find_package(Core REQUIRED)
find_package(Blaze REQUIRED)
find_package(Hydra REQUIRED)

# Always optimize the current architecture
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -march=native")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -mtune=native")

if(REGISTRY_INDEX)
  add_subdirectory(src/html)
  add_subdirectory(src/index)
endif()

if(REGISTRY_SERVER)
  add_subdirectory(src/server)
endif()

if(PROJECT_IS_TOP_LEVEL AND REGISTRY_DEVELOPMENT)
  sourcemeta_target_clang_format(SOURCES src/*.h src/*.cc)
  sourcemeta_target_shellcheck(SOURCES test/*.sh)
endif()
