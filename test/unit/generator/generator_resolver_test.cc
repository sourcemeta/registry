#include <gtest/gtest.h>

#include <sourcemeta/registry/generator.h>

#define RESOLVER_INIT(name)                                                    \
  sourcemeta::registry::Resolver(name);                                        \
  sourcemeta::registry::Configuration configuration{                           \
      CONFIGURATION_PATH,                                                      \
      sourcemeta::core::read_json(CONFIGURATION_SCHEMA_PATH)};

#define RESOLVER_ADD(resolver, collection_name, relative_path,                 \
                     expected_current_uri, expected_final_uri,                 \
                     expected_schema)                                          \
  {                                                                            \
    const sourcemeta::registry::Collection collection{                         \
        configuration.base(), (collection_name),                               \
        configuration.get().at("schemas").at(collection_name)};                \
    const auto result{(resolver).add(configuration, collection,                \
                                     std::filesystem::path{SCHEMAS_PATH} /     \
                                         (relative_path))};                    \
    EXPECT_EQ(result.first, (expected_current_uri));                           \
    EXPECT_EQ(result.second, (expected_final_uri));                            \
    const auto schema{(resolver)(result.second)};                              \
    EXPECT_TRUE(schema.has_value());                                           \
    EXPECT_EQ(schema.value(), sourcemeta::core::parse_json(expected_schema));  \
  }

TEST(Generator_Resolver, single_schema_anonymous_with_default_id) {
  RESOLVER_INIT(resolver);
  RESOLVER_ADD(resolver, "example", "2020-12-anonymous.json",
               "https://example.com/schemas/2020-12-anonymous.json",
               "http://localhost:8000/example/2020-12-anonymous.json",
               R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-anonymous.json"
  })JSON");
}
