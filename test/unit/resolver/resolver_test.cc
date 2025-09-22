#include <gtest/gtest.h>

#include <algorithm>
#include <cctype>
#include <vector>

#include <sourcemeta/registry/configuration.h>
#include <sourcemeta/registry/resolver.h>

static auto to_lowercase(const std::string_view input) -> std::string {
  std::string result{input};
  std::ranges::transform(result, result.begin(), [](const auto character) {
    return static_cast<char>(std::tolower(character));
  });
  return result;
}

#define RESOLVER_INIT(name)                                                    \
  sourcemeta::registry::Resolver name;                                         \
  const auto raw_configuration{sourcemeta::registry::Configuration::read(      \
      CONFIGURATION_PATH,                                                      \
      std::filesystem::path{CONFIGURATION_PATH}.parent_path() /                \
          "collections")};                                                     \
  const auto configuration{                                                    \
      sourcemeta::registry::Configuration::parse(raw_configuration)};

#define RESOLVER_EXPECT(resolver, expected_uri, expected_schema)               \
  {                                                                            \
    const auto schema{(resolver)(expected_uri)};                               \
    EXPECT_TRUE(schema.has_value());                                           \
    EXPECT_EQ(schema.value(), sourcemeta::core::parse_json(expected_schema));  \
  }

#define RESOLVER_IMPORT(resolver, collection_name, relative_path)              \
  (resolver).add(configuration.url, collection_name,                           \
                 std::get<sourcemeta::registry::Configuration::Collection>(    \
                     configuration.entries.at(collection_name)),               \
                 std::filesystem::path{SCHEMAS_PATH} / collection_name /       \
                     (relative_path))

#define RESOLVER_ADD(resolver, collection_name, relative_path,                 \
                     expected_current_uri, expected_final_uri,                 \
                     expected_schema)                                          \
  {                                                                            \
    const auto result{                                                         \
        RESOLVER_IMPORT(resolver, (collection_name), (relative_path))};        \
    EXPECT_EQ(result.first.get(), (expected_current_uri));                     \
    EXPECT_EQ(result.second.get(), (expected_final_uri));                      \
    RESOLVER_EXPECT(resolver, (result.second.get()), (expected_schema));       \
  }

TEST(Resolver, idempotent) {
  RESOLVER_INIT(resolver);

  RESOLVER_ADD(resolver, "example", "2020-12-with-id.json",
               "https://example.com/schemas/2020-12-with-id",
               "http://localhost:8000/example/2020-12-with-id",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id"
  })JSON");

  RESOLVER_ADD(resolver, "example", "2020-12-with-id.json",
               "https://example.com/schemas/2020-12-with-id",
               "http://localhost:8000/example/2020-12-with-id",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id"
  })JSON");

  RESOLVER_ADD(resolver, "example", "2020-12-with-id.json",
               "https://example.com/schemas/2020-12-with-id",
               "http://localhost:8000/example/2020-12-with-id",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id"
  })JSON");
}

TEST(Resolver, iterators) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-with-id.json",
               "https://example.com/schemas/2020-12-with-id",
               "http://localhost:8000/example/2020-12-with-id",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id"
  })JSON");

  std::vector<std::string> identifiers;
  for (const auto &entry : resolver) {
    identifiers.push_back(entry.first);
  }

  EXPECT_EQ(identifiers.size(), 1);
  EXPECT_EQ(identifiers.at(0), "http://localhost:8000/example/2020-12-with-id");
}

TEST(Resolver, duplicate_id) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-with-id-json.json",
               "https://example.com/schemas/2020-12-with-id-json",
               "http://localhost:8000/example/2020-12-with-id-json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id-json"
  })JSON");

  EXPECT_THROW(RESOLVER_IMPORT(resolver, "example",
                               "2020-12-with-id-json-duplicate.json"),
               sourcemeta::core::SchemaError);
}

