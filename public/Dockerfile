ARG SOURCEMETA_REGISTRY=registry
FROM ${SOURCEMETA_REGISTRY}

COPY public/registry.json ./public/registry.json
COPY vendor vendor

RUN sourcemeta ./public/registry.json --profile
