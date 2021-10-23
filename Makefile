TOP_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
VERSION := latest

build:
	cd ${TOP_DIR} && \
	docker build --tag cockroach-docker:local .

run-insecure:	build
	docker run -ti --rm --name=cockroach -e COCKROACH_SECURITY_MODE=insecure --ulimit nofile=262144:262144 cockroach-docker:local

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
		cockroach-docker:local

push:	build
	docker tag cockroach-docker:local cbuschka/cockroach:${VERSION}
	docker push cbuschka/cockroach:${VERSION}
