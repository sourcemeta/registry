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

TEST(Configuration_read, read_valid_001) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_valid_001.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "url": "http://localhost:8000",
    "html": {
      "name": "Title",
      "description": "Description"
    },
    "contents": {
      "example": {
        "title": "Sourcemeta",
        "description": "My description",
        "email": "hello@sourcemeta.com",
        "github": "sourcemeta",
        "website": "https://www.sourcemeta.com",
        "contents": {
          "extension": {
            "title": "Test",
            "baseUri": "https://example.com/extension",
            "path": "STUB_DIRECTORY/schemas/example/extension",
            "defaultDialect": "http://json-schema.org/draft-07/schema#",
            "resolve": {
              "https://other.com/single.json": "/foo.json"
            }
          }
        }
      },
      "test": {
        "title": "A sample schema folder",
        "description": "For testing purposes",
        "github": "sourcemeta/registry"
      }
    }
  })JSON"};

  replace_all(text, "STUB_DIRECTORY", STUB_DIRECTORY);
  const auto expected{sourcemeta::core::parse_json(text)};
  EXPECT_EQ(raw_configuration, expected);
}

TEST(Configuration_read, read_valid_002) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_valid_002.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "url": "http://localhost:8000",
    "html": {
      "name": "Sourcemeta",
      "description": "The next-generation JSON Schema Registry"
    },
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

TEST(Configuration_read, read_valid_003) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_valid_003.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "url": "http://localhost:8000",
    "html": {
      "name": "Sourcemeta",
      "description": "The next-generation JSON Schema Registry"
    },
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

TEST(Configuration_read, read_valid_004) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_valid_004.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "url": "http://localhost:8000",
    "html": {
      "name": "Sourcemeta",
      "description": "The next-generation JSON Schema Registry"
    },
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

TEST(Configuration_read, read_valid_005) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_valid_005.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "url": "http://localhost:8000",
    "html": {
      "name": "Sourcemeta",
      "description": "The next-generation JSON Schema Registry"
    },
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

TEST(Configuration_read, read_valid_006) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_valid_006.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "url": "http://localhost:8000",
    "html": {
      "name": "Sourcemeta",
      "description": "The next-generation JSON Schema Registry"
    },
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

TEST(Configuration_read, read_valid_007) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_valid_007.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "url": "http://localhost:8000",
    "html": {
      "name": "Sourcemeta",
      "description": "The next-generation JSON Schema Registry"
    },
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

TEST(Configuration_read, read_valid_008) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_valid_008.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "url": "http://localhost:8000",
    "html": false,
    "contents": {
      "test": {
        "title": "A sample schema folder",
        "description": "For testing purposes",
        "github": "sourcemeta/registry"
      }
    }
  })JSON"};

  replace_all(text, "STUB_DIRECTORY", STUB_DIRECTORY);
  const auto expected{sourcemeta::core::parse_json(text)};
  EXPECT_EQ(raw_configuration, expected);
}

TEST(Configuration_read, read_valid_009) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_valid_009.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "url": "http://localhost:8000",
    "html": {
      "name": "Sourcemeta",
      "description": "The next-generation JSON Schema Registry"
    },
    "contents": {
      "test": {
        "title": "A sample schema folder",
        "description": "For testing purposes",
        "github": "sourcemeta/registry"
      }
    }
  })JSON"};

  replace_all(text, "STUB_DIRECTORY", STUB_DIRECTORY);
  const auto expected{sourcemeta::core::parse_json(text)};
  EXPECT_EQ(raw_configuration, expected);
}

TEST(Configuration_read, read_valid_010) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_valid_010.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "url": "http://localhost:8000",
    "html": {
      "name": "Sourcemeta",
      "description": "The next-generation JSON Schema Registry"
    },
    "contents": {
      "test": {
        "title": "A sample schema folder",
        "description": "For testing purposes",
        "github": "sourcemeta/registry"
      }
    }
  })JSON"};

  replace_all(text, "STUB_DIRECTORY", STUB_DIRECTORY);
  const auto expected{sourcemeta::core::parse_json(text)};
  EXPECT_EQ(raw_configuration, expected);
}

TEST(Configuration_read, read_valid_011) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_valid_011.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "url": "http://localhost:8000",
    "html": false,
    "contents": {
      "test": {
        "title": "A sample schema folder",
        "description": "For testing purposes",
        "github": "sourcemeta/registry"
      }
    }
  })JSON"};

  replace_all(text, "STUB_DIRECTORY", STUB_DIRECTORY);
  const auto expected{sourcemeta::core::parse_json(text)};
  EXPECT_EQ(raw_configuration, expected);
}

