---
title: Home
hide:
  - navigation
---

# Welcome to the Sourcemeta JSON Schema Registry

A high-performance, self-hosted [JSON Schema](https://json-schema.org) registry
that transforms your **existing Git repositories of schemas** into searchable,
discoverable schema catalogs with enterprise-grade governance capabilities.

<img alt="A screenshot of the Registry" loading="lazy" src="https://www.sourcemeta.com/screenshot.webp" id="screenshot">

!!! info "About Us"

    [Sourcemeta](https://www.sourcemeta.com) is led by a member of the JSON
    Schema Technical Steering Committee. We are consultants, O'Reilly book
    authors, award-winning researchers, and open-source maintainers in the JSON
    Schema ecosystem.  *With us, you get unmatched specification compliance and
    battle-tested expertise that you simply won't find elsewhere.*

    Some of our other projects include
    **[Blaze](https://github.com/sourcemeta/blaze)** (ultra high-performance
    JSON Schema compiler), **[JSON Schema
    CLI](https://github.com/sourcemeta/jsonschema)** (the most comprehensive
    JSON Schema command-line tool), and
    **[LearnJSONSchema.com](https://www.learnjsonschema.com)** (the most
    popular JSON Schema reference documentation site).

Check out a live public example instance of the Sourcemeta Registry at
[schemas.sourcemeta.com](https://schemas.sourcemeta.com).

## Use Cases

**Schema Catalog**: Most organisations have JSON Schemas scattered across Git
repositories with broken frontends, duct-tape integrations, or no
discoverability at all. The Sourcemeta Registry sits on top of your existing
repositories and transforms them into a unified, searchable catalog where teams
can discover, browse, consume, and understand your data contracts.

**API Governance**: Establish organisation-wide standards for API design by
centralizing schema management, easily consuming external JSON Schema data
models, tracking schema quality, and ensuring consistency across teams and
services.

**Tooling Infrastructure**: API and schema tooling companies can embed the
Registry as a foundational component in their own products. For example,
OpenAPI editors and developer platforms can leverage Sourcemeta's advanced
schema technology through the Registry's [HTTP API](api.md) to power their
schema-related features (such as offering built-in schema collections to their
end users) without building complex JSON Schema infrastructure from scratch.

## Key Features

<div class="grid cards" markdown>

- :material-git: __GitOps-Native__ [Easy setup](configuration.md) from your
  existing Git repositories.  Governance-friendly by design—all schema changes
  go through Git approval workflows
- :material-language-html5: __Web Explorer__ Search and browse schemas across
  your organisation from an intuitive web interface. Disable for headless
  API-only deployments
- :material-code-braces: __Editor Integration__ Edit schemas in your IDE with
  full autocomplete support. Automatically accommodates Visual Studio Code
  [quirks](https://github.com/microsoft/vscode-json-languageservice/issues/224)
  like [broken auto-completion of
  meta-schemas](https://github.com/microsoft/vscode-json-languageservice/issues/149)
- :material-check: __Schema Health Checks__ Monitor and guarantee schema best
  practices with comprehensive built-in linting. The most advanced JSON Schema
  linter available, designed with input from the JSON Schema organisation
- :material-api: __Rich HTTP API__ High-performance programmatic access for
  CI/CD pipelines, tooling integration, and custom workflows. Check out the
  [documentation](api.md) to learn more
- :material-library:  __Built-in Schema Collections__ [Curated
  schemas](library.md) from industry leaders eliminate fragile copy-pasting of
  upstream schemas
- :octicons-versions-16: __JSON Schema Compatibility__ Full support for JSON
  Schema Draft 4, Draft 6, Draft 7, 2019-09, and 2020-12, plus custom
  meta-schemas, [Standard Output
  Formats](https://json-schema.org/draft/2020-12/json-schema-core#name-output-formatting),
  annotation collection, JSON Schema
  [Bundling](https://json-schema.org/blog/posts/bundling-json-schema-compound-documents),
  and more
- :material-rocket: __High Performance__ Written in C++, delivering exceptional
  performance with minimal compute resources. Run instances on modest hardware,
  reducing infrastructure costs while maintaining enterprise-scale throughput
  with a stateless horizontally-scalable design

</div>

## Enterprise Ready

**Zero-dependency deployment**: Maintain complete control over your schema data
with straightforward deployment without any additional runtime dependency such
as databases. Perfect for highly-regulated industries, compliance requirements,
and airgapped environments where every dependency creates security and
operational risk.

**Source-available**: The Registry is source-available (though not open-source)
on [GitHub](https://github.com/sourcemeta/registry), providing complete code
transparency for security audits, compliance reviews, internal assessments, and
modification. Enterprises can examine every line of code, eliminating black-box
concerns and ensuring no vendor lock-in. If Sourcemeta would ever cease
operations, you retain full access to continue running and maintaining your
Registry instances.

**Expert commercial support & training**: [Commercial
Licenses](./commercial.md) give you access to world-class JSON Schema expertise
whenever you need it. Upon request, we provide managed hosting, and we also
offer advanced tailored consultancy and training programs to elevate your
team's schema design capabilities. [Reach out](mailto:hello@sourcemeta.com) to
discuss further!

## Roadmap

As an early-stage bootstrapped startup, we're rapidly implementing new
capabilities, but the current Registry represents just the beginning of our
vision. Your feedback is crucial in helping us build the schema management
solution the industry needs.

- **Automatic schema upgrades and downgrades**: Seamlessly serve your schemas
  in any JSON Schema version that external tools require, eliminating manual
  conversion headaches
- **Schema evolution and transforms**: Convert data between schema versions and
  formats. Includes schema evolution (i.e. v1 to v2) to arbitrary data
  transformations (i.e. Celsius to Fahrenheit)
- **Standard Library of Schemas**: Expertly crafted OEM schema collections
  covering diverse domains, so that you can stop reinventing the wheel and
  build other schemas and API specifications on proven foundations
- **Step-through Online Schema Debugger**: Visual schema evaluation debugger
  that highlights validation logic line-by-line in both schema and instance
  data for faster troubleshooting
- **Documentation Generation**: Human-readable schema documentation that
  business teams and non-technical stakeholders can easily understand
- **Specification Support**: Native ingestion of OpenAPI, AsyncAPI, SDF, W3C
  Web of Things, and other specifications that embed JSON Schema, with the full
  benefits of the Registry
- **Gateway Functionality**: Structured Output LLM negotiation, API
  specification testing proxy, data ingestion endpoints, and other advanced
  validation gateway capabilities (such as dynamically testing strictness of
  schemas against runtime data)

Do you have other needs? Don't hesitate in [writing to
us](mailto:hello@sourcemeta.com) any time. We are friendly!

## Next Steps

Ready to transform your scattered schemas into a powerful discovery platform?
Head over to the [Getting Started](getting-started.md) guide and get up and
running in minutes.
