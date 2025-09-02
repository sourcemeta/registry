ARG SOURCEMETA_REGISTRY_EDITION=starter
FROM registry-${SOURCEMETA_REGISTRY_EDITION} AS builder
ARG SOURCEMETA_REGISTRY_CONFIGURATION=html
COPY registry-html.json /app/registry-html.json
COPY registry-headless.json /app/registry-headless.json
COPY registry-empty.json /app/registry-empty.json
COPY schemas /app/schemas
COPY manifest-html.txt /app/manifest-html.txt
COPY manifest-headless.txt /app/manifest-headless.txt
COPY manifest-empty.txt /app/manifest-empty.txt
COPY manifest-check.sh /app/manifest-check.sh

# Just for the sake of the sandbox
ENV SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1

RUN sourcemeta-registry-index /app/registry-${SOURCEMETA_REGISTRY_CONFIGURATION}.json /app/index
# For basic testing purposes
RUN /app/manifest-check.sh /app/index /app/manifest-${SOURCEMETA_REGISTRY_CONFIGURATION}.txt

FROM registry-${SOURCEMETA_REGISTRY_EDITION}
COPY --from=builder /app/index /app/index

# Just for the sake of the sandbox
ENV SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1

ARG SOURCEMETA_REGISTRY_PORT=8000
ENV SOURCEMETA_REGISTRY_PORT=${SOURCEMETA_REGISTRY_PORT}

ENTRYPOINT /usr/bin/sourcemeta-registry-server /app/index ${SOURCEMETA_REGISTRY_PORT}
