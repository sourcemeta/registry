#include <gtest/gtest.h>

#include <vector>

#include <sourcemeta/registry/configuration.h>
#include <sourcemeta/registry/resolver.h>

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
    EXPECT_EQ(result.first, (expected_current_uri));                           \
    EXPECT_EQ(result.second, (expected_final_uri));                            \
    RESOLVER_EXPECT(resolver, (result.second), (expected_schema));             \
  }

TEST(Resolver, idempotent) {
  RESOLVER_INIT(resolver);

  RESOLVER_ADD(resolver, "example", "2020-12-with-id.json",
               "https://example.com/schemas/2020-12-with-id",
               "http://localhost:8000/example/2020-12-with-id.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id.json"
  })JSON");

  RESOLVER_ADD(resolver, "example", "2020-12-with-id.json",
               "https://example.com/schemas/2020-12-with-id",
               "http://localhost:8000/example/2020-12-with-id.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id.json"
  })JSON");

  RESOLVER_ADD(resolver, "example", "2020-12-with-id.json",
               "https://example.com/schemas/2020-12-with-id",
               "http://localhost:8000/example/2020-12-with-id.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id.json"
  })JSON");
}

TEST(Resolver, iterators) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-with-id.json",
               "https://example.com/schemas/2020-12-with-id",
               "http://localhost:8000/example/2020-12-with-id.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id.json"
  })JSON");

  std::vector<std::string> identifiers;
  for (const auto &entry : resolver) {
    identifiers.push_back(entry.first);
  }

  EXPECT_EQ(identifiers.size(), 1);
  EXPECT_EQ(identifiers.at(0),
            "http://localhost:8000/example/2020-12-with-id.json");
}

TEST(Resolver, duplicate_id) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-with-id-json.json",
               "https://example.com/schemas/2020-12-with-id-json.json",
               "http://localhost:8000/example/2020-12-with-id-json.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id-json.json"
  })JSON");

  EXPECT_THROW(RESOLVER_IMPORT(resolver, "example",
                               "2020-12-with-id-json-duplicate.json"),
               sourcemeta::core::SchemaError);
}

TEST(Resolver, case_insensitive_lookup) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-with-id.json",
               "https://example.com/schemas/2020-12-with-id",
               "http://localhost:8000/example/2020-12-with-id.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id.json"
  })JSON");

  RESOLVER_EXPECT(resolver,
                  "http://localhost:8000/example/2020-12-with-id.json", R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id.json"
  })JSON");

  RESOLVER_EXPECT(resolver,
                  "HTTP://LOCALHOST:8000/EXAMPLE/2020-12-WITH-ID.JSON", R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id.json"
  })JSON");

  RESOLVER_EXPECT(resolver,
                  "hTtP://lOcaLhOST:8000/Example/2020-12-WIth-id.jsoN", R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id.json"
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
               "http://localhost:8000/example/2020-12-with-id.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id.json"
  })JSON");
}

TEST(Resolver, example_2020_12_with_id_json) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-with-id-json.json",
               "https://example.com/schemas/2020-12-with-id-json.json",
               "http://localhost:8000/example/2020-12-with-id-json.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-with-id-json.json"
  })JSON");
}

TEST(Resolver, example_only_id) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "only-id.json",
               "https://example.com/schemas/only-id.json",
               "http://localhost:8000/example/only-id.json",
               R"JSON({
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "http://localhost:8000/example/only-id.json"
  })JSON");
}

TEST(Resolver, example_2020_12_anonymous) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-anonymous.json",
               "https://example.com/schemas/2020-12-anonymous.json",
               "http://localhost:8000/example/2020-12-anonymous.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-anonymous.json"
  })JSON");
}

TEST(Resolver, example_2020_12_embedded_resource) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-embedded-resource.json",
               "https://example.com/schemas/2020-12-embedded-resource.json",
               "http://localhost:8000/example/2020-12-embedded-resource.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-embedded-resource.json",
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
               "https://example.com/schemas/2020-12-absolute-ref.json",
               "http://localhost:8000/example/2020-12-absolute-ref.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-absolute-ref.json",
    "$ref": "2020-12-id.json"
  })JSON");
}

