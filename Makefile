TOP_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
VERSION := latest

build:
	cd ${TOP_DIR} && \
	docker build --tag cockroach-dev:local .

run-insecure:	build
	docker run -ti --rm --name=cockroach -e COCKROACH_SECURITY_MODE=insecure --ulimit nofile=262144:262144 cockroach-dev:local

run-secure:	build
	docker run -ti --rm --name=cockroach \
		-e COCKROACH_SECURITY_MODE=secure \
		-e COCKROACH_ROOT_PASSWORD=asdfasdf \
		-e COCKROACH_DATABASE=develop \
		-e COCKROACH_USER=developer \
		-e COCKROACH_PASSWORD=asdfasdf \
		-p 26257:26257 \
		-p 8443:8443 \
		--ulimit nofile=20000:40000 \
		--ulimit nproc=65535 \
		cockroach-dev:local

push:
	docker tag cockroach-dev:local cbuschka/cockroach-dev:${VERSION}
	docker push cbuschka/cockroach-dev:${VERSION}