TEST(Resolver, case_insensitive_lookup) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-with-id.json",
               "https://example.com/schemas/2020-12-with-id",
               "http://localhost:8000/example/2020-12-with-id",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id"
  })JSON");

  RESOLVER_EXPECT(resolver, "http://localhost:8000/example/2020-12-with-id",
                  R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id"
  })JSON");

  RESOLVER_EXPECT(resolver, "HTTP://LOCALHOST:8000/EXAMPLE/2020-12-WITH-ID",
                  R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id"
  })JSON");

  RESOLVER_EXPECT(resolver, "hTtP://lOcaLhOST:8000/Example/2020-12-WIth-id",
                  R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id"
  })JSON");
}

TEST(Resolver, example_official_2020_12_meta) {
  RESOLVER_INIT(resolver);
  EXPECT_TRUE(
      resolver("https://json-schema.org/draft/2020-12/schema").has_value());
  EXPECT_EQ(resolver("https://json-schema.org/draft/2020-12/schema"),
            sourcemeta::core::schema_official_resolver(
                "https://json-schema.org/draft/2020-12/schema"));
}

TEST(Resolver, example_2020_12_with_id) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-with-id.json",
               "https://example.com/schemas/2020-12-with-id",
               "http://localhost:8000/example/2020-12-with-id",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id"
  })JSON");
}

TEST(Resolver, example_2020_12_with_id_json) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-with-id-json.json",
               "https://example.com/schemas/2020-12-with-id-json",
               "http://localhost:8000/example/2020-12-with-id-json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id-json"
  })JSON");
}

TEST(Resolver, example_2020_12_with_id_schema_json) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-with-id.schema.json",
               "https://example.com/schemas/2020-12-with-id",
               "http://localhost:8000/example/2020-12-with-id",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id"
  })JSON");
}

TEST(Resolver, example_2020_12_without_id_schema_json) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-without-id.schema.json",
               "https://example.com/schemas/2020-12-without-id",
               "http://localhost:8000/example/2020-12-without-id",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-without-id"
  })JSON");
}

TEST(Resolver, example_2020_12_schema_extension) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-schema-extension.json",
               "https://example.com/schemas/schema-extension",
               "http://localhost:8000/example/schema-extension",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/schema-extension"
  })JSON");
}

TEST(Resolver, example_2020_12_yaml_extension) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-yaml-extension.json",
               "https://example.com/schemas/yaml-extension",
               "http://localhost:8000/example/yaml-extension",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/yaml-extension"
  })JSON");
}

TEST(Resolver, example_2020_12_yml_extension) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-yml-extension.json",
               "https://example.com/schemas/yml-extension",
               "http://localhost:8000/example/yml-extension",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/yml-extension"
  })JSON");
}

TEST(Resolver, example_2020_12_schema_yaml_extension) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-schema-yaml-extension.json",
               "https://example.com/schemas/schema-yaml-extension",
               "http://localhost:8000/example/schema-yaml-extension",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/schema-yaml-extension"
  })JSON");
}

TEST(Resolver, example_2020_12_schema_yml_extension) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-schema-yml-extension.json",
               "https://example.com/schemas/schema-yml-extension",
               "http://localhost:8000/example/schema-yml-extension",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/schema-yml-extension"
  })JSON");
}

TEST(Resolver, example_2020_12_yaml_json_mix_extension) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-yaml-json-mix-extension.json",
               "https://example.com/schemas/yaml-json-mix-extension",
               "http://localhost:8000/example/yaml-json-mix-extension",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/yaml-json-mix-extension"
  })JSON");
}

TEST(Resolver, example_2020_12_semver) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-semver.json",
               "https://example.com/schemas/semver/v1.2.3",
               "http://localhost:8000/example/semver/v1.2.3",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/semver/v1.2.3"
  })JSON");
}

TEST(Resolver, example_2020_12_pointer_ref_casing_relative) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(
      resolver, "example", "2020-12-pointer-ref-casing-relative.json",
      "https://example.com/schemas/2020-12-pointer-ref-casing-relative",
      "http://localhost:8000/example/2020-12-pointer-ref-casing-relative",
      R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-pointer-ref-casing-relative",
    "$ref": "relative#/$defs/fooBar",
    "$defs": {
      "relative": {
        "$id": "relative",
        "$defs": { "fooBar": { "type": "string" } }
      }
    }
  })JSON");
}

