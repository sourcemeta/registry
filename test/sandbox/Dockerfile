ARG SOURCEMETA_REGISTRY_EDITION=starter
FROM registry-${SOURCEMETA_REGISTRY_EDITION} AS builder
COPY registry.json /app/registry.json
COPY schemas /app/schemas
COPY manifest.txt /app/manifest.txt
COPY manifest-check.sh /app/manifest-check.sh

# Just for the sake of the sandbox
ENV SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1

RUN sourcemeta-registry-index /app/registry.json /app/index
# For basic testing purposes
RUN /app/manifest-check.sh /app/index /app/manifest.txt

FROM registry-${SOURCEMETA_REGISTRY_EDITION}
COPY --from=builder /app/index /app/index

# Just for the sake of the sandbox
ENV SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1

ENTRYPOINT [ "/usr/bin/sourcemeta-registry-server" ]
CMD [ "/app/index" ]
