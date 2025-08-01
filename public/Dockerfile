ARG SOURCEMETA_REGISTRY=registry-enterprise
FROM ${SOURCEMETA_REGISTRY} AS builder

# (1) Install dependencies required for the setup of this specific repository
RUN apt-get --yes update && apt-get install --yes --no-install-recommends curl ca-certificates
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
RUN apt-get --yes update && apt-get install --yes --no-install-recommends make nodejs

# (2) Index the schemas
COPY public/registry.json /app/public/registry.json
COPY vendor /app/vendor
COPY Makefile /app/Makefile
RUN make -C /app public-prepare
RUN ldd /usr/bin/sourcemeta-registry-index
RUN ldd /usr/bin/sourcemeta-registry-server
ENV SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
RUN /usr/bin/sourcemeta-registry-index /app/public/registry.json /app/index
# For logging purposes
RUN du -sh /app/index

FROM ${SOURCEMETA_REGISTRY}
COPY --from=builder /app/index /app/index
ENV SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
ENTRYPOINT [ "/usr/bin/sourcemeta-registry-server" ]
CMD [ "/app/index" ]
