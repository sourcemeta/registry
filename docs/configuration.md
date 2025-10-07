---
hide:
  - navigation
---

# Configuration

Sourcemeta One is designed around a GitOps workflow: all of its behavior is
determined by the configuration file documented here, and runtime changes are
not permitted. *This ensures that your instances are fully reproducible,
auditable, and version-controlled, just like any other part of your
infrastructure.*

!!! success

    Because Sourcemeta One is entirely configured at build time (with changes
    applied only via a redeployment), it achieves significant performance
    advantages. Schemas are pre-optimized at build time, and the service itself
    is fully stateless, enabling effortless horizontal scaling and predictable
    performance under load.

This configuration file is designed to give you complete freedom to structure
your instance in a way that best suits your organization. Compared to many
other solutions, it imposes no artificial constraints on hierarchy, versioning,
or schema organization. You can version and arrange your schemas however you
like: by department, by function, in a flat structure, or in any other way you
can think of. This allows your instance to reflect your company's needs rather
than a pre-defined model.

!!! note

    By convention, the name of the configuration file is `one.json`.

The JSON Schema that defines `one.json` can be mounted in the instance as a
[built-in collection](library.md) called `@sourcemeta/one`. You can explore the
latest version at
[https://schemas.sourcemeta.com/sourcemeta/one/configuration](https://schemas.sourcemeta.com/sourcemeta/one/configuration).

!!! tip

    A great way to learn what's possible is to explore the configuration file
    of the [schemas.sourcemeta.com](https://schemas.sourcemeta.com) public
    example instance, which you can find [on
    GitHub](https://github.com/sourcemeta/one/blob/main/public/one.json)

## `one.json`

The configuration file controls your entire instance through various top-level
properties that define both global settings and content structure.  For
representing the contents of the instance, this file uses a hierarchical tree
approach where you organise the contents of your instance using nested nodes.
Each node in this tree serves as either a [Collection](#collections)
(containing actual schemas) or a [Page](#pages) (acting as a directory that
groups other pages and schema collections), giving you complete flexibility in
structuring your instance.

!!! note

    While any content tree structure is supported, you cannot create a
    top-level entry called `self`, as this namespace is reserved for the [HTTP
    API](api.md) and other internal functionality.

| Property        | Type | Required | Default | Description |
|-----------------|------|----------|---------|-------------|
| `/url`          | String  | :red_circle: **Yes** | N/A | The absolute URL on which the instance will be served. Sourcemeta One will automatically add URI identifiers relative to this URL for every ingested schema |
| `/extends`      | Array   | No  | None | One or more configuration files to extend from. See the [Extends](#extends) section for more information |
| `/contents`     | Object  | No  | None | The top-level [Collections](#collections) and [Pages](#pages) that compose the instance |
| `/html`        | Object or Boolean  | No  | `{}` | Settings for the HTML explorer. If set to `false`, the instance runs in headless mode. See the [HTML](#html) section for more details |

For example, a minimal configuration that mounts a single schema collection
(`./schemas`) at URL `https://schemas.example.com/my-first-collection` may look
like this, and a schema at `./schemas/foo.json` will be available at
`https://schemas.example.com/my-first-collection/foo.json`:

```json title="one.json"
{
  "url": "https://schemas.example.com",
  "contents": {
    "my-first-collection": {
      "path": "./schemas"
    }
  }
}
```

### HTML

When enabled through the optional `html` top-level property, Sourcemeta One
generates an HTML explorer interface. Unlike the [JSON API](api.md), this
explorer provides a user-friendly web interface for browsing and examining your
schemas.  You can customize the explorer's appearance and behavior using the
configuration options detailed below.

| Property        | Type | Required | Default | Description |
|-----------------|------|----------|---------|-------------|
| `/name`        | String  | No  | *Sourcemeta* | The concise name of the instance. For example, the name of your organisation. This will be shown in the navigation bar in the HTML explorer |
| `/description`  | String  | No  | *The next-generation JSON Schema platform* | A longer description of the instance. This will be shown in HTML meta tags |
| `/head`         | String  | No  | None | An HTML snippet to include in the `<head>` section of the HTML explorer. Useful for website analytics purposes or for custom styles |
| `/hero`         | String  | No  | None | An HTML snippet to render in the front page. Try to make this snippet as standalone as possible using `style` HTML attributes |
| `/action`       | Object  | No  | None | A call-to-action button to render in the navigation bar of the HTML explorer |
| `/action/title` | String  | Yes | N/A | The text of the call-to-action button |
| `/action/icon`  | String  | Yes | N/A | The icon name of the call-to-action button, which must match the name of an icon in the [Bootstrap Icons](https://icons.getbootstrap.com) collection |
| `/action/url`   | String  | Yes | N/A | The absolute URL of the call-to-action button |

## Collections

A schema collection functions as a curated set of schemas that the instance
ingests and serves at a specified location. Unlike pages, schema collections
contain the actual schema definitions that power your instance.

*Sourcemeta One supports JSON Schema Draft 4, Draft 6, Draft 7, 2019-09, and
2020-12; and custom meta-schemas based on those dialects.*

!!! warning

    Sourcemeta One maintains data integrity by rejecting any schemas that fail
    against their meta-schemas or that cannot be fully resolved during the
    ingestion process. For this reason, you may need to explicitly inform the
    instance about default dialects, base URIs, or custom overrides for schema
    reference resolution.

    If you are facing any difficulties with this, don't hesitate in asking for
    help using [GitHub
    Discussions](https://github.com/sourcemeta/one/discussions). We are here to
    help!

!!! note

    To consolidate differences across operating systems, Sourcemeta One assumes
    the file system is case-insensitive and will not distinguish between two
    schema URIs that only differ in casing.  Furthermore, URI paths will be
    turned into lowercase.

| Property        | Type | Required | Default | Description |
|-----------------|------|----------|---------|-------------|
| `/path`         | String  | :red_circle: **Yes** (unless `includes` is set) | N/A | The path (relative to the location of the configuration file) to the directory which includes the schemas for this collection. The directory will be recursively traversed in search of `.json`, `.yaml`, or `.yml` schemas |
| `/baseUri`         | String  | No  | *The `file://` URI of the configuration directory* | The base URI of every schema file that is part of this collection, for rebasing purposes. If a schema defines an explicit identifier that is not relative to this base URI, the generation of the instance will fail |
| `/defaultDialect` | String  | No  | None | The default JSON Schema dialect URI to use for schemas that do not declare the `$schema` keyword |
| `/title`        | String  | No  | None | The concise title of the schema collection |
| `/description`  | String  | No  | None | A longer description of the schema collection |
| `/email`        | String  | No  | None | The e-mail address associated with the schema collection |
| `/github`       | String  | No  | None | The GitHub organisation or `organisation/repository` identifier associated with the schema collection |
| `/website`      | String  | No  | None | The absolute URL to the website associated with the schema collection |
| `/includes`     | String  | No  | None | A `jsonschema.json` manifest definition to include in-place. See the [Includes](#includes) section for more information. **If this property is set, none of the other properties can be set (including `path`)** |
| `/resolve`      | Object  | No  | None | A URI-to-URI map to hook into the schema reference resolution process. See the [Resolve](#resolve) section for more information |
| `/x-sourcemeta-one:evaluate`      | Boolean  | No  | `true` | When set to `false`, disable the evaluation API for this schema collection. This is useful if you will never make use of the [evaluation API](api.md) and want to speed up the generation of the instance |
| `/x-sourcemeta-one:protected`      | Boolean  | No  | `false` | When set to `true`, list the schemas in the collection but don't serve them directly. This is useful to ingest a collection of schemas but not make them available to consumers other than the instance itself. **Note that the schemas will be indirectly served through bundling if you have collections that reference protected schemas but are not marked as protected themselves** |
| `/x-sourcemeta-one:alert`      | String  | No  | N/A | When set, provide a human-readable alert on both the API and the HTML explorer for every schema in the collection. This is useful to provide any important message to consumers |

### Includes

The `includes` property enables modular schema collection management by
allowing you to extract collection definitions into separate `jsonschema.json`
files and reference them in-place. Unlike inline definitions, this approach
promotes reusability across multiple configuration files while maintaining
clean separation of concerns. Each included `jsonschema.json` file contains the
same properties as a standard schema collection definition, with Sourcemeta One
seamlessly integrating the external file's contents at the specified location
during processing. For example:

```json hl_lines="5" title="one.json"
{
  "url": "https://schemas.example.com",
  "contents": {
    "my-first-collection": {
      "includes": "./jsonschema.json"
    }
  }
}
```

```json title="jsonschema.json"
{
  "title": "My Schema Collection",
  "path": "./schemas"
}
```

If a directory path is provided to the `includes` property, the instance will
look for a file called `jsonschema.json` inside such directory.

### Resolve

The `resolve` property is an advanced feature to hook into the schema reference
resolution process. When set, the object translates any reference that equals a
property name in the object to the corresponding property value.

This is useful when mounting schemas that consume other external schemas and
you want to route the reference back into the instance. For example, let's say
your schema collection depends on [GeoJSON](https://geojson.org) and has
various references to its latest official URL:
`https://geojson.org/schema/GeoJSON.json`. Instead of depending on an external
resource outside your control, you can configure the instance to extend from
the [`@geojson/v1.0.5`](library.md) built-in collection and rephrase the
`https://geojson.org/schema/GeoJSON.json` references to consume from the
internal version:

```json hl_lines="3 8" title="one.json"
{
  "url": "https://schemas.example.com",
  "extends": [ "@geojson/v1.0.5" ],
  "contents": {
    "my-first-collection": {
      "path": "./schemas",
      "resolve": {
        "https://geojson.org/schema/GeoJSON.json": "/geojson/v1.0.5/geojson.json"
      }
    }
  }
}
```

## Pages

A page functions as an organizational container within the instance.  Unlike
schema collections, pages don't contain schemas directly—instead, they group
other pages or schema collections together. For instance, you might create a
hierarchy of pages representing your organization's teams, where each team page
contains the schema collections they own.

| Property        | Type | Required | Default | Description |
|-----------------|------|----------|---------|-------------|
| `/title`        | String  | No  | None | The concise title of the page |
| `/description`  | String  | No  | None | A longer description of the page |
| `/email`        | String  | No  | None | The e-mail address associated with the page |
| `/github`       | String  | No  | None | The GitHub organisation or `organisation/repository` identifier associated with the page |
| `/website`      | String  | No  | None | The absolute URL to the website associated with the page |
| `/extends`      | Array   | No  | None | One or more configuration files to extend from. See the [Extends](#extends) section for more information |
| `/contents`     | Object  | No  | None | The nested [Collections](#collections) and [Pages](#pages) inside this page |

## Extends

The `extends` property enables configuration inheritance, allowing either your
top-level schema or individual pages to build upon existing configuration files
for enhanced reusability and modularity. This property accepts an array of
strings where each entry represents either a file path (relative from the
configuration file location) or a [built-in schema collection
identifier](library.md) (prefixed with `@`). For example:

```json hl_lines="3" title="one.json"
{
  "url": "https://schemas.example.com",
  "extends": [ "@geojson/v1.0.5", "../path/to/my/other/config/one.json" ]
}
```

If a directory path is provided to the `extends` property, the instance will
look for a file called `one.json` inside such directory.

!!! note

    Sourcemeta One processes these extensions through deep-merging, where each
    extended configuration file merges into the previous one in sequence, with
    your top-level configuration file taking final precedence over the combined
    result.