TEST(Resolver, example_only_id) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "only-id.json",
               "https://example.com/schemas/only-id",
               "http://localhost:8000/example/only-id",
               R"JSON({
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "http://localhost:8000/example/only-id"
  })JSON");
}

TEST(Resolver, example_2020_12_anonymous) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-anonymous.json",
               "https://example.com/schemas/2020-12-anonymous",
               "http://localhost:8000/example/2020-12-anonymous",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-anonymous"
  })JSON");
}

TEST(Resolver, example_2020_12_embedded_resource) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-embedded-resource.json",
               "https://example.com/schemas/2020-12-embedded-resource",
               "http://localhost:8000/example/2020-12-embedded-resource",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-embedded-resource",
    "$defs": {
      "string": {
        "$id": "string",
        "type": "string"
      }
    }
  })JSON");

  // The resolver does not expose embedded resources
  EXPECT_FALSE(resolver("http://localhost:8000/example/string").has_value());
  EXPECT_FALSE(
      resolver("http://localhost:8000/example/string.json").has_value());
}

TEST(Resolver, example_2020_12_absolute_ref) {
  RESOLVER_INIT(resolver);

  // We expect absolute references to be made relative
  RESOLVER_ADD(resolver, "example", "2020-12-absolute-ref.json",
               "https://example.com/schemas/2020-12-absolute-ref",
               "http://localhost:8000/example/2020-12-absolute-ref",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-absolute-ref",
    "$ref": "2020-12-id"
  })JSON");
}

TEST(Resolver, example_2020_12_relative_id) {
  RESOLVER_INIT(resolver);

  RESOLVER_ADD(resolver, "example", "2020-12-relative-id.json",
               "https://example.com/schemas/2020-12-relative-id",
               "http://localhost:8000/example/2020-12-relative-id",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-relative-id"
  })JSON");
}

TEST(Resolver, example_2020_12_ref_with_casing) {
  RESOLVER_INIT(resolver);

  RESOLVER_ADD(resolver, "example", "2020-12-ref-with-casing.json",
               "https://example.com/schemas/2020-12-ref-with-casing",
               "http://localhost:8000/example/2020-12-ref-with-casing",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-ref-with-casing",
    "$ref": "2020-12-id"
  })JSON");
}

TEST(Resolver, example_2020_12_id_with_casing) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-id-with-casing.json",
               "https://example.com/schemas/2020-12-id-with-casing",
               "http://localhost:8000/example/2020-12-id-with-casing",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-id-with-casing"
  })JSON");

  RESOLVER_EXPECT(resolver,
                  "http://localhost:8000/example/2020-12-iD-WiTh-cASIng",
                  R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-id-with-casing"
  })JSON");

  RESOLVER_EXPECT(resolver,
                  "HTTP://LOCALHOST:8000/EXAMPLE/2020-12-ID-WITH-CASING",
                  R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-id-with-casing"
  })JSON");
}

TEST(Resolver, example_2020_12_ref_needs_rebase) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-ref-needs-rebase.json",
               "https://example.com/schemas/2020-12-ref-needs-rebase",
               "http://localhost:8000/example/2020-12-ref-needs-rebase",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-ref-needs-rebase",
    "$ref": "/example/2020-12-with-id"
  })JSON");
}

TEST(Resolver, example_2020_12_meta) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-meta.json",
               "https://example.com/schemas/2020-12-meta",
               "http://localhost:8000/example/2020-12-meta",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-meta",
    "$vocabulary": {
      "https://json-schema.org/draft/2020-12/vocab/core": true
    }
  })JSON");
}

TEST(Resolver, example_2020_12_circular) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-circular.json",
               "https://example.com/schemas/2020-12-circular",
               "http://localhost:8000/example/2020-12-circular",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-circular",
    "$ref": "#"
  })JSON");
}