TEST(Configuration_read, read_valid_012) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_valid_012.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "include": "./read_valid_001.json",
    "html": {
      "name": "Sourcemeta",
      "description": "The next-generation JSON Schema Registry"
    }
  })JSON"};

  replace_all(text, "STUB_DIRECTORY", STUB_DIRECTORY);
  const auto expected{sourcemeta::core::parse_json(text)};
  EXPECT_EQ(raw_configuration, expected);
}

TEST(Configuration_read, read_valid_013) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_valid_013.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "url": "http://localhost:8000",
    "html": {
      "name": "Title",
      "description": "Description"
    },
    "contents": {
      "example": {
        "title": "Test",
        "baseUri": "https://example.com/extension",
        "path": "STUB_DIRECTORY/schemas/example/extension",
        "defaultDialect": "http://json-schema.org/draft-07/schema#",
        "resolve": {
          "https://other.com/single.json": "/foo.json"
        },
        "include": "./read_partial_001.json"
      }
    }
  })JSON"};

  replace_all(text, "STUB_DIRECTORY", STUB_DIRECTORY);
  const auto expected{sourcemeta::core::parse_json(text)};
  EXPECT_EQ(raw_configuration, expected);
}

TEST(Configuration_read, read_valid_014) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_valid_014.json"};
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, COLLECTIONS_DIRECTORY)};

  std::string text{R"JSON({
    "url": "http://localhost:8000",
    "html": {
      "name": "Title",
      "description": "Description"
    },
    "contents": {
      "example": {
        "title": "Test",
        "baseUri": "https://example.com/extension",
        "path": "STUB_DIRECTORY/schemas/example/extension",
        "defaultDialect": "http://json-schema.org/draft-07/schema#",
        "resolve": {
          "https://other.com/single.json": "/foo.json"
        },
        "contents": {
          "foo": {
            "include": "./read_partial_001.json"
          }
        }
      }
    }
  })JSON"};

  replace_all(text, "STUB_DIRECTORY", STUB_DIRECTORY);
  const auto expected{sourcemeta::core::parse_json(text)};
  EXPECT_EQ(raw_configuration, expected);
}

TEST(Configuration_read, read_invalid_001) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_invalid_001.json"};

  try {
    sourcemeta::registry::Configuration::read(configuration_path,
                                              COLLECTIONS_DIRECTORY);
    FAIL();
  } catch (const sourcemeta::registry::ConfigurationReadError &error) {
    EXPECT_EQ(error.from(), configuration_path);
    EXPECT_EQ(error.target(),
              std::filesystem::path{STUB_DIRECTORY} / "missing.json");
    EXPECT_EQ(sourcemeta::core::to_string(error.location()),
              "/contents/example/include");
    SUCCEED();
  } catch (...) {
    FAIL();
  }
}

TEST(Configuration_read, read_invalid_002) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_invalid_002.json"};

  try {
    sourcemeta::registry::Configuration::read(configuration_path,
                                              COLLECTIONS_DIRECTORY);
    FAIL();
  } catch (
      const sourcemeta::registry::ConfigurationUnknownBuiltInCollectionError
          &error) {
    EXPECT_EQ(error.from(), configuration_path);
    EXPECT_EQ(error.identifier(), "@invalid");
    EXPECT_EQ(sourcemeta::core::to_string(error.location()), "/extends");
    SUCCEED();
  } catch (...) {
    FAIL();
  }
}

TEST(Configuration_read, read_invalid_003) {
  const auto configuration_path{std::filesystem::path{STUB_DIRECTORY} /
                                "read_invalid_003.json"};

  try {
    sourcemeta::registry::Configuration::read(configuration_path,
                                              COLLECTIONS_DIRECTORY);
    FAIL();
  } catch (
      const sourcemeta::registry::ConfigurationUnknownBuiltInCollectionError
          &error) {
    EXPECT_EQ(error.from(), configuration_path);
    EXPECT_EQ(error.identifier(), "@invalid");
    EXPECT_EQ(sourcemeta::core::to_string(error.location()),
              "/contents/example/include");
    SUCCEED();
  } catch (...) {
    FAIL();
  }
}
