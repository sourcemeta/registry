---
hide:
  - navigation
---

# Curated Schema Collections

*Most JSON Schema projects don't start from a blank sheet. They often build on
top of existing data models for regulatory compliance, partner
interoperability, or simply to avoid reinventing the wheel.*

However, hunting down the right authoritative source, copying schemas from
multiple sources, and keeping them aligned with the versions your consumers
expect is time-consuming and error-prone. That friction increases delivery
risk, introduces compatibility bugs, and makes governance much harder than it
needs to be.

To solve this problem, the Sourcemeta Registry ships with a growing curated set
of widely-used JSON Schema collections that you can easily import into your
instance. Each collection is discoverable, versioned, and maintained so you
don't have to stitch together third-party copies or worry about minor drift
between consumers. Importing a collection gives you an immediately usable,
validated set of schemas you can reference and extend.

!!! tip

    Every available built-in collection is ingested in the
    [schemas.sourcemeta.com](https://schemas.sourcemeta.com) live example
    instance. We also ingest other collections to mature their definitions in
    such instance before they graduate as a built-in collection. Go take a look
    and checkout its
    [`registry.json`](https://github.com/sourcemeta/registry/blob/main/public/registry.json)
    configuration file!

Importing Collections
---------------------

Each built-in schema collection has with a unique identifier that starts with
the `@` character. To import such a collection, import the corresponding
identifier to your [configuration file](configuration.md) using the
[`extends`](configuration.md#extends) keyword.

!!! warning

    The number of schemas from pre-built collections that you import into your
    instance will count towards your schema limits. *If you go beyond the
    limits of the free plan, you will need to acquire a [commercial
    license](commercial.md)*.

For example, let's say your company depends on GeoJSON v1.0.5 and v1.0.4. Their
identifiers are `@geojson/v1.0.5` and `@geojson/v1.0.4`, respectively.
Therefore, a minimal example configuration that ingests them both using the
[`extends`](configuration.md#extends) keyword may look like this:

```json hl_lines="3" title="registry.json"
{
  "url": "https://schemas.example.com",
  "extends": [ "@geojson/v1.0.5", "@geojson/v1.0.4" ]
}
```

Other schemas in your instance may reference these GeoJSON schemas using their
absolute URLs (i.e. `https://schemas.example.com/geojson/v1.0.5/point.json`)
or.  relative URLs (i.e. `/geojson/v1.0.5/point.json`). You can also re-route
existing schemas into the imported locations using the `resolve` configuration
option.

Available Collections
---------------------

These collections are available in every edition of the Sourcemeta Registry
(including the free one) [^1].  Simply add the corresponding identifier to your
[configuration file](configuration.md) using the `extends` keyword.

<!-- TODO: Generate this table from code using the CSV import plugin: -->
<!-- https://squidfunk.github.io/mkdocs-material/reference/data-tables/#import-table-from-file -->

| Identifier | Source | Description | Preview |
|------------|------|-------------|---------|
| `@geojson/v1.0.5` | [GeoJSON](https://geojson.org) | A standard format (RFC 7946) for encoding a variety of geographic data structures | [Link](https://schemas.sourcemeta.com/geojson/v1.0.5) |
| `@geojson/v1.0.4` | [GeoJSON](https://geojson.org) | A standard format (RFC 7946) for encoding a variety of geographic data structures | [Link](https://schemas.sourcemeta.com/geojson/v1.0.4) |
| `@geojson/v1.0.3` | [GeoJSON](https://geojson.org) | A standard format (RFC 7946) for encoding a variety of geographic data structures | [Link](https://schemas.sourcemeta.com/geojson/v1.0.3) |
| `@geojson/v1.0.2` | [GeoJSON](https://geojson.org) | A standard format (RFC 7946) for encoding a variety of geographic data structures | [Link](https://schemas.sourcemeta.com/geojson/v1.0.2) |
| `@geojson/v1.0.1` | [GeoJSON](https://geojson.org) | A standard format (RFC 7946) for encoding a variety of geographic data structures | [Link](https://schemas.sourcemeta.com/geojson/v1.0.1) |
| `@geojson/v1.0.0` | [GeoJSON](https://geojson.org) | A standard format (RFC 7946) for encoding a variety of geographic data structures | [Link](https://schemas.sourcemeta.com/geojson/v1.0.0) |
| `@modelcontextprotocol/2025-06-18` | [Model Context Protocol (MCP)](https://modelcontextprotocol.io) | An open protocol that standardizes how applications provide context to large language models (LLMs) | [Link](https://schemas.sourcemeta.com/modelcontextprotocol/2025-06-18) |
| `@modelcontextprotocol/2025-03-26` | [Model Context Protocol (MCP)](https://modelcontextprotocol.io) | An open protocol that standardizes how applications provide context to large language models (LLMs) | [Link](https://schemas.sourcemeta.com/modelcontextprotocol/2025-03-26) |
| `@modelcontextprotocol/2024-11-05` | [Model Context Protocol (MCP)](https://modelcontextprotocol.io) | An open protocol that standardizes how applications provide context to large language models (LLMs) | [Link](https://schemas.sourcemeta.com/modelcontextprotocol/2024-11-05) |
| `@a2a/v0.3.0` | [Agent2Agent (A2A) Protocol](https://a2a-protocol.org) | An open standard designed to enable seamless communication and collaboration between AI agents | [Link](https://schemas.sourcemeta.com/a2a/v0.3.0) |
| `@a2a/v0.2.6` | [Agent2Agent (A2A) Protocol](https://a2a-protocol.org) | An open standard designed to enable seamless communication and collaboration between AI agents | [Link](https://schemas.sourcemeta.com/a2a/v0.2.6) |
| `@a2a/v0.2.5` | [Agent2Agent (A2A) Protocol](https://a2a-protocol.org) | An open standard designed to enable seamless communication and collaboration between AI agents | [Link](https://schemas.sourcemeta.com/a2a/v0.2.5) |
| `@a2a/v0.2.4` | [Agent2Agent (A2A) Protocol](https://a2a-protocol.org) | An open standard designed to enable seamless communication and collaboration between AI agents | [Link](https://schemas.sourcemeta.com/a2a/v0.2.4) |
| `@a2a/v0.2.3` | [Agent2Agent (A2A) Protocol](https://a2a-protocol.org) | An open standard designed to enable seamless communication and collaboration between AI agents | [Link](https://schemas.sourcemeta.com/a2a/v0.2.3) |
| `@a2a/v0.2.2` | [Agent2Agent (A2A) Protocol](https://a2a-protocol.org) | An open standard designed to enable seamless communication and collaboration between AI agents | [Link](https://schemas.sourcemeta.com/a2a/v0.2.2) |
| `@a2a/v0.2.1` | [Agent2Agent (A2A) Protocol](https://a2a-protocol.org) | An open standard designed to enable seamless communication and collaboration between AI agents | [Link](https://schemas.sourcemeta.com/a2a/v0.2.1) |
| `@a2a/v0.2.0` | [Agent2Agent (A2A) Protocol](https://a2a-protocol.org) | An open standard designed to enable seamless communication and collaboration between AI agents | [Link](https://schemas.sourcemeta.com/a2a/v0.2.0) |
| `@sdf/v1.0.0` | [Semantic Definition Format (SDF)](https://datatracker.ietf.org/doc/draft-ietf-asdf-sdf/) | A format for domain experts to use in the creation and maintenance of data and interaction models that describe Things | [Link](https://schemas.sourcemeta.com/sdf/v1.0.0) |
| `@openapi/v3.2` | [OpenAPI](https://www.openapis.org) | The world's most widely used API description standard | [Link](https://schemas.sourcemeta.com/openapi/v3.2) |
| `@openapi/v3.1` | [OpenAPI](https://www.openapis.org) | The world's most widely used API description standard | [Link](https://schemas.sourcemeta.com/openapi/v3.1) |
| `@openapi/v3.0` | [OpenAPI](https://www.openapis.org) | The world's most widely used API description standard | [Link](https://schemas.sourcemeta.com/openapi/v3.0) |
| `@openapi/v2.0` | [OpenAPI](https://www.openapis.org) | The world's most widely used API description standard | [Link](https://schemas.sourcemeta.com/openapi/v2.0) |
| `@sourcemeta/registry` | [Sourcemeta Registry](https://registry.sourcemeta.com) | Schemas that define the Sourcemeta Registry itself | [Link](https://schemas.sourcemeta.com/sourcemeta/registry) |

[^1]: The built-in collections we offer are redistributed directly from their
  upstream sources *without modification*. As such, any issues, errors, or
  requests for changes should be directed to the original project maintainers.

Requesting New Collections
--------------------------

To request the addition of a new built-in collection, or a new version of an
existing collection, please [open an issue on
GitHub](https://github.com/sourcemeta/registry/issues). Or if you are feeling
adventurous, you may send a pull request to contribute it to the
[`collections/`](https://github.com/sourcemeta/registry/tree/main/collections)
folder.

!!! info

    Not having a collection as part of the built-in library doesn't lock you
    out. You can always bring any collection into your instance yourself by
    cloning or downloading the collection's repository, and manually ingesting
    it into the Registry using the [configuration file](configuration.md).
    Built-in collections are nothing more than pre-made configuration files we
    pre-package for you.
