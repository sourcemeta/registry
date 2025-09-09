ARG SOURCEMETA_REGISTRY_EDITION=starter
FROM registry-${SOURCEMETA_REGISTRY_EDITION}
ARG SOURCEMETA_REGISTRY_CONFIGURATION=html

COPY registry-html.json .
COPY registry-headless.json .
COPY registry-empty.json .
COPY schemas schemas

# Just for the sake of the sandbox
ENV SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1

RUN sourcemeta registry-${SOURCEMETA_REGISTRY_CONFIGURATION}.json
# TODO: Maybe the `sourcemeta` command can auto-clean?
RUN rm -rf "$SOURCEMETA_REGISTRY_WORKDIR"

# For basic testing purposes
COPY manifest-html.txt .
COPY manifest-headless.txt .
COPY manifest-empty.txt .
COPY manifest-check.sh .
RUN ./manifest-check.sh "$SOURCEMETA_REGISTRY_OUTPUT" \
  ./manifest-${SOURCEMETA_REGISTRY_CONFIGURATION}.txt
RUN rm -rf "$SOURCEMETA_REGISTRY_WORKDIR"

ARG SOURCEMETA_REGISTRY_PORT=8000
ENV SOURCEMETA_REGISTRY_PORT=${SOURCEMETA_REGISTRY_PORT}

ENTRYPOINT /usr/bin/sourcemeta-registry-server "$SOURCEMETA_REGISTRY_OUTPUT" ${SOURCEMETA_REGISTRY_PORT}
