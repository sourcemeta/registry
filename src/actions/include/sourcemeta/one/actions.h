#ifndef SOURCEMETA_ONE_ACTIONS_H
#define SOURCEMETA_ONE_ACTIONS_H

#include <sourcemeta/one/router.h>

#include <array>       // std::array
#include <cstdint>     // std::uint8_t
#include <string_view> // std::string_view

namespace sourcemeta::one {

// New entries are appended rather than inserted, since the position of an
// entry is the identifier a built router records for it, and an identifier
// that moves points an already-built router at the wrong handler.
//
// The third column is what an action is called to anybody outside this
// program, which is a name this project promises rather than one it happens to
// use. It is written down rather than derived from the first, so that renaming
// a handler is an internal matter and renaming what an operator sees is a
// deliberate act
#define SOURCEMETA_ONE_FOR_EACH_ACTION(X)                                      \
  X(DEFAULT_V1, ActionDefaultV1, "default_v1")                                 \
  X(HEALTH_CHECK_V1, ActionHealthCheckV1, "health_check_v1")                   \
  X(NOT_FOUND_V1, ActionNotFoundV1, "not_found_v1")                            \
  X(SCHEMA_ARTIFACT_V1, ActionServeSchemaArtifactV1, "schema_artifact_v1")     \
  X(EXPLORER_ARTIFACT_V1, ActionServeExplorerArtifactV1,                       \
    "explorer_artifact_v1")                                                    \
  X(GET_SCHEMA_HEALTH_V1, ActionGetSchemaHealthV1, "get_schema_health_v1")     \
  X(GET_SCHEMA_LOCATIONS_V1, ActionGetSchemaLocationsV1,                       \
    "get_schema_locations_v1")                                                 \
  X(GET_SCHEMA_POSITIONS_V1, ActionGetSchemaPositionsV1,                       \
    "get_schema_positions_v1")                                                 \
  X(GET_SCHEMA_STATS_V1, ActionGetSchemaStatsV1, "get_schema_stats_v1")        \
  X(GET_SCHEMA_METADATA_V1, ActionGetSchemaMetadataV1,                         \
    "get_schema_metadata_v1")                                                  \
  X(LIST_DIRECTORY_V1, ActionListDirectoryV1, "list_directory_v1")             \
  X(DEPENDENCY_TREE_V1, ActionDependencyTreeV1, "dependency_tree_v1")          \
  X(GET_SCHEMA_DEPENDENCIES_V1, ActionGetSchemaDependenciesV1,                 \
    "get_schema_dependencies_v1")                                              \
  X(GET_SCHEMA_DEPENDENTS_V1, ActionGetSchemaDependentsV1,                     \
    "get_schema_dependents_v1")                                                \
  X(JSONSCHEMA_EVALUATE_V1, ActionJSONSchemaEvaluateV1,                        \
    "jsonschema_evaluate_v1")                                                  \
  X(JSONSCHEMA_RDF_V1, ActionJSONSchemaRDFV1, "jsonschema_rdf_v1")             \
  X(JSONSCHEMA_TRACE_V1, ActionJSONSchemaTraceV1, "jsonschema_trace_v1")       \
  X(SCHEMA_SEARCH_V1, ActionSchemaSearchV1, "schema_search_v1")                \
  X(SERVE_STATIC_V1, ActionServeStaticV1, "serve_static_v1")                   \
  X(MCP_V1, ActionMCPV1, "mcp_v1")                                             \
  X(AUTH_LOGOUT_V1, ActionAuthLogoutV1, "auth_logout_v1")                      \
  X(AUTH_LOGIN_V1, ActionAuthLoginV1, "auth_login_v1")                         \
  X(AUTH_LOGIN_PAGE_V1, ActionAuthLoginPageV1, "auth_login_page_v1")           \
  X(AUTH_CALLBACK_V1, ActionAuthCallbackV1, "auth_callback_v1")                \
  X(MCP_PROTECTED_RESOURCE_METADATA_V1, ActionMCPProtectedResourceMetadataV1,  \
    "mcp_protected_resource_metadata_v1")                                      \
  X(METRICS_V1, ActionMetricsV1, "metrics_v1")                                 \
  X(PLAYGROUND_SCHEMA_TRACE_V1, ActionPlaygroundSchemaTraceV1,                 \
    "playground_schema_trace_v1")

#define SOURCEMETA_ONE_DEFINE_ACTION_TYPE(Name, Class, Label)                  \
  ACTION_TYPE_##Name,

// The value of an entry is the identifier a built router records for it, so
// these stand in for an integer wherever a router asks for one
// NOLINTNEXTLINE(cppcoreguidelines-use-enum-class)
enum : std::uint8_t {
  SOURCEMETA_ONE_FOR_EACH_ACTION(SOURCEMETA_ONE_DEFINE_ACTION_TYPE)
      ACTION_TYPE_COUNT
};

#undef SOURCEMETA_ONE_DEFINE_ACTION_TYPE

#define SOURCEMETA_ONE_DEFINE_ACTION_NAME(Name, Class, Label)                  \
  std::string_view{Label},

// Indexed by the same values the enum above defines, since both come from the
// one list and neither can name an action the other does not have
inline constexpr std::array<std::string_view, ACTION_TYPE_COUNT> ACTION_NAMES{
    {SOURCEMETA_ONE_FOR_EACH_ACTION(SOURCEMETA_ONE_DEFINE_ACTION_NAME)}};

#undef SOURCEMETA_ONE_DEFINE_ACTION_NAME

extern const std::array<RouterActionConstructor, ACTION_TYPE_COUNT>
    CONSTRUCTORS;

[[nodiscard]] auto action_description(
    sourcemeta::core::URITemplateRouter::Identifier context) noexcept
    -> std::string_view;

[[nodiscard]] auto
is_read_only(sourcemeta::core::URITemplateRouter::Identifier context) noexcept
    -> bool;

[[nodiscard]] auto
is_destructive(sourcemeta::core::URITemplateRouter::Identifier context) noexcept
    -> bool;

[[nodiscard]] auto
is_idempotent(sourcemeta::core::URITemplateRouter::Identifier context) noexcept
    -> bool;

[[nodiscard]] auto
is_open_world(sourcemeta::core::URITemplateRouter::Identifier context) noexcept
    -> bool;

} // namespace sourcemeta::one

#endif
