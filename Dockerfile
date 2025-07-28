FROM debian:bookworm AS builder
RUN apt-get --yes update && apt-get install --yes --no-install-recommends \
  build-essential cmake sassc gzip shellcheck ca-certificates \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY cmake /source/cmake
COPY src /source/src
COPY schemas /source/schemas
COPY vendor /source/vendor
COPY CMakeLists.txt /source/CMakeLists.txt

# For testing
COPY test/cli /source/test/cli
COPY test/unit /source/test/unit
COPY test/schemas /source/test/schemas

# Commercial editions require a paid license
# See https://github.com/sourcemeta/registry/blob/main/LICENSE
ARG SOURCEMETA_REGISTRY_EDITION=starter

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
RUN cmake --build /build --config Release --target jsonschema_fmt_test
RUN cmake --build /build --config Release --target jsonschema_lint
RUN cmake --build /build --config Release --target shellcheck

RUN ctest --test-dir /build --build-config Release \
  --output-on-failure --parallel

FROM debian:bookworm-slim
COPY --from=builder /usr/bin/sourcemeta-registry-index \
  /usr/bin/sourcemeta-registry-index
COPY --from=builder /usr/bin/sourcemeta-registry-server \
  /usr/bin/sourcemeta-registry-server
COPY --from=builder /usr/share/sourcemeta/registry \
  /usr/share/sourcemeta/registry
