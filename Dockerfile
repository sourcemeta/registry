FROM debian:bookworm AS builder

RUN apt-get --yes update && apt-get install --yes --no-install-recommends curl ca-certificates \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
RUN apt-get --yes update && apt-get install --yes --no-install-recommends \
  build-essential cmake sassc esbuild shellcheck nodejs xxd \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY openapi /source/openapi
COPY package.json /source/package.json
COPY package-lock.json /source/package-lock.json
COPY cmake /source/cmake
COPY src /source/src
COPY contrib /source/contrib
COPY collections /source/collections
COPY vendor /source/vendor
COPY CMakeLists.txt /source/CMakeLists.txt

# For testing
COPY test/cli /source/test/cli
COPY test/unit /source/test/unit

# Commercial editions require a paid license
# See https://github.com/sourcemeta/registry/blob/main/LICENSE
ARG SOURCEMETA_REGISTRY_EDITION=starter

RUN cd /source && npm ci

RUN	cmake -S /source -B ./build \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DCMAKE_COMPILE_WARNING_AS_ERROR:BOOL=ON \
  -DREGISTRY_INDEX:BOOL=ON \
  -DREGISTRY_SERVER:BOOL=ON \
  -DREGISTRY_TESTS:BOOL=ON \
  -DREGISTRY_EDITION:STRING=${SOURCEMETA_REGISTRY_EDITION} \
  -DBUILD_SHARED_LIBS:BOOL=OFF

RUN cmake --build /build --config Release --parallel 2
RUN cmake --install /build --prefix /usr --verbose --config Release \
  --component sourcemeta_registry

# Linting
RUN cmake --build /build --config Release --target clang_format_test
RUN cmake --build /build --config Release --target shellcheck
RUN cmake --build /build --config Release --target jsonschema_fmt_test
RUN cmake --build /build --config Release --target jsonschema_metaschema
RUN cmake --build /build --config Release --target jsonschema_lint

RUN ctest --test-dir /build --build-config Release \
  --output-on-failure --parallel

FROM debian:bookworm-slim

# See https://github.com/opencontainers/image-spec/blob/main/annotations.md#pre-defined-annotation-keys
LABEL org.opencontainers.image.url="https://registry.sourcemeta.com"
LABEL org.opencontainers.image.documentation="https://registry.sourcemeta.com"
LABEL org.opencontainers.image.source="https://github.com/sourcemeta/registry"
LABEL org.opencontainers.image.vendor="Sourcemeta"
LABEL org.opencontainers.image.licenses="Commercial"
LABEL org.opencontainers.image.title="Sourcemeta Registry"
LABEL org.opencontainers.image.description="The JSON Schema registry"
LABEL org.opencontainers.image.authors="Sourcemeta <hello@sourcemeta.com>"

COPY --from=builder /usr/bin/sourcemeta-registry-index \
  /usr/bin/sourcemeta-registry-index
COPY --from=builder /usr/bin/sourcemeta-registry-server \
  /usr/bin/sourcemeta-registry-server
COPY --from=builder /usr/share/sourcemeta/registry \
  /usr/share/sourcemeta/registry

# For debugging purposes
RUN ldd /usr/bin/sourcemeta-registry-index
RUN ldd /usr/bin/sourcemeta-registry-server

# We expect images that extend this one to use this directory
ARG SOURCEMETA_REGISTRY_WORKDIR=/source
ENV SOURCEMETA_REGISTRY_WORKDIR=${SOURCEMETA_REGISTRY_WORKDIR}
WORKDIR ${SOURCEMETA_REGISTRY_WORKDIR}

# To make it easier for the consumer. So they can generate the index
# without caring about output locations at all
ARG SOURCEMETA_REGISTRY_OUTPUT=/sourcemeta
ENV SOURCEMETA_REGISTRY_OUTPUT=${SOURCEMETA_REGISTRY_OUTPUT}
RUN echo "#!/bin/sh\nexec /usr/bin/sourcemeta-registry-index \"\$1\" \"${SOURCEMETA_REGISTRY_OUTPUT}\"" \
  > /usr/bin/sourcemeta && chmod +x /usr/bin/sourcemeta
