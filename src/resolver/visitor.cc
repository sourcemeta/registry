#include <sourcemeta/registry/resolver_visitor.h>

#include <sourcemeta/core/jsonpointer.h>

namespace sourcemeta::registry {

auto reference_visit(sourcemeta::core::JSON &schema,
                     const sourcemeta::core::SchemaWalker &walker,
                     const sourcemeta::core::SchemaResolver &resolver,
                     const SchemaVisitorReference &callback,
                     const std::optional<std::string> &default_dialect,
                     const std::optional<std::string> &default_id) -> void {
  sourcemeta::core::SchemaFrame frame{
      sourcemeta::core::SchemaFrame::Mode::Locations};
  frame.analyse(schema, walker, resolver, default_dialect, default_id);
  for (const auto &entry : frame.locations()) {
    if (entry.second.type !=
            sourcemeta::core::SchemaFrame::LocationType::Resource &&
        entry.second.type !=
            sourcemeta::core::SchemaFrame::LocationType::Subschema) {
      continue;
    }

    auto &subschema{sourcemeta::core::get(schema, entry.second.pointer)};
    assert(sourcemeta::core::is_schema(subschema));
    if (!subschema.is_object()) {
      continue;
    }

    const sourcemeta::core::URI base{entry.second.base};
    // Assume the base is canonicalized already
    assert(sourcemeta::core::URI::canonicalize(entry.second.base) ==
           base.recompose());
    for (const auto &property : subschema.as_object()) {
      const auto walker_result{
          walker(property.first, frame.vocabularies(entry.second, resolver))};
      if (walker_result.type !=
              sourcemeta::core::SchemaKeywordType::Reference ||
          !property.second.is_string()) {
        continue;
      }

      assert(property.second.is_string());
      assert(walker_result.vocabulary.has_value());
      sourcemeta::core::URI reference{property.second.to_string()};
      callback(subschema, base, walker_result.vocabulary.value(),
               property.first, reference);
    }
  }
}

auto reference_visitor_relativize(
    sourcemeta::core::JSON &subschema, const sourcemeta::core::URI &base,
    const sourcemeta::core::JSON::String &vocabulary,
    const sourcemeta::core::JSON::String &keyword,
    sourcemeta::core::URI &reference) -> void {
  // In 2019-09, `$recursiveRef` can only be `#`, so there
  // is nothing else we can possibly do
  if (vocabulary == "https://json-schema.org/draft/2019-09/vocab/core" &&
      keyword == "$recursiveRef") {
    return;
  }

  reference.relative_to(base);
  reference.canonicalize();

  if (reference.is_relative()) {
    subschema.assign(keyword, sourcemeta::core::JSON{reference.recompose()});
  }
}

} // namespace sourcemeta::registry
