FROM cockroachdb/cockroach:v21.1.11

ADD assets/ /

RUN mkdir -p /docker-entrypoint-initdb.d /cockroach/cockroach-data

VOLUME /cockroach/cockroach-data

EXPOSE 8080 26257
ENTRYPOINT [ "/docker-entrypoint.sh" ]