TEST(Resolver, example_2020_12_ref_with_casing) {
  RESOLVER_INIT(resolver);

  RESOLVER_ADD(resolver, "example", "2020-12-ref-with-casing.json",
               "https://example.com/schemas/2020-12-ref-with-casing.json",
               "http://localhost:8000/example/2020-12-ref-with-casing.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-ref-with-casing.json",
    "$ref": "2020-12-id.json"
  })JSON");
}

TEST(Resolver, example_2020_12_id_with_casing) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-id-with-casing.json",
               "https://example.com/schemas/2020-12-id-with-casing.json",
               "http://localhost:8000/example/2020-12-id-with-casing.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-id-with-casing.json"
  })JSON");

  RESOLVER_EXPECT(resolver,
                  "http://localhost:8000/example/2020-12-iD-WiTh-cASIng.Json",
                  R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-id-with-casing.json"
  })JSON");

  RESOLVER_EXPECT(resolver,
                  "HTTP://LOCALHOST:8000/EXAMPLE/2020-12-ID-WITH-CASING.JSON",
                  R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-id-with-casing.json"
  })JSON");
}

TEST(Resolver, example_2020_12_ref_needs_rebase) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-ref-needs-rebase.json",
               "https://example.com/schemas/2020-12-ref-needs-rebase.json",
               "http://localhost:8000/example/2020-12-ref-needs-rebase.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-ref-needs-rebase.json",
    "$ref": "/example/2020-12-with-id"
  })JSON");
}

TEST(Resolver, example_2020_12_meta) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-meta.json",
               "https://example.com/schemas/2020-12-meta.json",
               "http://localhost:8000/example/2020-12-meta.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-meta.json",
    "$vocabulary": { 
      "https://json-schema.org/draft/2020-12/vocab/core": true 
    }
  })JSON");
}

TEST(Resolver, example_2020_12_meta_schema) {
  RESOLVER_INIT(resolver);
  const auto schema_result{
      RESOLVER_IMPORT(resolver, "example", "2020-12-meta-schema.json")};

  // We can't resolve it yet until we first satisfy the metaschema
  EXPECT_THROW(resolver(schema_result.second),
               sourcemeta::core::SchemaResolutionError);

  // Note we add the metaschema AFTER the schema
  RESOLVER_IMPORT(resolver, "example", "2020-12-meta.json");

  RESOLVER_EXPECT(resolver, schema_result.second, R"JSON({
    "$schema": "http://localhost:8000/example/2020-12-meta.json",
    "$id": "http://localhost:8000/example/2020-12-meta-schema.json"
  })JSON");
}

TEST(Resolver, example_2019_09_recursive_ref) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2019-09-recursive-ref.json",
               "https://example.com/schemas/2019-09-recursive-ref.json",
               "http://localhost:8000/example/2019-09-recursive-ref.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2019-09/schema",
    "$id": "http://localhost:8000/example/2019-09-recursive-ref.json",
    "$recursiveAnchor": true,
    "additionalProperties": {
      "$recursiveRef": "#"
    }
  })JSON");
}

TEST(Resolver, example_draft4_internal_ref) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "draft4-internal-ref.json",
               "https://example.com/schemas/draft4-internal-ref.json",
               "http://localhost:8000/example/draft4-internal-ref.json",
               R"JSON({
    "$schema": "http://json-schema.org/draft-04/schema#",
    "id": "http://localhost:8000/example/draft4-internal-ref.json",
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
  RESOLVER_ADD(
      resolver, "example", "draft4-trailing-hash-with-ref.json",
      "https://example.com/schemas/draft4-trailing-hash-with-ref.json",
      "http://localhost:8000/example/draft4-trailing-hash-with-ref.json",
      R"JSON({
    "$schema": "http://json-schema.org/draft-04/schema#",
    "id": "http://localhost:8000/example/draft4-trailing-hash-with-ref.json",
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
               "http://localhost:8000/meta-draft4/schema.json",
               R"JSON({
    "$schema": "http://json-schema.org/draft-04/schema#",
    "id": "http://localhost:8000/meta-draft4/schema.json"
  })JSON");
}
