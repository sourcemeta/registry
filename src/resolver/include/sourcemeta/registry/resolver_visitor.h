#ifndef SOURCEMETA_REGISTRY_RESOLVER_VISITOR_H_
#define SOURCEMETA_REGISTRY_RESOLVER_VISITOR_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/uri.h>

#include <functional> // std::function
#include <optional>   // std::optional, std::nullopt
#include <string>     // std::string

namespace sourcemeta::registry {

using SchemaVisitorReference = std::function<void(
    sourcemeta::core::JSON &, const sourcemeta::core::URI &,
    const sourcemeta::core::JSON::String &,
    const sourcemeta::core::JSON::String &, sourcemeta::core::URI &)>;

auto reference_visit(
    sourcemeta::core::JSON &schema,
    const sourcemeta::core::SchemaWalker &walker,
    const sourcemeta::core::SchemaResolver &resolver,
    const SchemaVisitorReference &callback,
    const std::optional<std::string> &default_dialect = std::nullopt,
    const std::optional<std::string> &default_id = std::nullopt) -> void;

auto reference_visitor_relativize(
    sourcemeta::core::JSON &subschema, const sourcemeta::core::URI &base,
    const sourcemeta::core::JSON::String &vocabulary,
    const sourcemeta::core::JSON::String &keyword, sourcemeta::core::URI &value)
    -> void;

} // namespace sourcemeta::registry

#endif
