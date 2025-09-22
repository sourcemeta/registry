---
hide:
  - navigation
---

# Integrations

We aim for the Sourcemeta Registry to seamlessly integrate with as many
applications and ecosystems as possible. Its [HTTP API](api.md) provides a
robust foundation for custom integrations, and we are always eager to hear more
about use cases that demand a more direct integration. If you have any ideas,
please reach out on [GitHub
Discussions](https://github.com/sourcemeta/registry/discussions)!

## Languages

### Deno

The Sourcemeta Registry supports [Deno HTTPS
imports](https://docs.deno.com/runtime/fundamentals/modules/#https-imports),
allowing you to directly import schema definitions (along with their
dependencies, if any) into your programs.

!!! success "Zero-Config Dependency Resolution"

    Forget about manually managing schema dependencies! The Registry
    intelligently detects Deno `import` requests and automatically serves
    [bundled
    schemas](https://json-schema.org/blog/posts/bundling-json-schema-compound-documents)
    with all `$ref` dependencies pre-resolved. What used to require complex
    dependency management now happens seamlessly behind the scenes.

To pull a JSON Schema into a Deno program, using a JSON `import` pointing to
the schema URL. In this case, replace `registry.example.com` with your Registry
URL and `my/schema.json` with the path to the schema you want to import.

```javascript title="main.js"
import schema from "https://registry.example.com/my/schema.json" with { type: "json" };
console.log(schema);
```

Then, run the program using the
[`--allow-import`](https://docs.deno.com/runtime/fundamentals/security/#importing-from-the-web)
permission.

```sh
deno run --allow-import main.js
```

Deno will download and cache the schema on the first run. To force Deno to
query the Registry again, use the
[`--reload`](https://docs.deno.com/runtime/fundamentals/modules/#reloading-modules)
option:

```sh
deno run --allow-import --reload main.js
```

## Specifications

### OpenAPI

OpenAPI specifications may directly reference schemas from the Registry using
the `$ref` keyword. For example:

```yaml title="openapi.yaml" hl_lines="12 19"
openapi: 3.1.0
info:
  title: My API
  version: 1.0.0
paths:
  /users:
    post:
      requestBody:
        content:
          application/json:
            schema:
              $ref: "https://registry.example.com/schemas/user.json"
      responses:
        '201':
          description: User created
          content:
            application/json:
              schema:
                $ref: "https://registry.example.com/schemas/user.json"
```

On distribution, you should bundle the OpenAPI specification to automatically
fetch and embed external schema references. This is how you can do it using the
popular [Redocly CLI](https://redocly.com/docs/cli/commands/bundle):

```sh
redocly bundle path/to/openapi.yaml
```

!!! tip

    This is a powerful strategy to have a growing amount of APIs defined using
    a single source of truth of data definitions. Bundling allows you get a
    self-contained OpenAPI specification for distribution that won't require
    further network requests to resolve, whilst allowing you to maintain clean
    separation between your API definitions and reusable schemas during
    development.

## Editors

### Visual Studio Code

The Sourcemeta Registry offers improved Visual Studio Code schema
auto-completion support. It does this by automatically serving the editor with
transformed schemas (without loss of semantics) that aim to workaround its
[significant compliance
issues](https://bowtie.report/#/implementations/ts-vscode-json-languageservice)
that prevent many schemas from working correctly.

The key limitations that the Registry aims to workaround include:

- Missing support for `$id` (and its older `id` counter-part). This affects
  auto-completion of bundled or complex schemas. See
  [`microsoft/vscode-json-languageservice#224`](https://github.com/microsoft/vscode-json-languageservice/issues/224)

- Missing support for `$dynamicRef`. This affects meta-schema auto-completion.
  See
  [`microsoft/vscode-json-languageservice#149`](https://github.com/microsoft/vscode-json-languageservice/issues/149)

!!! note

    Whilst this compatibility layer significantly improves Visual Studio Code
    auto-completion support, some advanced schema features may still not work
    due to fundamental limitations in their implementation. The ultimate
    solution is fixing the editor's compliance, which is of course outside of
    our control
