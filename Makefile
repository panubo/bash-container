GIT_EMAIL := $(shell git config user.email)

rendered/panubo-functions.sh: rendered functions/*
	cat functions/* > rendered/panubo-functions.sh

rendered:
	mkdir rendered

rendered/panubo-functions.tar.gz: rendered/panubo-functions.sh
	tar -C rendered/ -zcf rendered/panubo-functions.tar.gz panubo-functions.sh

rendered/panubo-functions.tar.gz.asc: rendered/panubo-functions.tar.gz
	gpg2 --default-key $(GIT_EMAIL) --output rendered/panubo-functions.tar.gz.asc --armor --detach-sig rendered/panubo-functions.tar.gz

.PHONY: sign build-docker-debian build-docker-alpine run-docker-debian run-docker-alpine test-docker-debian test-docker-alpine build-example-debian build-example-alpine test shellcheck
sign: rendered/panubo-functions.tar.gz.asc

build-docker-debian:
	docker build -f Dockerfile.debian -t panubo/bash-container-debian .

build-docker-alpine:
	docker build -f Dockerfile.alpine -t panubo/bash-container-alpine .

run-docker-debian: build-docker-debian
	docker run --rm -it -v $(shell pwd):/src --workdir /src --user user panubo/bash-container-debian

run-docker-alpine: build-docker-alpine
	docker run --rm -it -v $(shell pwd):/src --workdir /src panubo/bash-container-alpine

test-docker-debian:
	docker run --rm -i -v $(shell pwd):/src --workdir /src --user user panubo/bash-container-debian make test shellcheck

test-docker-alpine:
	docker run --rm -i -v $(shell pwd):/src --workdir /src panubo/bash-container-alpine make test shellcheck

build-example-debian:
	docker build -f Dockerfile.debian-install -t panubo/bash-container-debian-example .

build-example-alpine:
	docker build -f Dockerfile.alpine-install -t panubo/bash-container-alpine-example .

test:
	./test.sh

shellcheck:
	$(eval tmpdir := $(shell mktemp -d))
	cat functions/* > $(tmpdir)/panubo-functions.sh
	shellcheck $(tmpdir)/panubo-functions.sh
	rm -rf $(tmpdir)
