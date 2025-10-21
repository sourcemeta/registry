FROM registry
ARG SOURCEMETA_REGISTRY_SANDBOX_CONFIGURATION=html

COPY registry-html.json .
COPY registry-headless.json .
COPY registry-empty.json .

COPY schemas schemas

RUN sourcemeta registry-${SOURCEMETA_REGISTRY_SANDBOX_CONFIGURATION}.json --profile

# Check that by the end of the indexing, the workdir directory is empty
RUN test -d "$SOURCEMETA_REGISTRY_WORKDIR" -a \
  "$(find "$SOURCEMETA_REGISTRY_WORKDIR" -mindepth 1 -maxdepth 1 | wc -l)" -eq 0

# For basic testing purposes
COPY manifest-html.txt .
COPY manifest-headless.txt .
COPY manifest-empty.txt .

COPY manifest-check.sh .
RUN ./manifest-check.sh "$SOURCEMETA_REGISTRY_OUTPUT" \
  ./manifest-${SOURCEMETA_REGISTRY_SANDBOX_CONFIGURATION}.txt
RUN rm -rf "$SOURCEMETA_REGISTRY_WORKDIR"
