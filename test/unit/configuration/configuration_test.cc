#include <gtest/gtest.h>

#include <sourcemeta/registry/configuration.h>

#define EXPECT_PAGE(configuration, path, property, value)                      \
  EXPECT_TRUE((configuration).entries.contains(path));                         \
  EXPECT_TRUE(                                                                 \
      std::holds_alternative<sourcemeta::registry::Configuration::Page>(       \
          (configuration).entries.at(path)));                                  \
  EXPECT_EQ(std::get<sourcemeta::registry::Configuration::Page>(               \
                (configuration).entries.at(path))                              \
                .property,                                                     \
            value);

#define EXPECT_COLLECTION(configuration, path, property, value)                \
  EXPECT_TRUE((configuration).entries.contains(path));                         \
  EXPECT_TRUE(                                                                 \
      std::holds_alternative<sourcemeta::registry::Configuration::Collection>( \
          (configuration).entries.at(path)));                                  \
  EXPECT_EQ(std::get<sourcemeta::registry::Configuration::Collection>(         \
                (configuration).entries.at(path))                              \
                .property,                                                     \
            value);

TEST(Configuration, stub_1) {
  const auto configuration_path{std::filesystem::path{TEST_DIRECTORY} /
                                "stub_1.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};
  const auto configuration{sourcemeta::registry::Configuration::parse(
      configuration_path, raw_configuration)};

  EXPECT_EQ(configuration.url, "http://localhost:8000");
  EXPECT_EQ(configuration.title, "Title");
  EXPECT_EQ(configuration.description, "Description");
  EXPECT_EQ(configuration.port, 8000);
  EXPECT_FALSE(configuration.head.has_value());
  EXPECT_FALSE(configuration.hero.has_value());
  EXPECT_FALSE(configuration.action.has_value());

  EXPECT_EQ(configuration.entries.size(), 3);

  EXPECT_PAGE(configuration, "example", title, "Sourcemeta");
  EXPECT_PAGE(configuration, "example", description, "My description");
  EXPECT_PAGE(configuration, "example", email, "hello@sourcemeta.com");
  EXPECT_PAGE(configuration, "example", github, "sourcemeta");
  EXPECT_PAGE(configuration, "example", website, "https://www.sourcemeta.com");

  EXPECT_PAGE(configuration, "test", title, "A sample schema folder");
  EXPECT_PAGE(configuration, "test", description, "For testing purposes");
  EXPECT_PAGE(configuration, "test", email, std::nullopt);
  EXPECT_PAGE(configuration, "test", github, "sourcemeta/registry");
  EXPECT_PAGE(configuration, "test", website, std::nullopt);

  EXPECT_COLLECTION(configuration, "example/extension", title, "Test");
  EXPECT_COLLECTION(configuration, "example/extension", description,
                    std::nullopt);
  EXPECT_COLLECTION(configuration, "example/extension", email, std::nullopt);
  EXPECT_COLLECTION(configuration, "example/extension", github, std::nullopt);
  EXPECT_COLLECTION(configuration, "example/extension", website, std::nullopt);
  EXPECT_COLLECTION(configuration, "example/extension", absolute_path,
                    std::filesystem::path{TEST_DIRECTORY} / "schemas" /
                        "example" / "extension");
  EXPECT_COLLECTION(configuration, "example/extension", default_dialect,
                    "http://json-schema.org/draft-07/schema#");
  EXPECT_COLLECTION(configuration, "example/extension", resolve.size(), 1);
  EXPECT_COLLECTION(configuration, "example/extension",
                    resolve.at("https://other.com/single.json"), "/foo.json");
  EXPECT_COLLECTION(configuration, "example/extension", attributes.size(), 0);
}
