Sourcemeta Registry
===================

A high-performance OEM micro-service to serve collections of JSON Schema over
HTTP and build a schema registry for your organisation.

Configuration
-------------

The Sourcemeta Registry requires a configuration file that defines the schema
collections and pages the instance will serve. See
[`schemas/configuration.json`](./schemas/configuration.json) for the JSON
Schema that defines this configuration file format. The format is designed to
be easy to understand and performant to interact with at runtime.  Here is an
example:

```json
{
  "url": "http://localhost:8000",
  "port": 8000,
  "schemas": {
    "example/schemas": {
      "base": "https://example.com/schemas",
      "path": "./schemas/example/folder"
    }
  }
}
```

The `url` property defines the base URL of the instance and will be used for
reidentifying schemas at runtime, so make sure its correct. The `port` property
is optional. The `schemas` property mounts a given directory of schemas into a
certain relative path.

Deployment
----------

We release a small `registry-ce` Docker base image to [GitHub
Packages](https://github.com/sourcemeta/registry/pkgs/container/registry-ce)
that you are expected to extend for your own deployment as follows. Replace any
`{{ }}` variable with the values of your choosing:

```docker
FROM ghcr.io/sourcemeta/registry-ce:{{ version }}

# Copy your configuration file (see previous section) and schema files
COPY {{ path/to/configuration.json }} /app/configuration.json
COPY {{ path/to/schemas }} /app/schemas

# Index your schema directory given your configuration
RUN sourcemeta-registry-index /app/configuration.json /app/index \
    && rm -rf /app/schemas /app/configuration.json

# Run the registry against your indexed directory
ENTRYPOINT [ "/usr/bin/sourcemeta-registry-server" ]
CMD [ "/app/index" ]
```
