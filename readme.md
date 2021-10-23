# dockerized single node cockroach for local development

## Features
* single node cluster
* in insecure or secure mode with automatic certs creation
* optional database creation on start
* optional user with password creation on start
* database initialization scripts under /docker-entrypoint-initdb.d/, .sh and .sql

## Initialization script

Add scripts under /docker-entrypoint-initdb.d/; .sh and .sql are supported.

## Usage

### docker-compose

```
version: "3"
services:
  roach1:
    image: docker.io/cbuschka/cockroach:v21.1.11-5
    hostname: roach1
    environment:
      - COCKROACH_HTTP_ADDR=0.0.0.0:8443
      - COCKROACH_ADVERTISE_ADDR=localhost:26257
      - COCKROACH_LISTEN_ADDR=0.0.0.0:26257
      - COCKROACH_CERTS_DIR=/cockroach/cockroach-certs
      - COCKROACH_DATA_DIR=/cockroach/cockroach-data
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

| Variable                 | Value  | Required | Description |
|--------------------------|----------------|----------|----------|
| COCKROACH_SECURITY_MODE  | secure or insecure | Y | Chooses security mode of cockroach db, default: insecure |
| COCKROACH_HTTP_ADDR      | host:port      | N | Listen address for http console, default: 0.0.0.0:26257  |
| COCKROACH_ADVERTISE_ADDR | host:port      | N | Address other nodes shall connect to, default: hostname:26257 |
| COCKROACH_LISTEN_ADDR    | host:port      | N | Address cockroach process within docker container shall be listen on, default: 0.0.0.0:26257 |
| COCKROACH_CERTS_DIR      | /certs         | N | Directory for certificates, default: /cockroach/cockroach-certs |
| COCKROACH_DATA_DIR       | /data          | N | Directory for data, default: /cockroach/cockroach-data |
| COCKROACH_ROOT_PASSWORD  | secret         | N | Password for root, optional, default: none |
| COCKROACH_DATABASE       | exampledb      | N | Name of database to be created, default: none |
| COCKROACH_USER           | exampleuser    | N | Name of user to be created, default: none |
| COCKROACH_PASSWORD       | secret         | N | Password to set for created user, default: none |
| COCKROACH_EXTRA_START_OPTS |              | N | Opts to be added to start command, default: none | 

## License
Copyright (c) 2021 by [Cornelius Buschka](https://github.com/cbuschka).

[MIT-0](./license.txt)

