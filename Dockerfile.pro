FROM debian:bookworm AS builder
RUN apt-get --yes update && apt-get install --yes --no-install-recommends \
  build-essential cmake sassc && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY cmake /source/cmake
COPY src /source/src
COPY schemas /source/schemas
COPY vendor /source/vendor
COPY CMakeLists.txt /source/CMakeLists.txt

# For testing
COPY Makefile /source/Makefile
COPY test/cli /source/test/cli

RUN	cmake -S /source -B ./build \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DREGISTRY_INDEX:BOOL=ON \
  -DREGISTRY_SERVER:BOOL=ON \
  -DREGISTRY_DEVELOPMENT:BOOL=OFF \
  -DREGISTRY_EDITION:STRING=pro \
  -DBUILD_SHARED_LIBS:BOOL=OFF

RUN cmake --build /build --config Release --parallel 2
RUN cmake --install ./build --prefix /usr --verbose \
  --config Release --component sourcemeta_registry

RUN make -C /source test PREFIX=/usr EDITION=pro

FROM debian:bookworm-slim
COPY --from=builder /usr/bin/sourcemeta-registry-index \
  /usr/bin/sourcemeta-registry-index
COPY --from=builder /usr/bin/sourcemeta-registry-server \
  /usr/bin/sourcemeta-registry-server
COPY --from=builder /usr/share/sourcemeta/registry \
  /usr/share/sourcemeta/registry
