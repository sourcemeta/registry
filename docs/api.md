---
hide:
  - navigation
---

# HTTP API

!!! info

    The HTTP API is enabled by default on every Sourcemeta One instance.
    It can be disabled by setting `api` to `false` in the
    [configuration file](configuration.md#api).

This API has been architected with performance as a primary consideration,
ensuring fast response times and efficient resource utilization across all
endpoints.

- **Cross-origin resource sharing (CORS)**: Full CORS support is implemented
  throughout the API, including proper handling of preflight `OPTIONS`
  requests, making it seamlessly compatible with browser-based applications and
  cross-origin requests
- **HTTP conventions**: Every `GET` request has a corresponding `HEAD` method.
  For brevity, we don't specify this every time
- **Errors**: Error responses follow the [RFC 9457 Problem
  Details](https://www.rfc-editor.org/rfc/rfc9457) specification for
  consistent, machine-readable error information
- **Schema Documentation**: While we don't provide an OpenAPI specification due
  to its current limitations with multi-fragment path support ([see OpenAPI
  Issue #2653](https://github.com/OAI/OpenAPI-Specification/issues/2653)) which
  make describing this API impossible, Sourcemeta One itself is comprehensively
  defined using JSON Schemas mounted in `/self/v1/schemas`

## General

### Health

*This endpoint can be used as a health check for infrastructure integration
such as Docker
[`HEALTHCHECK`](https://docs.docker.com/reference/dockerfile/#healthcheck) or
load balancer probes.*

```
GET /self/v1/health
```

=== "200"

    Empty response body.

=== "405"

    The HTTP method is not `GET` or `HEAD`.

### Metrics

!!! success "Enterprise"

    This endpoint is only available in the [Enterprise](commercial.md)
    edition. Learn more about [commercial licensing](commercial.md).

*This endpoint reports instance telemetry in the [Prometheus exposition
format](https://prometheus.io/docs/instrumenting/exposition_formats/).*

```
GET /self/v1/metrics
```

Any Prometheus-compatible scraper reads this without configuration beyond the
path. Request behaviour follows the
[RED](https://grafana.com/blog/2018/08/02/the-red-method-how-to-instrument-your-services/)
method, with request and error counts reported per action and status code, and
duration reported per action.
This endpoint is not exempt from [authentication](#authentication), so a policy
covering its path gates it like any other route.

=== "200"

    The metrics in the Prometheus exposition format.

=== "403"

    The instance is running the Community edition.

=== "405"

    The HTTP method is not `GET` or `HEAD`.

### List

*This endpoint lists the contents of a directory at the specified `{path}`
parameter*.

```
GET /self/v1/api/list/{path?}
```

If no path is provided, the endpoint returns the contents of the root
directory. The response includes all schemas and subdirectories available at
the requested path, providing a hierarchical view of the instance structure for
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
    | `/description` | String | No | The description associated with the directory. The web explorer renders this as Markdown |
    | `/email` | String | No | The e-mail address associated with the directory |
    | `/github` | String | No | The GitHub organisation or repository associated with the directory |
    | `/website` | String | No | The external URL associated with the directory  |
    | `/schemas` | Integer | Yes | The recursive count of schemas in this directory |
    | `/private` | Boolean | Yes | Whether an authentication policy governs this directory |
    | `/entries` | Array | Yes | The entries inside the directory |
    | `/entries/*/type` | String | Yes | The type of the entry (`schema` or `directory`) |
    | `/entries/*/name` | String | Yes | The last URL path segment of the entry |
    | `/entries/*/path` | String | Yes | The relative URL of the entry |
    | `/entries/*/private` | Boolean | Yes | Whether an authentication policy governs the entry |
    | `/entries/*/health` | Integer | No | The aggregated health of the entry |
    | `/entries/*/schemas` | Integer | No | For `directory` entries, the recursive count of schemas in the directory |
    | `/entries/*/title` | String | No | The title associated with the entry |
    | `/entries/*/description` | String | No | The description associated with the entry. The web explorer renders this as Markdown |
    | `/entries/*/email` | String | No | For `directory` entries, the e-mail address associated with the entry |
    | `/entries/*/github` | String | No | For `directory` entries, the GitHub organisation or repository associated with the entry |
    | `/entries/*/website` | String | No | For `directory` entries, the website URL associated with the entry |
    | `/entries/*/dependencies` | Integer | Yes | For `schema` entries, the number of direct and indirect dependencies of the schema |
    | `/entries/*/bytes` | Integer | No | For `schema` entries, the bytes that the entry occupies |
    | `/entries/*/bytesBundled` | Integer | No | For `schema` entries, the bytes that the entry occupies when bundled |
    | `/entries/*/baseDialect` | String | No | For `schema` entries, the base dialect URI of the entry |
    | `/entries/*/dialect` | String | No | For `schema` entries, the dialect URI of the entry |
    | `/entries/*/identifier` | String | No | For `schema` entries, the absolute URI of the entry |
    | `/entries/*/alert` | String / Null | No | For `schema` entries, the human readable alert message for the schema collection. The web explorer renders this as Markdown |
    | `/entries/*/priority` | Integer | No | For `schema` entries, an importance hint from `0` (least important) to `100` (most important), inherited from the schema collection's [`x-sourcemeta-one:priority`](configuration.md) configuration value |

=== "404"

    The directory does not exist.

### Static

*This endpoint serves static assets such as stylesheets, scripts, icons, and
the web manifest used by the HTML web explorer.*

```
GET /self/v1/static/{path}
```

This endpoint is always mounted, but web assets are only served when the
[`html`](configuration.md#html) configuration option is enabled.

=== "200"

    The static asset contents with its corresponding `Content-Type` header.

=== "404"

    The static asset does not exist, or the instance is running in headless
    mode.

=== "405"

    The HTTP method is not `GET` or `HEAD`.

## Authentication

!!! success "Enterprise"

    Gating any part of an instance is only available in the
    [Enterprise](commercial.md) edition. Learn more about [commercial
    licensing](commercial.md).

Every endpoint on this page is public unless the [configuration
file](configuration.md#authentication) declares a policy that governs the path
it reaches. An endpoint no governing policy admits the caller to is answered
with `401` and a `WWW-Authenticate` header.

A registry path is different. A schema or collection the caller is not admitted
to is answered exactly as one that does not exist, and directory listings leave
it out. Where an endpoint below names a registry path among its arguments, that
path decides the answer, so it reports `404` rather than `401`.

A machine caller presents its credential on every request and needs none of the
endpoints below:

```
Authorization: Bearer <credential>
```

For an [`apiKey`](configuration.md#api-key) policy that credential is one of
the keys the policy declares. For a [`jwt`](configuration.md#jwt) policy it is
an access token from the issuer the policy trusts.

An [`oidc`](configuration.md#oidc) policy signs a person in at their provider
instead, through the three endpoints below, leaving the browser holding a
session cookie that admits it exactly as a credential would. That cookie is
`HttpOnly`, `SameSite=Lax`, scoped to the instance rather than to the whole
host, and `Secure` whenever the instance URL is `https`. It carries its own
expiry and the signature that proves this instance minted it, so no session is
kept in memory and every replica of an instance accepts the sessions the others
mint.

A signed-in browser also holds a short-lived transaction cookie during a login,
and a renewal marker naming the policy it signed in under, which is what lets an
expired session be renewed against the provider without asking the person again.
The marker carries no credential.

### Providers

*This endpoint names the ways of signing in to this instance, as a page for a
browser and as data for anything else.*

```
GET /self/v1/auth/login
```

Only [`oidc`](configuration.md#oidc) policies appear here. A policy that admits
a program has nowhere to send a person, so naming it would offer a way in that
does not exist.

=== "200"

    | Property                       | Type                     | Required | Description |
    |--------------------------------|--------------------------|-----|-------------------------------------|
    | `/title` | String | No | The name this instance goes by, where it has been given one |
    | `/providers` | Array | Yes | The identity providers a person may sign in through, in declaration order |
    | `/providers/*/name` | String | Yes | The policy name |
    | `/providers/*/title` | String | Yes | The human readable version of the policy name |
    | `/providers/*/path` | String | Yes | The relative URL that starts a login through this provider |

=== "403"

    The instance is running the Community edition, which signs nobody in.

=== "405"

    The HTTP method is not `GET` or `HEAD`.

### Login

*This endpoint begins an interactive login against the named policy's identity
provider.*

```
GET /self/v1/auth/login/{policy}[?to={redirect-location}]
```

The response redirects the browser to the provider's authorization endpoint,
discovered from the policy's issuer, and sets a short-lived transaction cookie
that binds the login to this browser. That cookie is what the callback checks
before it acts on anything the provider says.

`to` names where to land once the login completes, and is honoured only when it
is a path on this instance, so the endpoint cannot be turned into an open
redirect by whoever composes the link. Anything else falls back to the referring
page, and then to the first path the policy declares.

=== "303"

    The provider's authorization URL in `Location`, with the transaction
    cookie in `Set-Cookie`.

=== "404"

    No `oidc` policy carries that name. A policy of another type answers the
    same way, so the endpoint discloses nothing about what is configured.

=== "405"

    The HTTP method is not `GET` or `HEAD`.

=== "500"

    The login cannot be started. Every cause answers this way, among them a
    client secret or session secret absent from the environment, provider
    metadata that could not be retrieved or that names no authorization
    endpoint, and a provider this instance will not send a credential to. A
    login that could not be completed is refused here rather than stranding the
    person at the provider. Nothing distinguishes the causes, so the endpoint
    cannot be used to learn how an instance is configured or whether its
    provider is answering. The cause goes to the server log.

### Callback

*This endpoint completes an interactive login by exchanging the provider's
authorization code for a session.*

```
GET /self/v1/auth/callback/{policy}
```

**This is the redirect URI to register with the identity provider**, as
`{url}/self/v1/auth/callback/{policy}`, built from the instance
[`url`](configuration.md) and the policy name. The provider sends the browser
here, and the endpoint verifies that the transaction cookie belongs to a login
this instance started before acting on the outcome, so a callback arriving from
anywhere else cannot establish a session or report a failure on somebody's
behalf.

=== "303"

    The session cookie in `Set-Cookie`, the spent transaction cookie expired
    alongside it, and the login's return target in `Location`.

=== "400"

    The callback does not belong to a login this instance started, or is
    missing the code that would complete one. Nothing distinguishes the two,
    so a caller learns nothing about the login by asking.

=== "403"

    The provider declined the login, in a callback that does belong to a login
    this instance started.

=== "405"

    The HTTP method is not `GET` or `HEAD`.

=== "500"

    The callback belongs to a login this instance started, but no session came
    of it. Every cause answers this way, among them a client secret or session
    secret absent from the environment, a provider that could not be reached or
    that refused the authorization code, and an identity token that does not
    validate or that no session cookie can hold. Anybody can start a login and
    return with a code of their own invention, so reaching this says nothing
    about who is asking, and nothing distinguishes the causes. The cause goes
    to the server log.

### Logout

*This endpoint ends the browser's session, and the provider's session with it.*

```
POST /self/v1/auth/logout
```

Every cookie this endpoint mints is expired before anything else is decided,
and whether or not the request carried it, so no outcome leaves a session
behind or a browser eligible to renew one. Where the session names a policy
whose provider offers to end its own session, the browser is then sent on to do
so, carrying the identity token as proof of whose session it is asking to end.
That is what stops the next sign-in from silently admitting whoever used the
browser last.

This endpoint answers `POST` rather than `GET` because signing out changes
state at the provider, which [RFC 9110
§9.2.1](https://datatracker.ietf.org/doc/html/rfc9110#section-9.2.1) puts
outside what a safe method may do. A link to it would be followed by anything
that prefetches or unfurls URLs, signing the person out unasked, so the
control that reaches it is a form submission.

=== "303"

    The session, transaction and renewal cookies expired in `Set-Cookie`, and
    either the provider's end-session URL or the instance root in `Location`.

=== "405"

    The HTTP method is not `POST`.

## Schemas

### Fetch

*This endpoint fetches the JSON Schema located at the `{path}` parameter.*

```
GET /{path}[.json][?bundle=1]
```

The `.json` extension is optional unless the HTML UI is enabled and the
`Accept` header is set to prefer an HTML response. The extension and the
`{path}` segment are matched case-insensitively within the catalog's URL
namespace, so `foo.json`, `foo.JSON`, and `FOO.json` all resolve to the same
schema, even though
[RFC 3986 §6.2.2.1](https://datatracker.ietf.org/doc/html/rfc3986#section-6.2.2.1)
makes the path component of a URI case-sensitive in general.
If the `bundle` query parameter is set, the schema references are embedded
using the standard [JSON Schema
Bundling](https://json-schema.org/blog/posts/bundling-json-schema-compound-documents)
process. Meta-schemas are not embedded, as the registry serves every
meta-schema that a schema may declare.

!!! warning "`bundle` is a presence flag, not a boolean"

    Bundling is triggered by the presence of the `bundle` query parameter
    regardless of its value. `?bundle`, `?bundle=1`, `?bundle=true`,
    `?bundle=0`, and `?bundle=false` all trigger bundling. To disable
    bundling, omit the parameter entirely.

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
POST /self/v1/api/schemas/evaluate/{path}
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

=== "413"

    The request body is too large. See [RFC 9110 §15.5.14](https://datatracker.ietf.org/doc/html/rfc9110#section-15.5.14).

=== "417"

    The `Expect` header carries an expectation other than `100-continue`. See [RFC 9110 §10.1.1](https://datatracker.ietf.org/doc/html/rfc9110#section-10.1.1).

### Trace

*This endpoint takes a JSON instance as a request body and evaluates it against
the JSON Schema located at the `{path}` parameter.*

```
POST /self/v1/api/schemas/trace/{path}
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

=== "413"

    The request body is too large. See [RFC 9110 §15.5.14](https://datatracker.ietf.org/doc/html/rfc9110#section-15.5.14).

=== "417"

    The `Expect` header carries an expectation other than `100-continue`. See [RFC 9110 §10.1.1](https://datatracker.ietf.org/doc/html/rfc9110#section-10.1.1).

#### Tracing against a schema in the request

*This endpoint takes a JSON instance and a JSON Schema in the request body and
traces the evaluation of one against the other, without the schema having to be
in the catalog.*

```
POST /self/v1/api/schemas/trace
```

The request body is an object rather than the bare instance the form above
takes:

| Property    | Type   | Required | Description |
|-------------|--------|-----|-------------------------------------|
| `/instance` | JSON   | Yes | The instance to trace evaluation for |
| `/schema`   | Object | Yes | The schema to evaluate it against |

The schema must be an object declaring the dialect it is written against with
[`$schema`](https://www.learnjsonschema.com/2020-12/core/schema/). A boolean
schema is refused, as it declares no dialect and this endpoint does not guess
one.

A [`$ref`](https://www.learnjsonschema.com/2020-12/core/ref/) in the supplied
schema resolves against this catalog, naming a schema by the same URL it is
served at, and is subject to the same authentication as fetching that schema
directly. A [`$ref`](https://www.learnjsonschema.com/2020-12/core/ref/) naming
any other origin is refused, and so is one naming a path the caller may not
read, which is refused in the same way as one that names nothing at all.
Official JSON Schema metaschemas resolve without being in the catalog, which is
what lets a caller name a dialect. Every hop of a reference chain is resolved on
the same terms, so a reference reaching a schema the caller cannot read is
refused wherever in the chain it appears.

The response is identical to the form above.

Because the schema arrives with the request rather than being compiled ahead of
time, what it may cost is bounded. The request body cap is lower here than the
one the form above applies, so an instance too large for this endpoint can still
be evaluated against a catalog schema by path.

The supplied schema is compiled on every request and is not cached, so this
endpoint is slower per call than naming a schema by path.

=== "200"

    The same response as the form above.

=== "400"

    The body is not the expected object, the schema cannot be compiled, or a [`$ref`](https://www.learnjsonschema.com/2020-12/core/ref/) in it does not resolve.

=== "413"

    The request body is too large. See [RFC 9110 §15.5.14](https://datatracker.ietf.org/doc/html/rfc9110#section-15.5.14).

=== "417"

    The `Expect` header carries an expectation other than `100-continue`. See [RFC 9110 §10.1.1](https://datatracker.ietf.org/doc/html/rfc9110#section-10.1.1).

=== "422"

    The schema is too complex to compile, in the number of locations framing it registers, the number of instructions it compiles to, or how deeply it nests.

### RDF

!!! success "Enterprise"

    This endpoint is only available in the [Enterprise](commercial.md)
    edition. Learn more about [commercial licensing](commercial.md).

*This endpoint takes a JSON object wrapping an instance as its request body,
validates the instance against the JSON Schema located at the `{path}`
parameter, and promotes it to
[JSON-LD](https://www.w3.org/TR/json-ld11/) (and therefore RDF) using the
schema's `x-jsonld-*` annotations.*

```
POST /self/v1/api/schemas/rdf/{path}
```

The same schema that validates the instance declares how it maps to Linked
Data, keeping a single source of truth for both concerns. Learn more about
this approach in [Fully solving JSON Schema and JSON-LD
interoperability](https://www.sourcemeta.com/blog/json-schema-jsonld-interoperability/).
The annotation vocabulary is documented in the [JSON Schema CLI RDF
documentation](https://github.com/sourcemeta/jsonschema/blob/main/docs/rdf.markdown).
A schema without such annotations (including schemas on dialects older than
2019-09, which do not support annotation collection) produces an empty
JSON-LD document. Availability follows the evaluate flag: schemas excluded
from evaluation in the [configuration file](configuration.md) cannot be
promoted.

Unlike the evaluate and trace endpoints, the request body is not the bare
instance, but a JSON object with the following properties:

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `/instance` | JSON | Yes | The instance to validate and promote |
| `/flatten` | Boolean | No | Whether to flatten the resulting document. Defaults to `false` |
| `/context` | Object | No | A JSON-LD context to compact (or, with `flatten`, flatten) the resulting document against |

Without a `context`, the response is the document in [expanded
form](https://www.w3.org/TR/json-ld11/#expanded-document-form) (or [flattened
form](https://www.w3.org/TR/json-ld11/#flattened-document-form) with
`flatten`). With a `context`, the response is in [compacted
form](https://www.w3.org/TR/json-ld11/#compacted-document-form). Remote
contexts are not fetched.

=== "200"

    The instance promoted to JSON-LD, served as `application/ld+json`.

=== "400"

    You must pass a request body that matches the request schema, or the
    provided `context` cannot be processed (for example because it references
    a remote context).

=== "404"

    The schema does not exist.

=== "405"

    The [configuration file](configuration.md) excludes evaluation for this
    schema, or the [configuration file](configuration.md) marks the schema
    collection as listed but not served.

=== "413"

    The request body is too large. See [RFC 9110 §15.5.14](https://datatracker.ietf.org/doc/html/rfc9110#section-15.5.14).

=== "417"

    The `Expect` header carries an expectation other than `100-continue`. See [RFC 9110 §10.1.1](https://datatracker.ietf.org/doc/html/rfc9110#section-10.1.1).

=== "422"

    The instance does not conform to the schema (the problem details carry
    the standard [JSON Schema output
    errors](https://json-schema.org/draft/2020-12/json-schema-core#name-output-structure)),
    or the schema's JSON-LD annotations cannot be resolved for this instance
    (the problem details carry the offending annotation facet and instance
    location).

### Metadata

*This endpoint retrieves metadata information about the JSON Schema located at
the `{path}` parameter.*

```
GET /self/v1/api/schemas/metadata/{path}
```

=== "200"

    | Property                       | Type                     | Required | Description |
    |--------------------------------|--------------------------|-----|-------------------------------------|
    | `/path` | String | Yes | The relative URL of the schema |
    | `/identifier` | String | Yes | The absolute URI of the schema |
    | `/dialect` | String | Yes | The dialect URI of the schema |
    | `/baseDialect` | String | Yes | The base dialect URI of the schema |
    | `/health` | Integer | Yes | The health score of the schema |
    | `/priority` | Integer | Yes | An importance hint from `0` (least important) to `100` (most important), inherited from the schema collection's [`x-sourcemeta-one:priority`](configuration.md) configuration value |
    | `/private` | Boolean | Yes | Whether an authentication policy governs this schema |
    | `/dependencies` | Integer | Yes | The number of direct and indirect dependencies of the schema |
    | `/bytes` | Integer | Yes | The bytes that the schema occupies |
    | `/bytesBundled` | Integer | Yes | The bytes that the schema occupies when bundled |
    | `/alert` | String / Null | No | The human readable alert message for the schema collection, if any. The web explorer renders this as Markdown |
    | `/title` | String | No | The title of the schema, if any |
    | `/description` | String | No | The description of the schema, if any. The web explorer renders this as Markdown |
    | `/examples` | Array | Yes | Up to 10 of the schema examples, if any |
    | `/breadcrumb` | Array | Yes | The breadcrumb of the schema |
    | `/breadcrumb/*/name` | String | Yes | The breadcrumb entry URL path |
    | `/breadcrumb/*/path` | String | Yes | The relative URL of the breadcrumb location |

=== "404"

    The schema does not exist.

### Search

*This endpoint searches for JSON Schemas based on the provided query `{term}`.*

```
GET /self/v1/api/schemas/search?q={term}[&limit={n}][&scope={fields}]
```

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `q` | String | Yes | - | Search term (case-insensitive substring, at most 256 characters) |
| `limit` | Integer | No | 10 | Maximum number of results, between 1 and 100 |
| `scope` | String | No | `path,title,description` | Comma-separated fields to match against |

The valid values for `scope` are `path`, `title`, and `description`, which can
be combined in any order (i.e. `scope=title,description`).

=== "200"

    | Property | Type | Required | Description |
    |----------|------|----------|-------------|
    | `/*/path` | String | Yes | The relative URL of the schema |
    | `/*/identifier` | String | Yes | The absolute URL of the schema |
    | `/*/title` | String | No | The title of the schema (may be an empty string) |
    | `/*/description` | String | No | The description of the schema (may be an empty string). The web explorer renders this as Markdown |
    | `/*/priority` | Integer | Yes | An importance hint from `0` (least important) to `100` (most important), inherited from the schema collection's [`x-sourcemeta-one:priority`](configuration.md) configuration value |
    | `/*/health` | Integer | Yes | The health score of the schema (0 to 100) |

=== "400"

    Returned when `q` is missing or empty, when `q` or `limit` do not match
    their corresponding ranges, or any query parameter has an invalid type.

### Dependencies

*This endpoint retrieves all direct and indirect dependencies of the JSON
Schema located at the specified `{path}` parameter.*

```
GET /self/v1/api/schemas/dependencies/{path}
```

=== "200"

    | Property | Type | Required | Description |
    |----------|------|----------|-------------|
    | `/*/from` | String | Yes | The absolute URL of the schema that originates the dependency |
    | `/*/to` | String | Yes | The absolute URL of the schema being referenced |
    | `/*/at` | String | Yes | The JSON Pointer to the schema location where the dependency originates |

=== "404"

    The schema does not exist.

### Dependents

*This endpoint retrieves all direct and transitive dependents of the JSON
Schema located at the specified `{path}` parameter. A dependent is a schema
that references this schema, either directly or indirectly through a chain of
references.*

```
GET /self/v1/api/schemas/dependents/{path}
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
GET /self/v1/api/schemas/health/{path}
```

=== "200"

    | Property | Type | Required | Description |
    |----------|------|----------|-------------|
    | `/score` | Integer | Yes | The overall health score of the schema (0 to 100) |
    | `/errors` | Array | Yes | Array of health issues found in the schema |
    | `/errors/*/pointers` | Array | Yes | The paths where the issue occurs |
    | `/errors/*/pointers/*` | String | Yes | A JSON Pointer path of where the issue occurs |
    | `/errors/*/name` | String | Yes | The identifier name of the health issue |
    | `/errors/*/message` | String | Yes | Human-readable description of the issue. The web explorer renders this as Markdown |
    | `/errors/*/description` | String / Null | No | Additional description (may be null). The web explorer renders this as Markdown |

=== "404"

    The schema does not exist.

### Locations

*This endpoint retrieves metadata about every URI associated with the JSON
Schema located at the specified `{path}` parameter, including schema resources,
subschemas, and anchors.*

```
GET /self/v1/api/schemas/locations/{path}
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
    | `/static/*/position` | Array | Yes | The entry location positions |
    | `/static/*/position/0` | Integer | Yes | Starting line number |
    | `/static/*/position/1` | Integer | Yes | Starting column number |
    | `/static/*/position/2` | Integer | Yes | Ending line number |
    | `/static/*/position/3` | Integer | Yes | Ending column number |
    | `/static/*/propertyName` | Boolean | Yes | Whether the location applies to a property name |
    | `/static/*/orphan` | Boolean | Yes | Whether the location is inside a definitions container |
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
    | `/dynamic/*/position` | Array | Yes | The entry location positions |
    | `/dynamic/*/position/0` | Integer | Yes | Starting line number |
    | `/dynamic/*/position/1` | Integer | Yes | Starting column number |
    | `/dynamic/*/position/2` | Integer | Yes | Ending line number |
    | `/dynamic/*/position/3` | Integer | Yes | Ending column number |
    | `/dynamic/*/propertyName` | Boolean | Yes | Whether the location applies to a property name |
    | `/dynamic/*/orphan` | Boolean | Yes | Whether the location is inside a definitions container |

=== "404"

    The schema does not exist.

=== "405"

    The [configuration file](configuration.md) marks the schema collection as listed but not served.

### Stats

*This endpoint retrieves keyword statistics, by vocabulary, about every URI
associated with the JSON Schema located at the specified `{path}` parameter.*

```
GET /self/v1/api/schemas/stats/{path}
```

=== "200"

    | Property | Type | Required | Description |
    |----------|------|----------|-------------|
    | `/<vocabulary>/<keyword>` | Integer | Yes | The number of occurrences keywords of a specific keyword name from a specific vocabulary (or `unknown` otherwise) |

=== "404"

    The schema does not exist.

=== "405"

    The [configuration file](configuration.md) marks the schema collection as listed but not served.

### Positions

*This endpoint retrieves line and column position information for every token
in the JSON Schema located at the specified `{path}` parameter.*

```
GET /self/v1/api/schemas/positions/{path}
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

## Model Context Protocol

!!! success "Enterprise"

    The Model Context Protocol server is only available in the
    [Enterprise](commercial.md) edition. Learn more about [commercial
    licensing](commercial.md).

*This endpoint exposes the entire instance as a [Model Context
Protocol](https://modelcontextprotocol.io) server, offering every JSON Schema
in the catalog as an MCP resource and every action documented above as an
MCP tool.*

```
POST /self/v1/mcp
```

Sourcemeta One implements the [Streamable
HTTP](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports#streamable-http)
transport with full CORS support, and enforces the [`Origin` header
validation](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports#security-warning)
principle recommended by the specification to protect against DNS rebinding
attacks.

**Authorization.** The specification's
[authorization](https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization)
model has this endpoint act as an OAuth 2.1 resource server that tells a client
where its tokens come from. Where a [`jwt`](configuration.md#jwt) policy names
this endpoint as its `audience`, the instance serves that discovery both ways
the specification accepts: [RFC
9728](https://datatracker.ietf.org/doc/html/rfc9728) protected resource
metadata at its standard well-known location, and a `resource_metadata`
parameter naming it in the `WWW-Authenticate` header of every denial here. The
specification defines a resource identifier as an `https` URL and makes no
exception for loopback, so an instance served in the clear publishes nothing
rather than metadata a conforming client would reject.

The specification also has an MCP server accept only tokens issued for itself,
rather than for whatever wider resource happens to contain it, so that a token
minted for one service cannot be spent at another. A presented token must
therefore name this endpoint in `aud` whichever policy admits the caller, and a
token naming only the registry reaches everything that policy governs except
here. An `aud` claim may list several audiences, so one token
naming both the registry and this endpoint continues to reach both. Credentials
that carry no audience, an [`apiKey`](configuration.md#api-key) or a browser
session, are unaffected. OAuth scopes are not implemented, so no `scope`
parameter is advertised and no request is refused for want of one.

**Protocol versions.** The server simultaneously supports three revisions of
the MCP specification:
[`2025-03-26`](https://modelcontextprotocol.io/specification/2025-03-26),
[`2025-06-18`](https://modelcontextprotocol.io/specification/2025-06-18), and
[`2025-11-25`](https://modelcontextprotocol.io/specification/2025-11-25).
Clients pick a revision on every request via the `MCP-Protocol-Version`
header, falling back to `2025-03-26` when omitted as the [specification
requires](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports#protocol-version-header).
We recommend connecting with the latest revision to take advantage of all
available features, but the server gracefully degrades to support older
clients as needed.

**Resources.** Every JSON Schema in the catalog is offered as an MCP resource
addressable by its canonical absolute URI, served in paginated form. The
configured [`x-sourcemeta-one:priority`](configuration.md) hint of each
schema is mapped to the standard MCP `annotations.priority` value, so that
AI clients can rank schemas by their declared importance. A resource listing
names only the schemas the client's credential reaches.

**Tools.** Every action documented in this page is also exposed as an MCP tool
that performs the same work over JSON-RPC. The server supports the full range
of advanced MCP tool features applicable to each revision, including per-tool
[`outputSchema`](https://modelcontextprotocol.io/specification/2025-11-25/server/tools#output-schema)
declarations, [structured
content](https://modelcontextprotocol.io/specification/2025-11-25/server/tools#structured-content)
responses,
[`resource_link`](https://modelcontextprotocol.io/specification/2025-11-25/server/tools#resource-links)
content blocks, [JSON-RPC
batching](https://www.jsonrpc.org/specification#batch), and the standard [tool
hints](https://modelcontextprotocol.io/specification/2025-11-25/server/tools#tool)
(`readOnlyHint`, `destructiveHint`, `idempotentHint`, `openWorldHint`).
`tools/list` offers only the tools whose endpoint the client's credential
admits it to, and calling one that was not listed is answered as an unknown
tool.

!!! warning "Tool argument stringification"

    Note several widely-deployed MCP clients incorrectly stringify non-string
    tool arguments before transmission. See the following open tickets:
    [`anthropics/claude-code#24599`](https://github.com/anthropics/claude-code/issues/24599)
    and
    [`modelcontextprotocol/python-sdk#1112`](https://github.com/modelcontextprotocol/python-sdk/issues/1112).
    We work around this on a per-tool basis as needed so that affected clients
    remain fully interoperable with Sourcemeta One. We aim to eventually revert
    these workarounds once the client ecosystem stabilises.

!!! warning "MCP client schema compliance"

    The MCP ecosystem is young and several widely-deployed clients get confused
    by any tool `inputSchema` beyond the most trivial shape, rejecting or
    silently degrading legal JSON Schema constructs such as `$ref` (including
    the schemas-as-resources pattern this server relies on). OpenAI Codex is
    currently among the most affected. See for example
    [`openai/codex#13746`](https://github.com/openai/codex/issues/13746),
    [`openai/codex#3152`](https://github.com/openai/codex/issues/3152), and
    [`openai/codex#4176`](https://github.com/openai/codex/issues/4176).  Our
    stance on broad compliance gaps like these is to *not* work around them on
    our side. Mangling the MCP surface to fit each non-compliant client would
    compromise the integrity of the specification for every other client. We
    will instead keep the server faithful to the specification and put pressure
    on MCP client providers to reach a reasonable level of compliance.

=== "200"

    A JSON-RPC response envelope, or, on `2025-03-26`, a batch of envelopes.

=== "202"

    Acknowledged notification with no body.

=== "400"

    The `MCP-Protocol-Version` header is not one of the supported revisions.

=== "403"

    The request `Origin` does not match the configured instance URL.

=== "405"

    The HTTP method is not `POST` or `OPTIONS`.

=== "413"

    The request body exceeds the maximum allowed size.
