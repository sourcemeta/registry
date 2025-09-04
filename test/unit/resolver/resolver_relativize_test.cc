#include <gtest/gtest.h>

#include <sourcemeta/registry/resolver.h>

TEST(Resolver_visitor, draft4_1) {
  auto schema = sourcemeta::core::parse_json(R"JSON({
    "id": "http://asyncapi.com/definitions/1.0.0/asyncapi.json",
    "$schema": "http://json-schema.org/draft-04/schema",
    "title": "AsyncAPI 1.0 schema.",
    "type": "object",
    "required": [
        "asyncapi",
        "info",
        "topics"
    ],
    "additionalProperties": false,
    "patternProperties": {
        "^x-": {
            "$ref": "http://asyncapi.com/definitions/1.0.0/vendorExtension.json"
        }
    }
  })JSON");

  sourcemeta::registry::reference_visit(
      schema, sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::registry::reference_visitor_relativize);

  const auto expected = sourcemeta::core::parse_json(R"JSON({
    "id": "http://asyncapi.com/definitions/1.0.0/asyncapi.json",
    "$schema": "http://json-schema.org/draft-04/schema",
    "title": "AsyncAPI 1.0 schema.",
    "type": "object",
    "required": [
        "asyncapi",
        "info",
        "topics"
    ],
    "additionalProperties": false,
    "patternProperties": {
        "^x-": {
            "$ref": "vendorExtension.json"
        }
    }
  })JSON");

  EXPECT_EQ(schema, expected);
}

TEST(Resolver_visitor, draft4_2) {
  auto schema = sourcemeta::core::parse_json(R"JSON({
    "id": "http://example.com",
    "$schema": "http://json-schema.org/draft-04/schema",
    "properties": {
      "foo": {
        "$ref": "http://asyncapi.com/definitions/1.0.0/vendorExtension.json"
      }
    }
  })JSON");

  sourcemeta::registry::reference_visit(
      schema, sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::registry::reference_visitor_relativize);

  const auto expected = sourcemeta::core::parse_json(R"JSON({
    "id": "http://example.com",
    "$schema": "http://json-schema.org/draft-04/schema",
    "properties": {
      "foo": {
        "$ref": "http://asyncapi.com/definitions/1.0.0/vendorExtension.json"
      }
    }
  })JSON");

  EXPECT_EQ(schema, expected);
}

TEST(Resolver_visitor, draft4_3) {
  auto schema = sourcemeta::core::parse_json(R"JSON({
    "id": "http://example.com",
    "$schema": "http://json-schema.org/draft-04/schema",
    "properties": {
      "foo": {
        "$ref": "http://example.com/nested"
      },
      "bar": {
        "id": "http://sourcemeta.com",
        "properties": {
          "bar": {
            "$ref": "http://example.com/nested"
          },
          "baz": {
            "$ref": "http://sourcemeta.com/nested"
          }
        }
      }
    }
  })JSON");

  sourcemeta::registry::reference_visit(
      schema, sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::registry::reference_visitor_relativize);

  const auto expected = sourcemeta::core::parse_json(R"JSON({
    "id": "http://example.com",
    "$schema": "http://json-schema.org/draft-04/schema",
    "properties": {
      "foo": {
        "$ref": "nested"
      },
      "bar": {
        "id": "http://sourcemeta.com",
        "properties": {
          "bar": {
            "$ref": "http://example.com/nested"
          },
          "baz": {
            "$ref": "nested"
          }
        }
      }
    }
  })JSON");

  EXPECT_EQ(schema, expected);
}

TEST(Resolver_visitor, draft4_4) {
  auto schema = sourcemeta::core::parse_json(R"JSON({
    "$schema": "http://json-schema.org/draft-04/schema",
    "properties": {
      "foo": {
        "$ref": "http://asyncapi.com/definitions/1.0.0/vendorExtension.json"
      }
    }
  })JSON");

  sourcemeta::registry::reference_visit(
      schema, sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::registry::reference_visitor_relativize);

  const auto expected = sourcemeta::core::parse_json(R"JSON({
    "$schema": "http://json-schema.org/draft-04/schema",
    "properties": {
      "foo": {
        "$ref": "http://asyncapi.com/definitions/1.0.0/vendorExtension.json"
      }
    }
  })JSON");

  EXPECT_EQ(schema, expected);
}

TEST(Resolver_visitor, draft4_5) {
  auto schema = sourcemeta::core::parse_json(R"JSON({
    "$schema": "http://json-schema.org/draft-04/schema",
    "properties": {
      "foo": {
        "$ref": "http://example.com/nested"
      },
      "bar": {
        "id": "http://sourcemeta.com",
        "properties": {
          "bar": {
            "$ref": "http://example.com/nested"
          },
          "baz": {
            "$ref": "http://sourcemeta.com/nested"
          }
        }
      }
    }
  })JSON");

  sourcemeta::registry::reference_visit(
      schema, sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::registry::reference_visitor_relativize);

  const auto expected = sourcemeta::core::parse_json(R"JSON({
    "$schema": "http://json-schema.org/draft-04/schema",
    "properties": {
      "foo": {
        "$ref": "http://example.com/nested"
      },
      "bar": {
        "id": "http://sourcemeta.com",
        "properties": {
          "bar": {
            "$ref": "http://example.com/nested"
          },
          "baz": {
            "$ref": "nested"
          }
        }
      }
    }
  })JSON");

  EXPECT_EQ(schema, expected);
}

