ARG SOURCEMETA_REGISTRY=registry-enterprise
FROM ${SOURCEMETA_REGISTRY} AS builder

COPY public/registry.json /app/public/registry.json
COPY vendor /app/vendor
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
CMD [ "/app/index", "8000" ]
