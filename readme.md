# dockerized insecure single node cockroach for local development

## Initialization script

Add scripts under /docker-entrypoint-initdb./; .sh and .sql are supported.

## Trying out

### docker

```
docker run \
	--name cockroach \
	--rm -ti \
	--ulimit nofile=262144:262144 \
	docker.io/cbuschka/cockroach-dev:v21.1.11-1
```

### docker-compose

```
version: "3"
services:
  roach1:
    image: docker.io/cbuschka/cockroach-dev:v21.1.11-1
    hostname: roach1
    ports:
      - "26257:26257"
      - "8080:8080"
    ulimits:
      nproc: 65535
      nofile:
        soft: 20000
        hard: 40000
    volumes:
      - roach1-data:/cockroach/cockroach-data/:Z
    networks:
      roachnet:

volumes:
  roach1-data:

networks:
  roachnet:
```

## License

[MIT-0](./license.txt)

