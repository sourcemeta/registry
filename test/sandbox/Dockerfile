FROM registry AS builder
COPY configuration.json /app/configuration.json
COPY schemas /app/schemas
COPY manifest.txt /app/manifest.txt
COPY manifest-check.sh /app/manifest-check.sh
RUN sourcemeta-registry-index /app/configuration.json /app/index
# For basic testing purposes
RUN /app/manifest-check.sh /app/index /app/manifest.txt

FROM registry
COPY --from=builder /app/index /app/index
ENTRYPOINT [ "/usr/bin/sourcemeta-registry-server" ]
CMD [ "/app/index" ]
