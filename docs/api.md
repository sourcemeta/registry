---
hide:
  - navigation
---

# HTTP API

This API has been architected with performance as a primary consideration,
ensuring fast response times and efficient resource utilization across all
endpoints.

- **Cross-origin resource sharing (CORS)**: Full CORS support is implemented
  throughout the API, including proper handling of preflight `OPTIONS`
  requests, making it seamlessly compatible with browser-based applications and
  cross-origin requests
- **HTTP conventions**: Every `GET` request has a corresponding `HEAD` method.
  For brevity, we don't specify this every time
- **Errors**: Error responses follow the [RFC 7807 Problem
  Details](https://www.rfc-editor.org/rfc/rfc7807) specification for
  consistent, machine-readable error information
- **Schema Documentation**: While we don't provide an OpenAPI specification due
  to its current limitations with multi-fragment path support ([see OpenAPI
  Issue #2653](https://github.com/OAI/OpenAPI-Specification/issues/2653)) which
  make describing this API impossible, the Registry itself is comprehensively
  defined using JSON Schemas.  For complete API schema definitions, mount the
  built-in [`@sourcemeta/registry`](library.md) schema collection to your
  Registry instance

## General

### List

*This endpoint lists the contents of a directory within the Registry at the
specified `{path}` parameter*.

```
GET /self/api/list/{path?}
```

If no path is provided, the endpoint returns the contents of the root
directory. The response includes all schemas and subdirectories available at
the requested path, providing a hierarchical view of the registry structure for
navigation and discovery purposes.

=== "200"

    | Property                       | Type                     | Required | Description |
    |--------------------------------|--------------------------|-----|-------------------------------------|
    | `/url` | String | Yes | The absolute URL of the directory |
    | `/path` | String | Yes | The relative URL of the directory |
    | `/breadcrumb` | Array | Yes | The breadcrumb of the directory entry |
    | `/breadcrumb/*/name` | String | Yes | The breadcrumb entry URL path segment |
    | `/breadcrumb/*/url` | String | Yes | The relative URL of the breadcrumb location |
    | `/title` | String | No | The title associated with the directory |
    | `/description` | String | No | The description associated with the directory |
    | `/email` | String | No | The e-mail address associated with the directory |
    | `/github` | String | No | The GitHub organisation or repository associated with the directory |
    | `/website` | String | No | The external URL associated with the directory  |
    | `/entries` | Array | Yes | The entries inside the directory |
    | `/entries/*/type` | String | Yes | The type of the entry (`schema` or `directory`) |
    | `/entries/*/name` | String | Yes | The last URL path segment of the entry |
    | `/entries/*/path` | String | Yes | The relative URL of the entry |
    | `/entries/*/health` | Integer | No | The aggregated health of the entry |
    | `/entries/*/title` | String | No | The title associated with the entry |
    | `/entries/*/description` | String | No | The description associated with the entry |
    | `/entries/*/email` | String | No | For `directory` entries, the e-mail address associated with the entry |
    | `/entries/*/github` | String | No | For `directory` entries, the GitHub organisation or repository associated with the entry |
    | `/entries/*/website` | String | No | For `directory` entries, the website URL associated with the entry |
    | `/entries/*/bytes` | Integer | No | For `schema` entries, the bytes that the entry occupies |
    | `/entries/*/baseDialect` | String | No | For `schema` entries, the base dialect URI of the entry |
    | `/entries/*/dialect` | String | No | For `schema` entries, the dialect URI of the entry |
    | `/entries/*/identifier` | String | No | For `schema` entries, the absolute URI of the entry |
    | `/entries/*/protected` | Boolean | No | For `schema` entries, whether the schema is listed but not accessible |
    | `/entries/*/alert` | String / Null | No | For `schema` entries, the human readable alert message for the schema collection |

=== "404"

    The directory does not exist.

## Schemas

### Fetch

*This endpoint fetches the JSON Schema located at the `{path}` parameter.*

```
GET /{path}[.json][?bundle=1]
```

The `.json` extension is optional unless the HTML UI is enabled and the
`Accept` header is set to prefer an HTML response.  If the `bundle` query
parameter is set, the schema references are embedded using the standard [JSON
Schema
Bundling](https://json-schema.org/blog/posts/bundling-json-schema-compound-documents)
process.


=== "200"

    The schema as JSON.

=== "404"

    The schema does not exist.

=== "405"

    The [configuration file](configuration.md) marks the schema collection as listed but not served.

### Evaluate

*This endpoint takes a JSON instance as a request body and evaluates it against
the JSON Schema located at the `{path}` parameter.*

```
POST /self/api/schemas/evaluate/{path}
```

Perform exhaustive JSON Schema evaluation (including annotation collection) and
respond back using the *Basic* [JSON Schema Standard Output
Format](https://json-schema.org/draft/2020-12/json-schema-core#name-output-structure).

=== "200"

    See [JSON Schema Standard Output Formats](https://json-schema.org/draft/2020-12/json-schema-core#name-output-structure).

=== "400"

    You must pass an instance to validate against.

=== "404"

    The schema does not exist.

=== "405"

    The [configuration file](configuration.md) excludes evaluation for this schema, or the [configuration file](configuration.md) marks the schema collection as listed but not served.

### Trace

*This endpoint takes a JSON instance as a request body and evaluates it against
the JSON Schema located at the `{path}` parameter.*

```
POST /self/api/schemas/trace/{path}
```

Unlike standard schema validation, this endpoint performs a detailed trace
evaluation that exposes the complete internal validation process, including
each step, rule application, and decision point that occurs during schema
processing. This granular visibility into the validation workflow makes it
particularly valuable for debugging complex schema issues, understanding
validation failures, and for developers building JSON Schema tooling who need
insight into the validation engine's behavior and logic flow.

=== "200"

    | Property                       | Type                     | Required | Description |
    |--------------------------------|--------------------------|-----|-------------------------------------|
    | `/valid`                       | Boolean                  | Yes | Whether evaluation succeeded or not |
    | `/steps`                       | Array                    | Yes | The evaluation steps that took place |
    | `/steps/*`                     | Object                   | Yes | Each evaluation step that took place |
    | `/steps/*/type`                | `push` / `pass` / `fail` | Yes | The type of the step entry |
    | `/steps/*/message`             | String                   | Yes | A description of the step |
    | `/steps/*/evaluatePath`        | String                   | Yes | The evaluate path as a JSON Pointer |
    | `/steps/*/keywordLocation`     | String                   | Yes | The absolute keyword location as a URI |
    | `/steps/*/instanceLocation`    | String                   | Yes | The instance location as a JSON Pointer |
    | `/steps/*/name`                | String                   | Yes | The internal name of the step |
    | `/steps/*/vocabulary`          | String / Null            | Yes | The vocabulary URI that defines the keyword, if any |
    | `/steps/*/annotation`          | JSON / Null              | Yes | The annotation value produced by the step, if any |
    | `/steps/*/instancePositions`   | Array                    | Yes | The instance line positions associated with the step |
    | `/steps/*/instancePositions/0` | Integer | Yes | Starting line number |
    | `/steps/*/instancePositions/1` | Integer | Yes | Starting column number |
    | `/steps/*/instancePositions/2` | Integer | Yes | Ending line number |
    | `/steps/*/instancePositions/3` | Integer | Yes | Ending column number |

=== "400"

    You must pass an instance to validate against.

=== "404"

    The schema does not exist.

=== "405"

    The [configuration file](configuration.md) excludes evaluation for this schema, or the [configuration file](configuration.md) marks the schema collection as listed but not served.

### Metadata

*This endpoint retrieves metadata information about the JSON Schema located at
the `{path}` parameter.*

```
GET /self/api/schemas/metadata/{path}
```

=== "200"

    | Property                       | Type                     | Required | Description |
    |--------------------------------|--------------------------|-----|-------------------------------------|
    | `/path` | String | Yes | The relative URL of the schema |
    | `/identifier` | String | Yes | The absolute URI of the schema |
    | `/dialect` | String | Yes | The dialect URI of the schema |
    | `/baseDialect` | String | Yes | The base dialect URI of the schema |
    | `/health` | Integer | Yes | The health score of the schema |
    | `/bytes` | Integer | Yes | The bytes that the schema occupies |
    | `/protected` | Boolean | Yes | Whether the schema is listed but not accessible |
    | `/alert` | String / Null | No | The human readable alert message for the schema collection, if any |
    | `/title` | String | No | The title of the schema, if any |
    | `/description` | String | No | The description of the schema, if any |
    | `/examples` | Array | Yes | Up to 10 of the schema examples, if any |
    | `/breadcrumb` | Array | Yes | The breadcrumb of the schema |
    | `/breadcrumb/*/name` | String | Yes | The breadcrumb entry URL path |
    | `/breadcrumb/*/path` | String | Yes | The relative URL of the breadcrumb location |

=== "404"

    The schema does not exist.

### Search

*This endpoint searches for JSON Schemas based on the provided query `{term}`.*

```
GET /self/api/schemas/search?q={term}
```

Note that the this endpoint has a hard limit of 10 results.

=== "200"

    | Property | Type | Required | Description |
    |----------|------|----------|-------------|
    | `/*/path` | String | Yes | The relative URL of the schema |
    | `/*/title` | String | No | The title of the schema (may be an empty string) |
    | `/*/description` | String | No | The description of the schema (may be an empty string) |

### Dependencies

*This endpoint retrieves all direct and indirect dependencies of the JSON
Schema located at the specified `{path}` parameter.*

```
GET /self/api/schemas/dependencies/{path}
```

=== "200"

    | Property | Type | Required | Description |
    |----------|------|----------|-------------|
    | `/*/from` | String | Yes | The absolute URL of the schema that originates the dependency |
    | `/*/to` | String | Yes | The absolute URL of the schema being referenced |
    | `/*/at` | String | Yes | The JSON Pointer to the schema location where the dependency originates |

=== "404"

    The schema does not exist.

### Health

*This endpoint retrieves the health analysis and score for the JSON Schema located at the specified `{path}` parameter.*

```
GET /self/api/schemas/health/{path}
```

=== "200"

    | Property | Type | Required | Description |
    |----------|------|----------|-------------|
    | `/score` | Integer | Yes | The overall health score of the schema (0 to 100) |
    | `/errors` | Array | Yes | Array of health issues found in the schema |
    | `/errors/*/pointers` | Array | Yes | The paths where the issue occurs |
    | `/errors/*/pointers/*` | String | Yes | A JSON Pointer path of where the issue occurs |
    | `/errors/*/name` | String | Yes | The identifier name of the health issue |
    | `/errors/*/message` | String | Yes | Human-readable description of the issue |
    | `/errors/*/description` | String / Null | No | Additional description (may be null) |

=== "404"

    The schema does not exist.

### Locations

*This endpoint retrieves metadata about every URI associated with the JSON
Schema located at the specified `{path}` parameter, including schema resources,
subschemas, anchors, and more.*

```
GET /self/api/schemas/locations/{path}
```

=== "200"

    | Property | Type | Required | Description |
    |----------|------|----------|-------------|
    | `/static` | Object | Yes | Static URI locations within the schema |
    | `/static/*` | Object | Yes | Metadata for a specific URI location |
    | `/static/*/base` | String | Yes | The base URI of the location |
    | `/static/*/baseDialect` | String | Yes | The base dialect of the schema |
    | `/static/*/dialect` | String | Yes | The JSON Schema dialect URI |
    | `/static/*/parent` | String / Null | No | The parent JSON Pointer (if any) |
    | `/static/*/pointer` | String | Yes | The JSON Pointer to this location from the root of the schema |
    | `/static/*/relativePointer` | String | Yes | The relative JSON Pointer from its nearest base URI |
    | `/static/*/root` | String | Yes | The root URI of the schema |
    | `/static/*/type` | String | Yes | The type of location |
    | `/dynamic` | Object | Yes | Dynamic URI locations within the schema |
    | `/dynamic/*` | Object | Yes | Metadata for a specific URI location |
    | `/dynamic/*/base` | String | Yes | The base URI of the location |
    | `/dynamic/*/baseDialect` | String | Yes | The base dialect of the schema |
    | `/dynamic/*/dialect` | String | Yes | The JSON Schema dialect URI |
    | `/dynamic/*/parent` | String / Null | No | The parent URI (if any) |
    | `/dynamic/*/pointer` | String | Yes | The JSON Pointer to this location from the root of the schema |
    | `/dynamic/*/relativePointer` | String | Yes | The relative JSON Pointer from its nearest base URI |
    | `/dynamic/*/root` | String | Yes | The root URI of the schema |
    | `/dynamic/*/type` | String | Yes | The type of location |

=== "404"

    The schema does not exist.

=== "405"

    The [configuration file](configuration.md) marks the schema collection as listed but not served.

### Positions

*This endpoint retrieves line and column position information for every token
in the JSON Schema located at the specified `{path}` parameter.*

```
GET /self/api/schemas/positions/{path}
```

The result is a JSON object where every property is JSON Pointer to the given
schema.

=== "200"

    | Property | Type | Required | Description |
    |----------|------|----------|-------------|
    | `/*/0` | Integer | Yes | Starting line number |
    | `/*/1` | Integer | Yes | Starting column number |
    | `/*/2` | Integer | Yes | Ending line number |
    | `/*/3` | Integer | Yes | Ending column number |

=== "404"

    The schema does not exist.

=== "405"

    The [configuration file](configuration.md) marks the schema collection as listed but not served.
