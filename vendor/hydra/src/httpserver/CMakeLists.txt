sourcemeta_library(NAMESPACE sourcemeta PROJECT hydra NAME httpserver
  FOLDER "Hydra/HTTP Server"
  PRIVATE_HEADERS request.h response.h logger.h
  SOURCES uwebsockets.h httpserver.cc request.cc response.cc logger.cc static.cc)

if(HYDRA_INSTALL)
  sourcemeta_library_install(NAMESPACE sourcemeta PROJECT hydra NAME httpserver)
endif()

target_link_libraries(sourcemeta_hydra_httpserver PUBLIC sourcemeta::hydra::http)
target_link_libraries(sourcemeta_hydra_httpserver PUBLIC sourcemeta::core::json)
target_link_libraries(sourcemeta_hydra_httpserver PRIVATE sourcemeta::core::uuid)
target_link_libraries(sourcemeta_hydra_httpserver PRIVATE sourcemeta::core::gzip)
target_link_libraries(sourcemeta_hydra_httpserver PRIVATE sourcemeta::core::md5)
target_link_libraries(sourcemeta_hydra_httpserver PRIVATE uNetworking::uSockets)
target_link_libraries(sourcemeta_hydra_httpserver PRIVATE uNetworking::uWebSockets)