TEST(Resolver, example_2020_12_meta_schema) {
  RESOLVER_INIT(resolver);
  const auto schema_result{
      RESOLVER_IMPORT(resolver, "example", "2020-12-meta-schema.json")};

  // We can't resolve it yet until we first satisfy the metaschema
  EXPECT_THROW(resolver(schema_result.second.get()),
               sourcemeta::core::SchemaResolutionError);

  // Note we add the metaschema AFTER the schema
  RESOLVER_IMPORT(resolver, "example", "2020-12-meta.json");

  RESOLVER_EXPECT(resolver, schema_result.second.get(), R"JSON({
    "$schema": "http://localhost:8000/example/2020-12-meta",
    "$id": "http://localhost:8000/example/2020-12-meta-schema"
  })JSON");
}

TEST(Resolver, example_2020_12_base_with_trailing_slash) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-base-with-trailing-slash.json",
               "https://example.com/schemas/2020-12-base-with-trailing-slash",
               "http://localhost:8000/example/2020-12-base-with-trailing-slash",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-base-with-trailing-slash"
  })JSON");
}

TEST(Resolver, base_slash_2020_12_equal_to_base) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "base-slash", "2020-12-equal-to-base.json",
               "https://example.com/slash/2020-12-equal-to-base",
               "http://localhost:8000/base-slash/2020-12-equal-to-base",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/base-slash/2020-12-equal-to-base"
  })JSON");
}

TEST(Resolver, example_2019_09_recursive_ref) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2019-09-recursive-ref.json",
               "https://example.com/schemas/2019-09-recursive-ref",
               "http://localhost:8000/example/2019-09-recursive-ref",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2019-09/schema",
    "$id": "http://localhost:8000/example/2019-09-recursive-ref",
    "$recursiveAnchor": true,
    "additionalProperties": {
      "$recursiveRef": "#"
    }
  })JSON");
}

TEST(Resolver, example_draft4_internal_ref) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "draft4-internal-ref.json",
               "https://example.com/schemas/draft4-internal-ref",
               "http://localhost:8000/example/draft4-internal-ref",
               R"JSON({
    "$schema": "http://json-schema.org/draft-04/schema#",
    "id": "http://localhost:8000/example/draft4-internal-ref",
    "allOf": [ { "$ref": "#/definitions/foo" } ],
    "definitions": {
      "foo": {
        "type": "string"
      }
    }
  })JSON");
}

TEST(Resolver, example_draft4_trailing_hash_with_ref) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "draft4-trailing-hash-with-ref.json",
               "https://example.com/schemas/draft4-trailing-hash-with-ref",
               "http://localhost:8000/example/draft4-trailing-hash-with-ref",
               R"JSON({
    "$schema": "http://json-schema.org/draft-04/schema#",
    "id": "http://localhost:8000/example/draft4-trailing-hash-with-ref",
    "properties": {
      "foo": { "$ref": "#/properties/bar" },
      "bar": {}
    }
  })JSON");
}

TEST(Resolver, meta_draft4_override) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "meta-draft4", "draft4-override.json",
               "http://json-schema.org/draft-04/schema",
               "http://localhost:8000/meta-draft4/schema",
               R"JSON({
    "$schema": "http://json-schema.org/draft-04/schema#",
    "id": "http://localhost:8000/meta-draft4/schema"
  })JSON");
}

TEST(Resolver, no_base_anonymous) {
  RESOLVER_INIT(resolver);
  const auto schemas_path{
      std::filesystem::path{to_lowercase(CONFIGURATION_PATH)}.parent_path() /
      "schemas"};

  RESOLVER_ADD(
      resolver, "no-base", "anonymous.json",
      sourcemeta::core::URI::from_path(schemas_path / "no-base" / "anonymous")
          .recompose(),
      "http://localhost:8000/no-base/anonymous",
      R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/no-base/anonymous"
  })JSON");
}
