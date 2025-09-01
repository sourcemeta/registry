#include <gtest/gtest.h>

#include <sourcemeta/registry/configuration.h>

auto replace_all(std::string &text, const std::string &from,
                 const std::string &to) -> void {
  assert(!from.empty());
  std::size_t cursor{0};
  while ((cursor = text.find(from, cursor)) != std::string::npos) {
    text.replace(cursor, from.length(), to);
    cursor += to.length();
  }
}

TEST(Configuration_read, stub_2) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "stub_2.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "owner": "Sourcemeta",
    "description": "The next-generation JSON Schema Registry",
    "url": "http://localhost:8000",
    "port": 8000,
    "contents": {
      "example": {
        "title": "Nested",
        "contents": {
          "nested": {
            "baseUri": "https://example.com/extension",
            "path": "STUB_DIRECTORY/folder/schemas/example/extension",
            "defaultDialect": "http://json-schema.org/draft-07/schema#"
          }
        }
      }
    }
  })JSON"};

  replace_all(text, "STUB_DIRECTORY", STUB_DIRECTORY);
  const auto expected{sourcemeta::core::parse_json(text)};
  EXPECT_EQ(raw_configuration, expected);
}

TEST(Configuration_read, stub_3) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "stub_3.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "owner": "Sourcemeta",
    "description": "The next-generation JSON Schema Registry",
    "url": "http://localhost:8000",
    "port": 8000,
    "contents": {
      "example": {
        "title": "Nested without file name",
        "contents": {
          "nested": {
            "baseUri": "https://example.com/extension",
            "path": "STUB_DIRECTORY/folder/schemas/example/extension",
            "defaultDialect": "http://json-schema.org/draft-07/schema#"
          }
        }
      }
    }
  })JSON"};

  replace_all(text, "STUB_DIRECTORY", STUB_DIRECTORY);
  const auto expected{sourcemeta::core::parse_json(text)};
  EXPECT_EQ(raw_configuration, expected);
}

TEST(Configuration_read, stub_4) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "stub_4.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "owner": "Sourcemeta",
    "description": "The next-generation JSON Schema Registry",
    "url": "http://localhost:8000",
    "port": 8000,
    "contents": {
      "other": {
        "title": "Other"
      },
      "example": {
        "title": "Nested",
        "contents": {
          "nested": {
            "baseUri": "https://example.com/extension",
            "path": "STUB_DIRECTORY/folder/schemas/example/extension",
            "defaultDialect": "http://json-schema.org/draft-07/schema#"
          }
        }
      }
    }
  })JSON"};

  replace_all(text, "STUB_DIRECTORY", STUB_DIRECTORY);
  const auto expected{sourcemeta::core::parse_json(text)};
  EXPECT_EQ(raw_configuration, expected);
}

TEST(Configuration_read, stub_5) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "stub_5.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "owner": "Sourcemeta",
    "description": "The next-generation JSON Schema Registry",
    "url": "http://localhost:8000",
    "port": 8000,
    "contents": {
      "other": {
        "title": "Other"
      },
      "example": {
        "title": "Nested",
        "contents": {
          "nested": {
            "baseUri": "https://example.com/extension",
            "path": "STUB_DIRECTORY/folder/schemas/example/extension",
            "defaultDialect": "http://json-schema.org/draft-07/schema#"
          }
        }
      }
    }
  })JSON"};

  replace_all(text, "STUB_DIRECTORY", STUB_DIRECTORY);
  const auto expected{sourcemeta::core::parse_json(text)};
  EXPECT_EQ(raw_configuration, expected);
}

TEST(Configuration_read, stub_6) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "stub_6.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "owner": "Sourcemeta",
    "description": "The next-generation JSON Schema Registry",
    "url": "http://localhost:8000",
    "port": 8000,
    "contents": {
      "here": {
        "contents": {
          "test": {
            "title": "Imported utility"
          }
        }
      }
    }
  })JSON"};

  replace_all(text, "STUB_DIRECTORY", STUB_DIRECTORY);
  const auto expected{sourcemeta::core::parse_json(text)};
  EXPECT_EQ(raw_configuration, expected);
}

TEST(Configuration_read, stub_7) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "stub_7.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "owner": "Sourcemeta",
    "description": "The next-generation JSON Schema Registry",
    "url": "http://localhost:8000",
    "port": 8000,
    "contents": {
      "here": {
        "title": "With standard name"
      }
    }
  })JSON"};

  replace_all(text, "STUB_DIRECTORY", STUB_DIRECTORY);
  const auto expected{sourcemeta::core::parse_json(text)};
  EXPECT_EQ(raw_configuration, expected);
}
