FROM cockroachdb/cockroach:v21.1.11

ENV COCKROACH_HTTP_ADDR ""
ENV COCKROACH_ADVERTISE_ADDR ""
ENV COCKROACH_LISTEN_ADDR "0.0.0.0:26257"
ENV COCKROACH_CERTS_DIR "/cockroach/cockroach-certs"
ENV COCKROACH_SECURITY_MODE "insecure"
ENV COCKROACH_ROOT_PASSWORD ""
ENV COCKROACH_DATABASE ""
ENV COCKROACH_USER ""
ENV COCKROACH_PASSWORD ""
ENV COCKROACH_EXTRA_START_OPTS ""
ENV COCKROACH_DATA_DIR "/cockroach/cockroach-data"

ADD assets/ /

RUN mkdir -p /docker-entrypoint-initdb.d /cockroach/cockroach-data

VOLUME /cockroach/cockroach-certs
VOLUME /cockroach/cockroach-data

EXPOSE 8080 8443 26257
ENTRYPOINT [ "/docker-entrypoint.sh" ]
