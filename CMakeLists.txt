cmake_minimum_required(VERSION 3.16)
project(registry VERSION 0.0.1 LANGUAGES CXX)
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

# Options
option(REGISTRY_DEVELOPMENT "Build the Registry in development mode" OFF)
option(REGISTRY_SERVER "Build the Registry server" ON)
option(REGISTRY_INDEX "Build the Registry index tool" ON)
option(REGISTRY_ENTERPRISE "Build the Registry Enterprise edition (requires a license)" OFF)
set(REGISTRY_PREFIX "/usr" CACHE STRING "Expected installation prefix")

find_package(Noa REQUIRED)
find_package(JSONToolkit REQUIRED)
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
  noa_target_clang_format(SOURCES src/*.h src/*.cc)
  noa_target_shellcheck(SOURCES test/*.sh)
endif()
