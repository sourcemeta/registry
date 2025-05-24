#include <gtest/gtest.h>

#include <sourcemeta/registry/generator.h>

TEST(Generator_Resolver, single_schema_anonymous_with_default_id) {
  sourcemeta::registry::Configuration configuration{
      CONFIGURATION_PATH,
      sourcemeta::core::read_json(CONFIGURATION_SCHEMA_PATH)};
  sourcemeta::registry::Collection collection{
      configuration.base(), "example",
      configuration.get().at("schemas").at("example")};
  sourcemeta::registry::Resolver resolver;

  const auto schema_path{std::filesystem::path{SCHEMAS_PATH} /
                         "2020-12-anonymous.json"};
  const auto result{resolver.add(configuration, collection, schema_path)};
  EXPECT_EQ(result.first, "https://example.com/schemas/2020-12-anonymous.json");
  EXPECT_EQ(result.second,
            "http://localhost:8000/example/2020-12-anonymous.json");

  const auto schema{resolver(result.second)};
  EXPECT_TRUE(schema.has_value());
  EXPECT_EQ(schema.value(), sourcemeta::core::parse_json(R"JSON({
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "http://localhost:8000/example/2020-12-anonymous.json"
  })JSON"));
}
