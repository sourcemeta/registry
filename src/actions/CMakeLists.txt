sourcemeta_library(NAMESPACE sourcemeta PROJECT one NAME actions
  SOURCES actions.cc
    action_auth_login_page_v1.h
    action_default_v1.h
    action_dependency_tree_v1.h
    action_health_check_v1.h
    action_metrics_v1.h
    action_jsonschema_evaluate_v1.h
    action_jsonschema_rdf_v1.h
    action_jsonschema_serve_v1.h
    action_jsonschema_trace_v1.h
    action_list_directory_v1.h
    action_not_found_v1.h
    action_schema_search_v1.h
    action_serve_explorer_artifact_v1.h
    action_serve_schema_artifact_v1.h
    action_serve_static_v1.h
    action_mcp_v1.h)

target_link_libraries(sourcemeta_one_actions PUBLIC sourcemeta::one::router)
target_link_libraries(sourcemeta_one_actions PUBLIC sourcemeta::one::http)
target_link_libraries(sourcemeta_one_actions PUBLIC sourcemeta::core::uritemplate)
target_link_libraries(sourcemeta_one_actions PRIVATE sourcemeta::core::json)
target_link_libraries(sourcemeta_one_actions PRIVATE sourcemeta::core::uri)
target_link_libraries(sourcemeta_one_actions PUBLIC sourcemeta::core::jsonrpc)
target_link_libraries(sourcemeta_one_actions PRIVATE sourcemeta::core::mcp)
target_link_libraries(sourcemeta_one_actions PRIVATE sourcemeta::core::jsonpointer)
target_link_libraries(sourcemeta_one_actions PRIVATE sourcemeta::core::io)
target_link_libraries(sourcemeta_one_actions PRIVATE sourcemeta::core::text)
target_link_libraries(sourcemeta_one_actions PRIVATE sourcemeta::core::time)
target_link_libraries(sourcemeta_one_actions PRIVATE sourcemeta::one::shared)
target_link_libraries(sourcemeta_one_actions PUBLIC sourcemeta::one::metapack)
target_link_libraries(sourcemeta_one_actions PRIVATE sourcemeta::one::search)
target_link_libraries(sourcemeta_one_actions PUBLIC sourcemeta::blaze::evaluator)
target_link_libraries(sourcemeta_one_actions PUBLIC sourcemeta::blaze::compiler)
target_link_libraries(sourcemeta_one_actions PUBLIC sourcemeta::blaze::foundation)
target_link_libraries(sourcemeta_one_actions PRIVATE sourcemeta::blaze::output)

if(ONE_ENTERPRISE)
  target_link_libraries(sourcemeta_one_actions
    PUBLIC sourcemeta::one::enterprise_server)
endif()