TEST(Resolver_visitor, draft4_6) {
  auto schema = sourcemeta::core::parse_json(R"JSON({
    "$schema": "http://json-schema.org/draft-04/schema",
    "properties": {
      "foo": {
        "$ref": "http://asyncapi.com/definitions/1.0.0/vendorExtension.json"
      }
    }
  })JSON");

  sourcemeta::registry::reference_visit(
      schema, sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::registry::reference_visitor_relativize, std::nullopt,
      "http://asyncapi.com/definitions");

  const auto expected = sourcemeta::core::parse_json(R"JSON({
    "$schema": "http://json-schema.org/draft-04/schema",
    "properties": {
      "foo": {
        "$ref": "1.0.0/vendorExtension.json"
      }
    }
  })JSON");

  EXPECT_EQ(schema, expected);
}

TEST(Resolver_visitor, draft4_7) {
  auto schema = sourcemeta::core::parse_json(R"JSON({
    "id": "http://asyncapi.com/definitions",
    "properties": {
      "foo": {
        "$ref": "http://asyncapi.com/definitions/1.0.0/vendorExtension.json"
      }
    }
  })JSON");

  sourcemeta::registry::reference_visit(
      schema, sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::registry::reference_visitor_relativize,
      "http://json-schema.org/draft-04/schema");

  const auto expected = sourcemeta::core::parse_json(R"JSON({
    "id": "http://asyncapi.com/definitions",
    "properties": {
      "foo": {
        "$ref": "1.0.0/vendorExtension.json"
      }
    }
  })JSON");

  EXPECT_EQ(schema, expected);
}

TEST(Resolver_visitor, draft4_8) {
  auto schema = sourcemeta::core::parse_json(R"JSON({
    "id": "http://asyncapi.com/definitions",
    "properties": {
      "foo": {
        "$ref": "http://asyncapi.com/definitions/1.0.0/vendorExtension.json"
      }
    }
  })JSON");

  EXPECT_THROW(sourcemeta::registry::reference_visit(
                   schema, sourcemeta::core::schema_official_walker,
                   sourcemeta::core::schema_official_resolver,
                   sourcemeta::registry::reference_visitor_relativize),
               sourcemeta::core::SchemaUnknownBaseDialectError);
}

TEST(Resolver_visitor, 2020_12_1) {
  auto schema = sourcemeta::core::parse_json(R"JSON({
    "$id": "http://example.com",
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "properties": {
      "foo": {
        "$dynamicRef": "http://example.com/foo#bar"
      }
    }
  })JSON");

  sourcemeta::registry::reference_visit(
      schema, sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::registry::reference_visitor_relativize);

  const auto expected = sourcemeta::core::parse_json(R"JSON({
    "$id": "http://example.com",
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "properties": {
      "foo": {
        "$dynamicRef": "foo#bar"
      }
    }
  })JSON");

  EXPECT_EQ(schema, expected);
}

TEST(Resolver_visitor, 2020_12_2) {
  auto schema = sourcemeta::core::parse_json(R"JSON({
    "$id": "https://example.com/foo/bar/baz/qux",
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "../../schema.json"
  })JSON");

  sourcemeta::registry::reference_visit(
      schema, sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::registry::reference_visitor_relativize);

  const auto expected = sourcemeta::core::parse_json(R"JSON({
    "$id": "https://example.com/foo/bar/baz/qux",
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "../../schema.json"
  })JSON");

  EXPECT_EQ(schema, expected);
}

TEST(Resolver_visitor, recursive_ref) {
  auto schema = sourcemeta::core::parse_json(R"JSON({
    "$schema": "https://json-schema.org/draft/2019-09/schema",
    "$id": "https://www.sourcemeta.com",
    "$recursiveAnchor": true,
    "additionalProperties": {
      "$recursiveRef": "#"
    }
  })JSON");

  sourcemeta::registry::reference_visit(
      schema, sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::registry::reference_visitor_relativize);

  const auto expected = sourcemeta::core::parse_json(R"JSON({
    "$schema": "https://json-schema.org/draft/2019-09/schema",
    "$id": "https://www.sourcemeta.com",
    "$recursiveAnchor": true,
    "additionalProperties": {
      "$recursiveRef": "#"
    }
  })JSON");

  EXPECT_EQ(schema, expected);
}

TEST(Resolver_visitor, camelcase_paths_are_sensitive) {
  auto schema = sourcemeta::core::parse_json(R"JSON({
    "$schema": "http://json-schema.org/draft-04/schema#",
    "id": "https://sourcemeta.com/camelcase/no-id-absolute-ref.json",
    "properties": {
      "foo": {
        "$ref": "https://sourcemeta.com/CamelCase/no-id.json"
      }
    }
  })JSON");

  sourcemeta::registry::reference_visit(
      schema, sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::registry::reference_visitor_relativize);

  const auto expected = sourcemeta::core::parse_json(R"JSON({
    "$schema": "http://json-schema.org/draft-04/schema#",
    "id": "https://sourcemeta.com/camelcase/no-id-absolute-ref.json",
    "properties": {
      "foo": {
        "$ref": "../CamelCase/no-id.json"
      }
    }
  })JSON");

  EXPECT_EQ(schema, expected);
}
