# dockerized insecure single node cockroach for local development

## Initialization script

Add scripts under /docker-entrypoint-initdb./; .sh and .sql are supported.

## Usage

### docker-compose

```
version: "3"
services:
  roach1:
    image: docker.io/cbuschka/cockroach-dev:v21.1.11-2
    hostname: roach1
    environment:
      - COCKROACH_HTTP_ADDR=0.0.0.0:8443
      - COCKROACH_ADVERTISE_ADDR=localhost:26257
      - COCKROACH_LISTEN_ADDR=0.0.0.0:26257
      - COCKROACH_CERTS_DIR=/cockroach/cockroach-certs
      - COCKROACH_SECURITY_MODE=secure
      - COCKROACH_ROOT_PASSWORD=asdfasdf
      - COCKROACH_DATABASE=develop
      - COCKROACH_USER=developer
      - COCKROACH_PASSWORD=asdfasdf
    ports:
      - "26257:26257"
      - "8443:8443"
    ulimits:
      nproc: 65535
      nofile:
        soft: 20000
        hard: 40000
    volumes:
      - roach1-data:/cockroach/cockroach-data/:Z
      - roach1-certs:/cockroach/cockroach-certs/:Z
    networks:
      roachnet:

volumes:
  roach1-data:
  roach1-certs:

networks:
  roachnet:
```
[docker-compose.yml](./docker-compose.yml)

## Supported Environment Variables

| Variable                 | Example Value  | Required | Default Value  | Description |
|--------------------------|----------------|----------|----------------------------|----------|
| COCKROACH_SECURITY_MODE  | secure         | Y | insecure or secure | Chooses security mode of cockroach db
| COCKROACH_HTTP_ADDR      | host:port      | N | 0.0.0.0:26257 | Listen address for http console |
| COCKROACH_ADVERTISE_ADDR | host:port      | N | 0.0.0.0:26257 |  Address other nodes shall connect to |
| COCKROACH_LISTEN_ADDR    | host:port      | N | 0.0.0.0:26257 | Address cockroach process within docker container shall be listen on |
| COCKROACH_CERTS_DIR      | /certs         | N | /cockroach/cockroach-certs | Directory for certificates |
| COCKROACH_ROOT_PASSWORD  | secret         | N | none | Password for root, optional, default none |
| COCKROACH_DATABASE       | exampledb      | N | none | Name of database to be created |
| COCKROACH_USER           | exampleuser    | N | none | Name of user to be created |
| COCKROACH_PASSWORD       | secret         | N | none | Password to set for created user |
| COCKROACH_EXTRA_START_OPTS |              | N | none | Opts to be added to start command | 

## License
Copyright (c) 2021 by [Cornelius Buschka](https://github.com/cbuschka).

[MIT-0](./license.txt)

