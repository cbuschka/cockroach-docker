TOP_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
VERSION := latest

build:
	cd ${TOP_DIR} && \
	docker build --tag cockroach-dev:local .

run:	build
	docker run -ti --rm --name=cockroach --ulimit nofile=262144:262144 cockroach-dev:local

push:
	docker tag cockroach-dev:local cbuschka/cockroach-dev:${VERSION}
	docker push cbuschka/cockroach-dev:${VERSION}

