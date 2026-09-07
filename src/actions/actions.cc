#include <sourcemeta/one/actions.h>

#include <cassert>     // assert
#include <string_view> // std::string_view

#include "action_auth_callback_v1.h"
#include "action_auth_login_page_v1.h"
#include "action_auth_login_v1.h"
#include "action_auth_logout_v1.h"
#include "action_default_v1.h"
#include "action_dependency_tree_v1.h"
#include "action_get_schema_dependencies_v1.h"
#include "action_get_schema_dependents_v1.h"
#include "action_get_schema_health_v1.h"
#include "action_get_schema_locations_v1.h"
#include "action_get_schema_metadata_v1.h"
#include "action_get_schema_positions_v1.h"
#include "action_get_schema_stats_v1.h"
#include "action_health_check_v1.h"
#include "action_jsonschema_evaluate_v1.h"
#include "action_jsonschema_rdf_v1.h"
#include "action_jsonschema_trace_inline_v1.h"
#include "action_jsonschema_trace_v1.h"
#include "action_list_directory_v1.h"
#include "action_mcp_prm_v1.h"
#include "action_mcp_v1.h"
#include "action_metrics_v1.h"
#include "action_not_found_v1.h"
#include "action_schema_search_v1.h"
#include "action_serve_explorer_artifact_v1.h"
#include "action_serve_schema_artifact_v1.h"
#include "action_serve_static_v1.h"

namespace {

struct ActionMetadata {
  std::string_view description;
  bool read_only;
  bool destructive;
  bool idempotent;
  bool open_world;
};

#define SOURCEMETA_ONE_DEFINE_METADATA(Name, Class, Label)                     \
  ActionMetadata{Class::DESCRIPTION, Class::READ_ONLY, Class::DESTRUCTIVE,     \
                 Class::IDEMPOTENT, Class::OPEN_WORLD},

const std::array<ActionMetadata, sourcemeta::one::ACTION_TYPE_COUNT> METADATA{
    {SOURCEMETA_ONE_FOR_EACH_ACTION(SOURCEMETA_ONE_DEFINE_METADATA)}};

#undef SOURCEMETA_ONE_DEFINE_METADATA

} // namespace

namespace sourcemeta::one {

#define SOURCEMETA_ONE_MAKE_CONSTRUCTOR_ENTRY(Name, Class, Label)              \
  table[ACTION_TYPE_##Name] = &make_router_action<Class>;

const std::array<RouterActionConstructor, ACTION_TYPE_COUNT> CONSTRUCTORS{
    []() noexcept -> std::array<RouterActionConstructor, ACTION_TYPE_COUNT> {
      std::array<RouterActionConstructor, ACTION_TYPE_COUNT> table{};
      SOURCEMETA_ONE_FOR_EACH_ACTION(SOURCEMETA_ONE_MAKE_CONSTRUCTOR_ENTRY)
      return table;
    }()};

#undef SOURCEMETA_ONE_MAKE_CONSTRUCTOR_ENTRY

auto action_description(
    const sourcemeta::core::URITemplateRouter::Identifier context) noexcept
    -> std::string_view {
  if (context >= METADATA.size()) {
    return {};
  }
  return METADATA[context].description;
}

auto is_read_only(
    const sourcemeta::core::URITemplateRouter::Identifier context) noexcept
    -> bool {
  assert(context < METADATA.size());
  return METADATA[context].read_only;
}

auto is_destructive(
    const sourcemeta::core::URITemplateRouter::Identifier context) noexcept
    -> bool {
  assert(context < METADATA.size());
  return METADATA[context].destructive;
}

auto is_idempotent(
    const sourcemeta::core::URITemplateRouter::Identifier context) noexcept
    -> bool {
  assert(context < METADATA.size());
  return METADATA[context].idempotent;
}

auto is_open_world(
    const sourcemeta::core::URITemplateRouter::Identifier context) noexcept
    -> bool {
  assert(context < METADATA.size());
  return METADATA[context].open_world;
}

} // namespace sourcemeta::one
