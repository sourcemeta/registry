ARG SOURCEMETA_REGISTRY=registry-enterprise
FROM ${SOURCEMETA_REGISTRY}

COPY public/registry.json ./public/registry.json
COPY vendor vendor

ENV SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
RUN sourcemeta ./public/registry.json --profile
