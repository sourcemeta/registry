ARG SOURCEMETA_REGISTRY_SANDBOX_EDITION=starter
FROM registry-${SOURCEMETA_REGISTRY_SANDBOX_EDITION}
ARG SOURCEMETA_REGISTRY_SANDBOX_EDITION
ARG SOURCEMETA_REGISTRY_SANDBOX_CONFIGURATION=html

COPY registry-html-enterprise.json .
COPY registry-html-pro.json .
COPY registry-html-starter.json .
COPY registry-headless-enterprise.json .
COPY registry-headless-pro.json .
COPY registry-headless-starter.json .
COPY registry-empty-enterprise.json .
COPY registry-empty-pro.json .
COPY registry-empty-starter.json .

COPY schemas schemas

# Just for the sake of the sandbox
ENV SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1

RUN sourcemeta registry-${SOURCEMETA_REGISTRY_SANDBOX_CONFIGURATION}-${SOURCEMETA_REGISTRY_SANDBOX_EDITION}.json --profile

# Check that by the end of the indexing, the workdir directory is empty
RUN test -d "$SOURCEMETA_REGISTRY_WORKDIR" -a \
  "$(find "$SOURCEMETA_REGISTRY_WORKDIR" -mindepth 1 -maxdepth 1 | wc -l)" -eq 0

# For basic testing purposes
COPY manifest-html-enterprise.txt .
COPY manifest-html-pro.txt .
COPY manifest-html-starter.txt .
COPY manifest-headless-enterprise.txt .
COPY manifest-headless-pro.txt .
COPY manifest-headless-starter.txt .
COPY manifest-empty-enterprise.txt .
COPY manifest-empty-pro.txt .
COPY manifest-empty-starter.txt .

COPY manifest-check.sh .
RUN ./manifest-check.sh "$SOURCEMETA_REGISTRY_OUTPUT" \
  ./manifest-${SOURCEMETA_REGISTRY_SANDBOX_CONFIGURATION}-${SOURCEMETA_REGISTRY_SANDBOX_EDITION}.txt
RUN rm -rf "$SOURCEMETA_REGISTRY_WORKDIR"
